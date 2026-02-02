import zx from "../lib/zod/ext.js"
import z from "zod"
import { ResultAsync, okAsync, errAsync, Result } from "neverthrow"
import path from "path"

// Schema for validating that imported module exports are zod schemas
export const zodDeclsSchema = z.record(z.string(), z.instanceof(z.ZodType))
export type ZodDecls = z.infer<typeof zodDeclsSchema>

// Read a module and extract its exports as a plain object
const readModule = (filepath: string): ResultAsync<Record<string, unknown>, unknown> =>
  ResultAsync.fromPromise(import(filepath), (e) => `Failed to import from filepath: ${e}`).andThen(
    Result.fromThrowable((m) => Object.fromEntries(Object.entries(m)))
  )

// Transform the module-object to zod schemas
const toZodSchemas = (module: unknown): ResultAsync<ZodDecls, unknown> => {
  if (typeof module !== "object" || module === null) {
    return errAsync(`Dynamic import failed; module contains no exports`)
  }
  return zx.parseResultAsync(zodDeclsSchema)(module)
}

export const execute = (
  root: string,
  relativeInputPath: string
): ResultAsync<{ outputModulePath: string[]; decls: ZodDecls }, unknown> =>
  readModule(path.join(root, relativeInputPath))
    .andThen(toZodSchemas)
    .map((decls) => ({ outputModulePath: relativeInputPath.replace(".ts", "").split("/"), decls }))
