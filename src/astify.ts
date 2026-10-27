import z from "zod"
import path from "path"

// Schema for validating that imported module exports are zod schemas
export const zodDecls = z.record(z.string(), z.instanceof(z.ZodType))
export type ZodDecls = z.infer<typeof zodDecls>

// Read a module and keep only the exports that are zod schemas, keyed by the module name each
// generates under. a `default` export alongside named ones is an alias of one of them (it would
// generate twice), so it's skipped; a lone `default` is named after its file (`locale.ts` → `locale`)
const readModule = async (filepath: string): Promise<Record<string, unknown>> => {
  const module = await import(filepath)

  if (typeof module !== "object" || module === null) {
    throw new Error(`Dynamic import of ${filepath} produced no exports`)
  }

  const { default: defaultExport, ...named } = Object.fromEntries(
    Object.entries(module).filter(([, value]) => value instanceof z.ZodType)
  )

  return Object.keys(named).length === 0 && defaultExport !== undefined
    ? { [path.basename(filepath, path.extname(filepath))]: defaultExport }
    : named
}

export const execute = async (inputPath: string): Promise<ZodDecls> => {
  const module = await readModule(inputPath)
  const parsed = await zodDecls.safeParseAsync(module)

  if (!parsed.success) {
    throw parsed.error
  }

  return parsed.data
}
