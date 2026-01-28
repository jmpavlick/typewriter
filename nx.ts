import z from "zod"
import stringify from "safe-stable-stringify"

let objSchemas: Record<string, z.ZodObject> = {}

export const simpleObj = z.object({
  name: z.string(),
  age: z.int(),
  weight: z.number(),
  optStr: z.string().optional(),
  nullableStr: z.string().nullable(),
  nullishStr: z.string().nullish()

})

objSchemas.simpleObj = simpleObj

// Array.from(Object.entries(objSchemas)).forEach(([name, sch]) => {
//   const shape = sch.shape

//   console.log(stringify({ [name]: shape }, null, 2))
// })

const strSch = z.string()

console.log(stringify(simpleObj, null, 2))
// console.log((stringify(simpleObj.shape, null, 2)))
