import zx from "../lib/zod/ext.js"
import z from "zod"
import { ResultAsync, okAsync, errAsync, Result } from "neverthrow"
import path from "path"

// Schema for validating that imported module exports are zod schemas
export const zodDecls = z.record(z.string(), z.instanceof(z.ZodType))
export type ZodDecls = z.infer<typeof zodDecls>

// Read a module and extract its exports as a plain object
const readModule = (filepath: string): ResultAsync<Record<string, unknown>, unknown> =>
  ResultAsync.fromPromise(import(filepath), (e) => `Failed to import from filepath: ${e}`).andThen(
    Result.fromThrowable((m) =>
      Object.fromEntries(
        Object.entries(m).filter(([, obj]) => {
          return obj instanceof z.ZodType
        })
      )
    )
  )

// Transform the module-object to zod schemas
const toZodSchemas = (module: unknown): ResultAsync<ZodDecls, unknown> => {
  if (typeof module !== "object" || module === null) {
    return errAsync(`Dynamic import failed; module contains no exports`)
  }
  return zx.parseResultAsync(zodDecls)(module)
}

export const execute = (inputPath: string): ResultAsync<ZodDecls, unknown> =>
  readModule(inputPath).andThen(toZodSchemas)
