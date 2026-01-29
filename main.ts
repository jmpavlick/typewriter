import "../lib/serializeErrorPrototype.js"
import stringify from "safe-stable-stringify"
import stringifyOrElse from "./lib/stringifyOrElse.js"
import { type ResultAsync, okAsync, errAsync, fromPromise, Result } from "neverthrow"
import dedent from "dedent"
import z from "zod"
import zx from "./lib/zod/ext.js"
import { ternary } from "./lib/neverthrow/ext.js"

// eventually, make this stuff configurable
const WORKDIR = "./.typewriter"

const zodDeclSchema = z.record(
  z.string(),
  z.custom<z.ZodType>((v) => v instanceof z.ZodType, { error: "Value must be a Zod schema" })
)

// ResultAsync<Record<string, z.ZodType>, string>
const toZodSchemas = (module: unknown): ResultAsync<Record<string, z.ZodType>, unknown> =>
  ternary((m) => typeof m === "object" && m !== null)
    .whenFalse(errAsync(`Dynamic import failed; module contains no exports`))(module)
    .andThen(zx.parseResultAsync(zodDeclSchema))

// (typeof module === "object" && module !== null
//   ? okAsync<object, string>(module)
//   : errAsync(`Imported module did not contain any exports`)
// )
// .map((module) => {
//   const decls: [string, z.ZodType][] = Object.entries(module).filter(
//     ([_, value]) => value instanceof z.ZodType
//   )

//   return decls
// })

// const read = (filepath: string): ResultAsync<string, string> =>
//   fromPromise(
//     import(filepath),
//     (e) => `Failed to import from filepath: ${filepath}:\n\n{stringify(e)}`
//   ).andThen(toZodSchemas)

// const writeElmCodegenInput = async (data: unknown) => {}
