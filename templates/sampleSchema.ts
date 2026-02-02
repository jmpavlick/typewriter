import z from "zod"

export const user = z.object({
  name: z.string(),
  birthday: z.iso.date(),
  pets: z
    .array(
      z.object({
        name: z.string(),
        breed: z.string().nullable(),
      })
    )
    .optional(),
})
