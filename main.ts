import "./lib/serializeErrorPrototype.js"
import stringify from "safe-stable-stringify"
import stringifyOrElse from "./lib/stringifyOrElse.js"
import { type ResultAsync, okAsync, errAsync, fromPromise, Result } from "neverthrow"
import dedent from "dedent"
import z from "zod"
import zx from "./lib/zod/ext.js"
import { ternary } from "./lib/neverthrow/ext.js"
import * as fs from "fs"
import { dirname } from "path"

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

const toOutfileCodegenInput = (root: string) => (input: { rel: string }) =>
  `${toWorkdirPath(root)}/${input.rel}.json`

const toConfig = (root: string, relativeInputPath: string) => {
  const input = toInput(root)(relativeInputPath)
  return {
    workdirPath: toWorkdirPath(root),
    input,
    outfileCodegenInputPath: toOutfileCodegenInput(root)(input),
  }
}

const config = toConfig(".", "tests/schemaVariants.ts")

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
  z.custom<z.ZodType>(
    (v) => {
      // console.log(v)
      return v instanceof z.ZodType
    },
    { error: "Value must be a Zod schema" }
  )
)

type ZodDecls = z.infer<typeof zodDeclsSchema>

const toZodSchemas = (module: unknown): ResultAsync<ZodDecls, unknown> =>
  ternary((m) => typeof m === "object" && m !== null)
    .whenFalse(errAsync(`Dynamic import failed; module contains no exports`))(module)
    .andThen(zx.parseResultAsync(zodDeclsSchema))

// get the girl, put the girl in the barn
// (the american dream)
const toCodgenInputFile = (path: string) => (zds: ZodDecls) =>
  stringifyOrElse(zds, null, 2)
    .andTee((v) => console.log(v))
    .andThrough(() =>
      Result.fromThrowable(() => fs.mkdirSync(dirname(path), { recursive: true }))()
    )
    .andThen(Result.fromThrowable((str) => fs.writeFileSync(path, str)))

// the chain that fleetwood mac said they'd never break
const run = (config: Config) =>
  read(config.input.path)
    .andThen(toZodSchemas)
    .andThen(toCodgenInputFile(config.outfileCodegenInputPath))

// for dev testing, just do it
run(config)
  .andTee((output) => {
    console.log(stringify(output, null, 2))
    console.log()
    console.log("OK")
  })
  .orTee((output) => {
    console.error(stringify(output, null, 2))
    console.error()
    console.error("ERR")
  })
