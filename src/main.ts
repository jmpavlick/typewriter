import * as ElmCodegen from "../lib/elmCodegen.js"
import z from "zod"
import { ResultAsync, okAsync, errAsync } from "neverthrow"
import path from "path"
import * as Astify from "./astify.js"
import { doAsync } from "../lib/neverthrow/ext.js"
import * as fs from "../lib/fs.js"

/** the module the Elm codegen emits when one or more schemas can't be fully generated */
const ERROR_MODULE_NAME = "AaaaaaaaaErrors"

/** belt-and-suspenders: a generated error module means some schema fell through to a
 * `Debug.todo` placeholder. Surface that as a hard failure so it can never pass silently. */
const assertNoErrorModule = (
  errorModulePath: string,
  label: string
): ResultAsync<void, unknown> =>
  fs
    .readFile(errorModulePath)
    .map((content) => ({ emitted: true, content }))
    .orElse(() => okAsync({ emitted: false, content: "" }))
    .andThen(({ emitted, content }) =>
      emitted
        ? errAsync(
            `Codegen emitted an error module for section "${label}" (${errorModulePath}).\n` +
              `One or more schemas could not be fully generated:\n\n${content}`
          )
        : okAsync(undefined)
    )

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

export const run = ({
  label,
  inputPath: inputPath,
  elmCodegenConfig,
  debugZodAstOutputPath,
  outputModuleNamespace,
}: RunProps): ResultAsync<void, unknown> => {
  const errorModulePath = path.join(
    elmCodegenConfig.outdir,
    ...outputModuleNamespace,
    `${ERROR_MODULE_NAME}.elm`
  )

  return doAsync(() => {
    console.log(`section: ${label}\ninput: ${inputPath}`)
  })
    .andThen(() => Astify.execute(inputPath))
    .andThrough((zodDecls) =>
      elmCodegenConfig.debug
        ? fs.writeFileUtf8(debugZodAstOutputPath, JSON.stringify(zodDecls, null, 2), {
            overwrite: true,
            mkdirP: true,
          })
        : okAsync(undefined)
    )
    .map((decls) => ({ outputModuleNamespace, decls }))
    // clear any stale error module first, so the post-run check only sees this run's output
    // (cleanFirst only globs the top of outdir, not nested namespace dirs)
    .andThrough(() => fs.rm(errorModulePath, { force: true }))
    .andThen(ElmCodegen.execute(elmCodegenConfig))
    .andThen(() => assertNoErrorModule(errorModulePath, label))
}
