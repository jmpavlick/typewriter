import z from "zod"
import * as path from "path"
import { fileURLToPath } from "url"
import * as ElmCodegen from "../lib/elmCodegen.js"

// typewriter's own Elm generator project (codegen/) lives beside this package,
// independent of the caller's `root`. derive it from this module's location so
// external configs — which root their *inputs* elsewhere (e.g. another repo's
// schemas) — still find the generator. `src/config.ts` → `..` is the package root.
export const packageRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")

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
    cwd: path.join(packageRoot, "codegen"),
    generatorModulePath: "GenerateZodBindings.elm",
    outdir: "generated",
  }

  return {
    root,
    workdirPath,
    relativeGlobalPrepareScriptPath,
    sections,
    elmCodegenConfig,
  }
}
