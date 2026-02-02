import * as ElmCodegen from "../lib/elmCodegen.js"
import z from "zod"
import { ResultAsync, okAsync } from "neverthrow"
import * as Astify from "./astify.js"
import { doAsync } from "../lib/neverthrow/ext.js"
import * as fs from "../lib/fs.js"

/** a `Config` describes all of the program's executions; `RunProps` describes a single execution of the program

  a `Config` becomes many `RunProps`es
 */
export const runProps = z.object({
  label: z.string(),
  inputPath: z.string(),
  elmCodegenConfig: ElmCodegen.config,
  debugZodAstOutputPath: z.string(),
})
export type RunProps = z.infer<typeof runProps>

export const run = ({
  label,
  inputPath,
  elmCodegenConfig,
  debugZodAstOutputPath,
}: RunProps): ResultAsync<void, unknown> =>
  doAsync(() => {
    console.log(`section: ${label}\ninput: ${inputPath}`)
  })
    .andThen(() => Astify.execute(inputPath))
    .andThrough((zodDecls) =>
      elmCodegenConfig.debug
        ? fs.writeFile(debugZodAstOutputPath, JSON.stringify(zodDecls, null, 2))
        : okAsync(undefined)
    )
    .andThen(ElmCodegen.execute(elmCodegenConfig))
