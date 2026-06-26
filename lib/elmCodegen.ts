import z from "zod"
import * as ElmCodegenCore from "elm-codegen"

export const config = z.object({
  cleanFirst: z.boolean(),
  cwd: z.string(),
  generatorModulePath: z.string(),
  outdir: z.string(),
  debug: z.boolean(),
})
export type Config = z.infer<typeof config>

export const execute =
  ({ cwd, generatorModulePath, outdir, debug }: Config) =>
  (jsonInput: unknown): Promise<void> =>
    ElmCodegenCore.run(generatorModulePath, {
      debug,
      output: outdir,
      flags: jsonInput,
      cwd,
    })
