import z from "zod"
import * as ElmCodegen from "../lib/elmCodegen.js"

/** this defines a single configuration section; at least one is required for the program to do anything meaningful
 */
const configParamsSection = z.object({
  relativeInputPaths: z.array(z.string()),
  relativeOutdir: z.string(),
  cleanFirst: z.boolean(),
  relativePrepareScriptPath: z.string().optional(),
  elmCodegenOverrides: z
    .object({
      relativeGeneratorModulePath: ElmCodegen.config.shape.generatorModulePath.optional(),
      debug: ElmCodegen.config.shape.debug.optional(),
    })
    .optional(),
})

/** this is the shape of the program's entry point
 */
export const configParams = z.object({
  root: z.optional(z.string()),
  relativeGlobalPrepareScriptPath: z.string().optional(),
  sections: z.record(z.string(), configParamsSection),
})
export type ConfigParams = z.infer<typeof configParams>

export const config = z.object({
  root: z.string(),
  workdirPath: z.string(),
  ...configParams,
})
export type Config = z.infer<typeof config>

export const toConfig = ({}: ConfigParams): Config => {
  throw new Error("todo lol")
}

export const zodDecls = z.record(
  z.string(),
  z.custom<z.ZodType>((v) => v instanceof z.ZodType, { error: "Value must be a Zod " })
)
