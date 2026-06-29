import * as ElmCodegen from "../lib/elmCodegen.js"
import z from "zod"
import path from "path"
import * as Astify from "./astify.js"
import * as fs from "../lib/fs.js"
import { type Config } from "./config.js"
import ouroboros from "./ouroboros.js"

/** the module the Elm codegen emits when one or more schemas can't be fully generated */
const ERROR_MODULE_NAME = "AaaaaaaaaErrors"

/** belt-and-suspenders: a generated error module means some schema fell through to a
 * `Debug.todo` placeholder. Surface that as a hard failure so it can never pass silently. */
const assertNoErrorModule = async (errorModulePath: string, label: string): Promise<void> => {
  let content: string
  try {
    content = await fs.readFile(errorModulePath)
  } catch {
    // no error module on disk -> nothing fell through
    return
  }

  throw new Error(
    `Codegen emitted an error module for section "${label}" (${errorModulePath}).\n` +
      `One or more schemas could not be fully generated:\n\n${content}`
  )
}

/** a `Config` describes all of the program's executions; `RunProps` describes a single execution of the program

  a `Config` becomes many `RunProps`es
 */
export const runProps = z.object({
  label: z.string(),
  inputPath: z.string(),
  outputModuleNamespace: z.array(z.string()),
  elmCodegenConfig: ElmCodegen.config,
  debugZodAstOutputPath: z.string(),
})
export type RunProps = z.infer<typeof runProps>

export const run = async ({
  label,
  inputPath,
  elmCodegenConfig,
  debugZodAstOutputPath,
  outputModuleNamespace,
}: RunProps): Promise<void> => {
  const namespaceOutdir = path.join(elmCodegenConfig.outdir, ...outputModuleNamespace)
  const errorModulePath = path.join(namespaceOutdir, `${ERROR_MODULE_NAME}.elm`)

  console.log(`section: ${label}\ninput: ${inputPath}`)

  const decls = await Astify.execute(inputPath)

  if (elmCodegenConfig.debug) {
    await fs.writeFileUtf8(debugZodAstOutputPath, JSON.stringify(decls, null, 2), {
      overwrite: true,
      mkdirP: true,
    })
  }

  // wipe this section's output dir first so deleted schemas don't leave stale modules (and the
  // post-run check only sees this run's output)
  await fs.rm(namespaceOutdir, { recursive: true, force: true })
  await ElmCodegen.execute(elmCodegenConfig)({ outputModuleNamespace, decls })
  await assertNoErrorModule(errorModulePath, label)
}

/** flatten a `Config` into one `RunProps` per (section × input path). pure — no IO.
 * `root` is resolved to an absolute path here so inputs resolve the same regardless
 * of the caller's cwd; outputs (per-section `relativeOutdir`) stay relative to the
 * launch dir, which is how callers land generated code wherever they want. */
export const toRunPropsEntries = ({
  root,
  elmCodegenConfig: globalElmCodegenConfig,
  sections,
  workdirPath,
}: Config): RunProps[] => {
  const absoluteRoot = path.resolve(root)

  const fromSection = ([
    label,
    {
      relativeInputPaths,
      relativeOutdir,
      cleanFirst,
      debug,
      elmCodegenOverrides,
      outputModuleNamespace,
    },
  ]: [string, Config["sections"][number]]): RunProps[] => {
    const elmCodegenConfig: ElmCodegen.Config = {
      ...globalElmCodegenConfig,
      outdir: relativeOutdir,
      ...(cleanFirst === undefined ? {} : { cleanFirst }),
      ...(debug === undefined ? {} : { debug }),
      ...{ ...elmCodegenOverrides },
    }

    return relativeInputPaths.map((rip) => {
      const inputPath = path.join(absoluteRoot, rip)
      const relativeWithoutExt = rip.replace(/\.[^.]+$/, "")
      const debugZodAstOutputPath = path.join(workdirPath, `${relativeWithoutExt}.json`)

      return {
        label,
        inputPath,
        outputModuleNamespace: outputModuleNamespace ?? [],
        elmCodegenConfig,
        debugZodAstOutputPath,
      }
    })
  }

  return Array.from(Object.entries(sections)).flatMap(fromSection)
}

/** run every section of one config concurrently, collecting ALL failures (so one
 * bad section doesn't hide the others). throws an `AggregateError` if any failed. */
const runEntries = async (entries: RunProps[]): Promise<void> => {
  const outcomes = await Promise.allSettled(entries.map(run))
  const failures = outcomes.flatMap((o) => (o.status === "rejected" ? [o.reason] : []))
  if (failures.length > 0) {
    throw new AggregateError(failures, `typewriter: ${failures.length} section(s) failed`)
  }
}

/** the full pipeline. ouroboros (typewriter generating its OWN Elm bindings) ALWAYS
 * runs first, to completion — the generator compiles against those bindings, so a
 * caller config must never race it — then each passed-in config runs in order.
 * throws an `AggregateError` on any section failure; the CLI (index.ts) turns that
 * into a non-zero exit. */
export const runAll = async (...configs: Config[]): Promise<void> => {
  for (const config of [ouroboros, ...configs]) {
    await runEntries(toRunPropsEntries(config))
  }
}
