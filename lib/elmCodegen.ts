import z from "zod"
import { Result, okAsync, fromPromise, ResultAsync } from "neverthrow"
import * as ElmCodegenCore from "elm-codegen"
import * as path from "path"
import * as fs from "./fs.js"
import { doAsync } from "./neverthrow/ext.js"
import { exec } from "child_process"
import { promisify } from "util"

const execAsync = promisify(exec)

export const init: ResultAsync<void, unknown> = fromPromise(
  execAsync("npx elm-codegen init"),
  (e) => e
).map(() => {})

export const install: ResultAsync<void, unknown> = fromPromise(
  execAsync("npx elm-codegen install"),
  (e) => e
).map(() => {})

export const config = z.object({
  cleanFirst: z.boolean(),
  cwd: z.string(),
  generatorModulePath: z.string(),
  outdir: z.string(),
  debug: z.boolean(),
})
export type Config = z.infer<typeof config>

export const execute =
  ({ cleanFirst, cwd, generatorModulePath, outdir, debug }: Config) =>
  (jsonInput: unknown) => {
    const cleanIO: ResultAsync<void, unknown> = fs.rm(path.join(outdir, "*.elm"), {
      recursive: true,
      force: true,
    })

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
