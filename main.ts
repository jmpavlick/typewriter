import "./lib/serializeErrorPrototype.js"
import stringify from "safe-stable-stringify"
import { type ResultAsync, okAsync, errAsync, fromPromise, Result, ok } from "neverthrow"
import zx from "./lib/zod/ext.js"
import { ternary } from "./lib/neverthrow/ext.js"
import * as fs from "fs"
import * as path from "path"
import {
  type Input,
  type ElmCodegenConfig,
  type ElmCodegenParams,
  type ConfigParams,
  type Config,
  type ZodDecls,
  configParamsSchema,
  zodDeclsSchema,
} from "./src/schema.js"
import configParams from "./src/ouroboros.js"

export { configParamsSchema, type ConfigParams, type Config } from "./src/schema.js"

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
  relativeInputPaths,
  elmCodegenParams,
  cleanFirst,
}: ConfigParams): Config => {
  const inputs = relativeInputPaths.map(toInput(root))
  return {
    workdirPath: toWorkdirPath(root),
    inputs,
    elmCodegenConfig: toElmCodegenConfig(elmCodegenParams)(root),
    cleanFirst,
  }
}

// Config resolution: check for .typewriter/config.json, fallback to ouroboros config
const getConfig = (): ResultAsync<Config, unknown> => {
  const ouroborosConfig = toConfig(configParams)
  const configJsonPath = path.join(ouroborosConfig.workdirPath, "config.json")

  return fromPromise(fs.promises.readFile(configJsonPath, "utf-8"), () => "config.json not found")
    .andThen((content) => Result.fromThrowable(() => JSON.parse(content))())
    .andThen(zx.parseResultAsync(configParamsSchema))
    .orElse(() => okAsync(configParams))
    .map(toConfig)
}

// read the input file as a module and do cursed shit to make it into a typed serialized object
const read = (filepath: string): ResultAsync<Record<string, unknown>, unknown> =>
  fromPromise(import(filepath), (e) => `Failed to import from filepath: ${e}`).andThen(
    Result.fromThrowable((m) => Object.fromEntries(Object.entries(m)))
  )

// transform the module-object to zod schemas
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
  (config: Config, inputRel: string) =>
  ({ decls }: { decls: ZodDecls }): ResultAsync<void, unknown> =>
    okAsync()
      .andThen(
        Result.fromThrowable(() =>
          fs.writeFileSync(
            path.join(config.workdirPath, `${inputRel}.json`),
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
const runSingle = (config: Config, input: Input) =>
  read(input.path)
    .andThen(toZodSchemas)
    .map(toElmCodegenInput(input.rel))
    .andThrough(debugWriteElmCodegenInput(config, input.rel))
    .andThen(toElmCodegenExec(config.elmCodegenConfig, config.cleanFirst))

const run = (config: Config): ResultAsync<void[], unknown> =>
  okAsync(config.inputs).andThen((inputs) =>
    fromPromise(
      Promise.all(
        inputs.map((input) =>
          runSingle(config, input).match(
            (ok) => ok,
            (err) => Promise.reject(err)
          )
        )
      ),
      (e) => e
    )
  )

// for dev testing, just do it
getConfig()
  .andThen(run)
  .andTee(() => {
    console.log("OK")
  })
  .orTee((output) => {
    console.error(stringify(output, null, 2))
    console.error()
    console.error("ERR")
  })
