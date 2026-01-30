import z from "zod"

const inputConfigSchema = z.object({})

const outputConfigSchema = z.object({
  dir: z.string().describe("file path for output, relative to the `workingDir` option"),
  mkdirP: z.boolean().describe("create the directory path for `outputDir` if it does not exist"),
  cleanOnGenerate: z
    .boolean()
    .describe("clean the output directory before `typewriter` generates output"),
})

export const configSchema = z.object({
  workingDir: z
    .union([
      z.literal("here"),
      z.literal("root"),
      z.string().describe("file path relative to the configuration file"),
    ])
    .describe("working directory for `typewriter` execution"),
  input: inputConfigSchema,
  output: outputConfigSchema,
})

const nx = (b: boolean) => configSchema.omit({ workingDir: b ? true : undefined }) //.omit({ workingDir: true })

const nxx = nx(true)

type A = z.infer<typeof nxx>

type Config = z.infer<typeof configSchema>
