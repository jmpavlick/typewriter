import z from "zod"

// every nested type here is written out fresh (no shared zod instances) — imports match on
// structure, not identity
export const importingPage = z.object({
  locale: z.enum(["en-US", "fr-CA"]),
  // same members, different order: still the same structural key
  alternates: z.array(z.object({ locale: z.enum(["fr-CA", "en-US"]), url_slug: z.string() })),
  channel: z.discriminatedUnion("kind", [
    z.object({ kind: z.literal("email"), to: z.string() }),
    z.object({ kind: z.literal("sms"), phone: z.string() }),
  ]),
  slots: z.record(z.enum(["closet", "parking"]), z.object({ priority: z.int(), label: z.string() })),
  other: z.enum(["x", "y"]),
})
