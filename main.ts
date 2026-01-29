import "./lib/serializeErrorPrototype.js"
import stringify from "safe-stable-stringify"
import stringifyOrElse from "./lib/stringifyOrElse.js"
import { type ResultAsync, okAsync, errAsync, fromPromise, Result, ok } from "neverthrow"
import dedent from "dedent"
import z from "zod"
import zx from "./lib/zod/ext.js"
import { ternary } from "./lib/neverthrow/ext.js"
import * as fs from "fs"
import { dirname } from "path"
import * as ElmCodegen from "elm-codegen"
import { relative } from "path/win32"

// eventually, make this stuff configurable
const ROOT = `.`
const WORKDIR = `${ROOT}/.typewriter`
const INPUT = `${ROOT}/tests/schemaVariants.ts`
const OUTFILE_CODEGEN_INPUT = `${WORKDIR}/${INPUT.replace(WORKDIR, "")}.json`

const toWorkdirPath = (root: string) => `${ROOT}/.typewriter`
const toInput = (root: string) => (relInputPath: string) => ({
  path: `${root}/${relInputPath}`,
  rel: relInputPath,
})

const toElmCodegenConfig =
  ({
    relativeGeneratorModulePath,
    relativeOutdir,
    debug,
  }: {
    relativeGeneratorModulePath: string
    relativeOutdir: string
    debug: boolean
  }) =>
  (root: string) => ({
    cwd: root,
    generatorModulePath: relativeGeneratorModulePath,
    outdir: relativeOutdir,
    debug,
  })

type ElmCodegenConfig = ReturnType<ReturnType<typeof toElmCodegenConfig>>
type ElmCodegenParams = Parameters<typeof toElmCodegenConfig>[0]

const toConfig = ({
  root,
  relativeInputPath,
  elmCodegenParams,
  cleanFirst,
}: {
  root: string
  relativeInputPath: string
  elmCodegenParams: ElmCodegenParams
  cleanFirst: boolean
}) => {
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
    relativeGeneratorModulePath: "codegen/Generate.elm",
    relativeOutdir: "./generated",
    debug: true,
  },
  cleanFirst: false,
})

export type Config = ReturnType<typeof toConfig>

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

// run elm-codegen
const toElmCodegenExec =
  ({ debug, cwd, generatorModulePath, outdir }: ElmCodegenConfig, cleanFirst: boolean) =>
  (input: { outputModulePath: string[]; decls: ZodDecls }) =>
    okAsync()
      .andThrough(() => {
        if (cleanFirst) {
          return okAsync().andThen(
            Result.fromThrowable(() => fs.rmSync(outdir, { recursive: true, force: true }))
          )
        }

        return okAsync()
      })
      .andThrough(Result.fromThrowable(() => fs.mkdirSync(outdir, { recursive: true })))
      .andThen(
        Result.fromThrowable(() =>
          ElmCodegen.run(generatorModulePath, {
            debug,
            output: outdir,
            flags: input as unknown as any,
            cwd,
          })
        )
      )

// the chain that fleetwood mac said they'd never break
const run = (config: Config) =>
  read(config.input.path)
    .andThen(toZodSchemas)
    .map(toElmCodegenInput(config.input.rel))
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
