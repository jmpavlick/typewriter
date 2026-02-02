import z from "zod"
import { Result, okAsync, fromPromise, ResultAsync } from "neverthrow"
import * as ElmCodegenCore from "elm-codegen"
import * as fs from "fs"
import * as path from "path"

export const config = z.object({
  cleanFirst: z.boolean(),
  cwd: z.string(),
  generatorModulePath: z.string(),
  outdir: z.string(),
  debug: z.boolean(),
})
export type config = z.infer<typeof config>

const execute =
  ({ cleanFirst, cwd, generatorModulePath, outdir, debug }: config) =>
  (jsonInput: unknown) => {
    const cleanIO: ResultAsync<void, unknown> = okAsync().andThen(
      Result.fromThrowable(() =>
        fs.rmSync(path.join(outdir, "*.elm"), { recursive: true, force: true })
      )
    )

    const elmCodegenIO: ResultAsync<void, unknown> = fromPromise(
      ElmCodegenCore.run(generatorModulePath, {
        debug,
        output: outdir,
        flags: jsonInput,
        cwd,
      }),
      (e) => e
    )

    return (cleanFirst ? cleanIO : okAsync()).andThen(() => elmCodegenIO)
  }
