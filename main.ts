import "./lib/serializeErrorPrototype.js"
import stringify from "safe-stable-stringify"
import stringifyOrElse from "./lib/stringifyOrElse.js"
import { type ResultAsync, okAsync, errAsync, fromPromise, Result, ok } from "neverthrow"
import dedent from "dedent"
import z from "zod"
import zx from "./lib/zod/ext.js"
import { ternary } from "./lib/neverthrow/ext.js"
import * as fs from "fs"
import * as path from "path"
import * as ElmCodegen from "elm-codegen"

// Schemas
const inputSchema = z.object({
  path: z.string(),
  rel: z.string(),
})

const elmCodegenConfigSchema = z.object({
  cwd: z.string(),
  generatorModulePath: z.string(),
  outdir: z.string(),
  debug: z.boolean(),
})

const elmCodegenParamsSchema = z.object({
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

const configSchema = z.object({
  workdirPath: z.string(),
  input: inputSchema,
  elmCodegenConfig: elmCodegenConfigSchema,
  cleanFirst: z.boolean(),
})

// Types
type Input = z.infer<typeof inputSchema>
type ElmCodegenConfig = z.infer<typeof elmCodegenConfigSchema>
type ElmCodegenParams = z.infer<typeof elmCodegenParamsSchema>
export type ConfigParams = z.infer<typeof configParamsSchema>
export type Config = z.infer<typeof configSchema>

// Constructors
const toWorkdirPath = (root: string): string => path.join(root, ".typewriter")

const toInput =
  (root: string) =>
  (relInputPath: string): Input => ({
    path: path.resolve(root, relInputPath),
    rel: relInputPath,
  })

const toElmCodegenConfig =
  ({ relativeGeneratorModulePath, relativeOutdir, debug }: ElmCodegenParams) =>
  (root: string): ElmCodegenConfig => ({
    cwd: root,
    generatorModulePath: relativeGeneratorModulePath,
    outdir: relativeOutdir,
    debug,
  })

const toConfig = ({
  root,
  relativeInputPath,
  elmCodegenParams,
  cleanFirst,
}: ConfigParams): Config => {
  const input = toInput(root)(relativeInputPath)
  return {
    workdirPath: toWorkdirPath(root),
    input,
    elmCodegenConfig: toElmCodegenConfig(elmCodegenParams)(root),
    cleanFirst,
  }
}

const config = toConfig({
  root: ".",
  relativeInputPath: "tests/schemaVariants.ts",
  elmCodegenParams: {
    relativeGeneratorModulePath: "codegen/GenerateZodBindings.elm",
    relativeOutdir: "./generated",
    debug: true,
  },
  cleanFirst: true,
})

// read the input file as a module and do cursed shit to make it more objectionable
// (pun intended)
const read = (filepath: string): ResultAsync<Record<string, unknown>, unknown> =>
  fromPromise(import(filepath), (e) => `Failed to import from filepath: ${e}`).andThen(
    Result.fromThrowable((m) => Object.fromEntries(Object.entries(m)))
  )

// transform the module-object to zod schemas
const zodDeclsSchema = z.record(
  z.string(),
  z.custom<z.ZodType>((v) => v instanceof z.ZodType, { error: "Value must be a Zod schema" })
)

type ZodDecls = z.infer<typeof zodDeclsSchema>

const toZodSchemas = (module: unknown): ResultAsync<ZodDecls, unknown> =>
  ternary((m) => typeof m === "object" && m !== null)
    .whenFalse(errAsync(`Dynamic import failed; module contains no exports`))(module)
    .andThen(zx.parseResultAsync(zodDeclsSchema))

// turn it in to input for elm-codegen
const toElmCodegenInput =
  (relativeInputPath: string) =>
  (zsd: ZodDecls): { outputModulePath: string[]; decls: ZodDecls } => {
    const outputModulePath = relativeInputPath
      .split(".")[0]
      .split("/")
      .map((chunk) => {
        const [c, ...hunk] = chunk

        return `${c.toUpperCase()}${hunk.join("")}`
      })

    return { outputModulePath, decls: zsd }
  }

const debugWriteElmCodegenInput =
  (config: Config) =>
  ({ decls }: { decls: ZodDecls }): ResultAsync<void, unknown> =>
    okAsync()
      .andThen(
        Result.fromThrowable(() =>
          fs.writeFileSync(
            path.join(config.workdirPath, `${config.input.rel}.json`),
            JSON.stringify(decls, null, 2)
          )
        )
      )
      .map(() => {})

// run elm-codegen
const toElmCodegenExec =
  ({ debug, cwd, generatorModulePath, outdir }: ElmCodegenConfig, cleanFirst: boolean) =>
  (input: { outputModulePath: string[]; decls: ZodDecls }): ResultAsync<void, unknown> =>
    okAsync()
      .andThrough(() => {
        if (cleanFirst) {
          return okAsync().andThen(
            Result.fromThrowable(() =>
              fs.rmSync(path.join(outdir, "*.elm"), { recursive: true, force: true })
            )
          )
        }

        return okAsync()
      })
      .andThrough(Result.fromThrowable(() => fs.mkdirSync(outdir, { recursive: true })))
      .andThen(() =>
        fromPromise(
          ElmCodegen.run(generatorModulePath, {
            debug,
            output: outdir,
            flags: input as unknown as any,
            cwd,
          }),
          (e) => e
        )
      )

// the chain that fleetwood mac said they'd never break
const run = (config: Config) =>
  read(config.input.path)
    .andThen(toZodSchemas)
    .map(toElmCodegenInput(config.input.rel))
    .andThrough(debugWriteElmCodegenInput(config))
    .andThen(toElmCodegenExec(config.elmCodegenConfig, config.cleanFirst))

// for dev testing, just do it
run(config)
  .andTee((output) => {
    console.log("OK")
  })
  .orTee((output) => {
    console.error(stringify(output, null, 2))
    console.error()
    console.error("ERR")
  })
