import * as ElmCodegen from "../lib/elmCodegen.js"
import z from "zod"
import path from "path"
import { execFile } from "child_process"
import { promisify } from "util"
import * as Astify from "./astify.js"
import * as fs from "../lib/fs.js"
import { type Config } from "./config.js"

/**
 * Astify hands back live Zod schema instances. Consumers may decorate those instances
 * with non-structural metadata (e.g. a back-reference to a parent object) that forms a
 * cycle — which makes both our debug dump and elm-codegen's flag serialization throw.
 * Flatten to a plain, acyclic value: drop a node only when it reappears on its OWN path
 * (a genuine cycle), never when it's merely shared (a DAG), so every structural field the
 * Elm decoder reads is preserved. The decoder ignores the surviving decoration fields.
 */
export const toSerializable = (decls: unknown): unknown => {
  const ancestors: { holder: unknown; value: object }[] = []
  return JSON.parse(
    JSON.stringify(decls, function (this: unknown, _key: string, value: unknown) {
      if (value !== null && typeof value === "object") {
        // unwind ancestors that aren't the current holder, then detect a back-edge
        while (ancestors.length > 0 && ancestors[ancestors.length - 1].value !== this) {
          ancestors.pop()
        }
        if (ancestors.some((a) => a.value === value)) return undefined
        ancestors.push({ holder: this, value: value as object })

        // `z.partialRecord` serializes identically to `z.record` — zod keeps partiality only in
        // the keyType's internal `_zod.values` (a Set on the exhaustive record, undefined on the
        // partial one), which stringify never emits. Stamp it onto the def IN PLACE (a copy would
        // break the ancestor identities the cycle guard relies on) so the Elm decoder can see it.
        const def = value as Record<string, unknown>
        if (
          def.type === "record" &&
          def.keyType instanceof z.ZodType &&
          def.keyType.def.type === "enum" &&
          def.keyType._zod.values === undefined
        ) {
          def.partial = true
        }
      }
      return value
    }),
  )
}

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

/** a module path segment as Builder.elm names it (`String.Extra.camelize >> toTitleCase`), so the
 * TS side can know every generated module's path ahead of the run */
export const toElmModuleSegment = (s: string): string =>
  s
    .trim()
    .replace(/[-_\s]+(.)?/g, (_, c?: string) => (c ?? "").toUpperCase())
    .replace(/^[a-z]/, (c) => c.toUpperCase())

/** elm-codegen swallows generator compile failures (logs, then resolves), and the section's output
 * dir was wiped before the run — so a failed generation silently deletes the output. every decl
 * yields either its own module or an entry in the error module (checked first), so each decl's
 * module must exist on disk. */
const assertModulesGenerated = async (modulePaths: string[], label: string): Promise<void> => {
  const missing = (
    await Promise.all(modulePaths.map(async (p) => ((await fs.exists(p)) ? [] : [p])))
  ).flat()
  if (missing.length > 0) {
    throw new Error(
      `Codegen did not generate ${missing.length} module(s) for section "${label}":\n\n` +
        missing.map((p) => `    - ${p}`).join("\n")
    )
  }
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
  const modulePaths = Object.keys(decls).map(
    (name) =>
      path.join(
        elmCodegenConfig.outdir,
        ...[...outputModuleNamespace, name].map(toElmModuleSegment)
      ) + ".elm"
  )
  // flatten the live Zod instances to a plain, acyclic value: elm-codegen serializes the
  // flags it hands to the Elm generator, and consumer-attached cyclic decorations (e.g.
  // shepherd's `.topic`) would otherwise make that throw. the Elm decoder reads only the
  // structural fields, all of which survive this.
  const serializableDecls = toSerializable(decls)

  if (elmCodegenConfig.debug) {
    await fs.writeFileUtf8(debugZodAstOutputPath, JSON.stringify(serializableDecls, null, 2), {
      overwrite: true,
      mkdirP: true,
    })
  }

  // wipe this section's output dir first so deleted schemas don't leave stale modules (and the
  // post-run check only sees this run's output)
  await fs.rm(namespaceOutdir, { recursive: true, force: true })
  await ElmCodegen.execute(elmCodegenConfig)({ outputModuleNamespace, decls: serializableDecls })
  await assertNoErrorModule(errorModulePath, label)
  await assertModulesGenerated(modulePaths, label)
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

/** best-effort `elm-format --yes` over the generated output dirs: any failure (including a
 * missing `elm-format`) only warns — the output is valid Elm either way. */
const elmFormat = async (entries: RunProps[]): Promise<void> => {
  const outdirs = [...new Set(entries.map((e) => e.elmCodegenConfig.outdir))]
  if (outdirs.length === 0) return
  try {
    await promisify(execFile)("elm-format", ["--yes", ...outdirs])
  } catch (e) {
    console.warn(
      (e as NodeJS.ErrnoException).code === "ENOENT"
        ? "typewriter: elm-format not found in $PATH; skipping formatting"
        : `typewriter: elm-format failed; output left unformatted\n${e}`
    )
  }
}

/** the full pipeline: each passed-in config runs in order, to completion. the
 * generator compiles against typewriter's OWN Elm bindings (platformWorkerConfig/,
 * generated/) — those are regenerated by the ouroboros config, which the CLI
 * (index.ts) passes explicitly; library callers get the source-controlled bindings
 * as-committed, so a consumer run never writes inside the typewriter package
 * (which would retrigger any file-watcher-driven build graph — e.g. turbo watch).
 * throws an `AggregateError` on any section failure; the CLI turns that into a
 * non-zero exit. */
export const runAll = async (...configs: Config[]): Promise<void> => {
  for (const config of configs) {
    const entries = toRunPropsEntries(config)
    await runEntries(entries)
    await elmFormat(entries)
  }
}
