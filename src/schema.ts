import z from "zod"

// Schemas
export const inputSchema = z.object({
  path: z.string(),
  rel: z.string(),
})

export const elmCodegenConfigSchema = z.object({
  cwd: z.string(),
  generatorModulePath: z.string(),
  outdir: z.string(),
  debug: z.boolean(),
})

export const elmCodegenParamsSchema = z.object({
  relativeGeneratorModulePath: z.string(),
  relativeOutdir: z.string(),
  debug: z.boolean(),
})

export const configParamsSchema = z.object({
  root: z.string(),
  relativeInputPath: z.string(),
  elmCodegenParams: elmCodegenParamsSchema,
  cleanFirst: z.boolean(),
})

export const configSchema = z.object({
  workdirPath: z.string(),
  input: inputSchema,
  elmCodegenConfig: elmCodegenConfigSchema,
  cleanFirst: z.boolean(),
})

export const zodDeclsSchema = z.record(
  z.string(),
  z.custom<z.ZodType>((v) => v instanceof z.ZodType, { error: "Value must be a Zod schema" })
)

// Types
export type Input = z.infer<typeof inputSchema>
export type ElmCodegenConfig = z.infer<typeof elmCodegenConfigSchema>
export type ElmCodegenParams = z.infer<typeof elmCodegenParamsSchema>
export type ConfigParams = z.infer<typeof configParamsSchema>
export type Config = z.infer<typeof configSchema>
export type ZodDecls = z.infer<typeof zodDeclsSchema>
