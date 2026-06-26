import * as ElmCodegen from "../lib/elmCodegen.js"
import z from "zod"
import path from "path"
import * as Astify from "./astify.js"
import * as fs from "../lib/fs.js"

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
