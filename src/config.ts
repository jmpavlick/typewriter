import z from "zod"
import * as path from "path"
import * as ElmCodegen from "../lib/elmCodegen.js"

/** this defines a single configuration section; at least one is required for the program to do anything meaningful
 */
const configParamsSection = z.object({
  relativeInputPaths: z.array(z.string()),
  relativeOutdir: z.string(),
  outputModuleNamespace: z.array(z.string()).optional(),
  relativePrepareScriptPath: z.string().optional(),
  ...ElmCodegen.config
    .pick({
      cleanFirst: true,
      debug: true,
    })
    .partial().shape,
  elmCodegenOverrides: ElmCodegen.config.pick({ generatorModulePath: true }).partial().optional(),
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
  workdirPath: z.string(),
  ...configParams.required({ root: true }).shape,
  elmCodegenConfig: ElmCodegen.config,
  baseConfigMd5Path: z.string(),
  userConfigParamsPath: z.string(),
})
export type Config = z.infer<typeof config>

export const toConfig = ({
  root: maybeRoot,
  relativeGlobalPrepareScriptPath,
  sections,
}: ConfigParams): Config => {
  const root = maybeRoot ?? "."
  const workdirPath = path.join(root, ".typewriter")

  const elmCodegenConfig: ElmCodegen.Config = {
    cleanFirst: false,
    debug: false,
    cwd: path.join(root, "codegen"),
    generatorModulePath: "GenerateZodBindings.elm",
    outdir: "generated",
  }

  return {
    root,
    workdirPath,
    relativeGlobalPrepareScriptPath,
    sections,
    elmCodegenConfig,
    baseConfigMd5Path: path.join(workdirPath, "baseConfig.md5"),
    userConfigParamsPath: path.join(workdirPath, "configParams.json"),
  }
}
