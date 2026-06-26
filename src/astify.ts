import z from "zod"

// Schema for validating that imported module exports are zod schemas
export const zodDecls = z.record(z.string(), z.instanceof(z.ZodType))
export type ZodDecls = z.infer<typeof zodDecls>

// Read a module and keep only the exports that are zod schemas
const readModule = async (filepath: string): Promise<Record<string, unknown>> => {
  const module = await import(filepath)

  if (typeof module !== "object" || module === null) {
    throw new Error(`Dynamic import of ${filepath} produced no exports`)
  }

  return Object.fromEntries(
    Object.entries(module).filter(([, value]) => value instanceof z.ZodType)
  )
}

export const execute = async (inputPath: string): Promise<ZodDecls> => {
  const module = await readModule(inputPath)
  const parsed = await zodDecls.safeParseAsync(module)

  if (!parsed.success) {
    throw parsed.error
  }

  return parsed.data
}
