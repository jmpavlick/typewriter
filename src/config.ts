import * as path from "path"
import { fileURLToPath } from "url"
import * as ElmCodegen from "../lib/elmCodegen.js"

// typewriter's own Elm generator project (codegen/) lives beside this package,
// independent of the caller's `root`. derive it from this module's location so
// external configs — which root their *inputs* elsewhere (e.g. another repo's
// schemas) — still find the generator. `src/config.ts` → `..` is the package root.
export const packageRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")

/** reference another config's generated modules instead of regenerating them: each named export
 * of `from` (its module name, e.g. `Locale`) whose structure matches a nested type in this section
 * is referenced as `Locale.Value` — imported, not hoisted. only types typewriter hoists can match:
 * enums/literal unions, discriminated unions, and enum-keyed records' value types. */
export type ConfigImport = {
  from: Config
  names: string[]
}

/** one section: generate every zod export of each input file into `relativeOutdir`, under
 * `outputModuleNamespace` */
export type ConfigSection = {
  relativeInputPaths: string[]
  relativeOutdir: string
  outputModuleNamespace?: string[]
  imports?: ConfigImport[]
  elmCodegenOverrides?: Partial<Pick<ElmCodegen.Config, "generatorModulePath" | "debug">>
}

/** what a caller writes; `toConfig` fills in the rest */
export type ConfigParams = {
  root?: string
  sections: Record<string, ConfigSection>
}

export type Config = Required<ConfigParams> & {
  workdirPath: string
  elmCodegenConfig: ElmCodegen.Config
}

export const toConfig = ({ root = ".", sections }: ConfigParams): Config => ({
  root,
  workdirPath: path.join(root, ".typewriter"),
  sections,
  elmCodegenConfig: {
    // elm-codegen's `debug: false` compiles the generator with --optimize, which rejects the
    // generator's `Debug.log`s — so the generator only builds in debug mode
    debug: true,
    cwd: path.join(packageRoot, "codegen"),
    generatorModulePath: "GenerateZodBindings.elm",
    outdir: "generated",
  },
})
