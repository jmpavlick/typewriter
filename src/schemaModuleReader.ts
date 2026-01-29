import stringify from "safe-stable-stringify"

// this will be set by configuration
const schemaVariants = "../tests/schemaVariants.ts"

export const read = async (filepath: string) => {
  const schemas = await import(filepath)

  const declsStr = stringify(schemas, null, 2)

  if (declsStr === undefined)
    throw new Error(`Failed to import schemas module at filepath: ${filepath}`)

  const declsObj = JSON.parse(declsStr)
}
