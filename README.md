# typewriter

Generates Elm types and decoders from [Zod](https://zod.dev) schemas.

Point it at a `.ts` file that exports Zod schemas, run it, and get a directory of Elm modules —
one per exported schema, each with a `Value` type and a `Json.Decode.Decoder Value`.

## How to hold it

### Prerequisites

- Node + [pnpm](https://pnpm.io)
- Elm 0.19.1 (installed via the `elm` dev dependency / `elm-tooling`)

```
pnpm install
```

### Configure

There's no config file to drop in — the configuration lives in code, in [`src/ouroboros.ts`](src/ouroboros.ts).
It defines a set of **sections**; each section reads one or more `.ts` files and writes Elm into an
output directory under a module namespace:

```ts
const configParams: ConfigParams = {
  root: ".",
  sections: {
    // generate from the example corpus into ./generated/IntegrationTests/*
    tests: {
      relativeInputPaths: ["tests/schemaVariants.ts"],
      relativeOutdir: "generated",
      outputModuleNamespace: ["IntegrationTests"],
      cleanFirst: true,
      debug: true,
    },
    // add your own:
    myApp: {
      relativeInputPaths: ["../shepherd/packages/whatever/schemas.ts"],
      relativeOutdir: "../shepherd/.../generated",
      outputModuleNamespace: ["Api", "Generated"],
    },
  },
}
```

Per-section options:

| field | meaning |
|-------|---------|
| `relativeInputPaths` | `.ts` files (relative to `root`) whose exported Zod schemas get generated |
| `relativeOutdir` | where the Elm files are written |
| `outputModuleNamespace` | module-name prefix, e.g. `["Api", "Generated"]` → `module Api.Generated.User` |
| `cleanFirst` / `debug` | optional; `debug` dumps the intermediate Zod AST as JSON under `.typewriter/` |

The input file just needs to `export` Zod schemas — anything that's a `ZodType` is picked up;
everything else is ignored.

### Generate

```
pnpm generate
```

Each run wipes and rewrites each section's output directory, so deleting a schema removes its
module too. Output for one schema looks like:

```elm
-- export const user = z.object({ id: z.string(), role: z.enum(["admin", "user"]) })

module Api.Generated.User exposing (..)

type alias Value =
    { id : String, role : Role }

decoder : Json.Decode.Decoder Value
decoder = ...

type Role = RoleAdmin | RoleUser   -- nested unions are hoisted to named types

roleDecoder : Json.Decode.Decoder Role
roleDecoder = ...
```

### The safety net

If any schema uses something not yet supported, codegen writes a placeholder into an
`AaaaaaaaaErrors` module **and the run fails with a non-zero exit** (see `assertNoErrorModule` in
[`src/main.ts`](src/main.ts)) — listing exactly which schemas fell through. Nothing is ever silently
half-generated. So the way to find out whether your schemas are fully supported is to just run it.

## What's supported

Generates a type **and** a working decoder, compiling cleanly:

- All primitives, `optional` / `nullable` / `nullish`, arrays, nested objects
- `z.record` (string-keyed) → `Dict String v`; `z.map` (string-keyed) → `Dict String v`
- `z.set` of a comparable element (`String` / `Int` / `Float`) → `Set elem`
- `z.tuple` of any arity: 2 → `( a, b )`, 3 → `( a, b, c )`, 4+ → right-nested pairs `( a, ( b, ( c, d ) ) )`
- `z.literal` / `z.enum` / `z.union` of literals — string, int, and bool — at the root or nested
  (nested ones are hoisted to named top-level types and deduped by structure)
- `z.nativeEnum` — string and numeric (numeric TS enums become int-valued unions)
- `z.discriminatedUnion` — at the root or nested, with unions inside the payloads also hoisted
- `.default()` / `.catch()` — transparently unwrapped to the inner type
- Object transformers (`.partial()`, `.extend()`, `.pick()`, `.omit()`) — resolve to plain objects

Not supported yet (these fail the run, by design — see the safety net above):

- `z.set` / `z.map` with a non-comparable element / non-string key
- Mixed-wire literal unions (e.g. `z.literal(["a", 1])`)
- `z.union` of non-literal, non-object options, or object unions without a discriminant
- `z.intersection`, `z.lazy` / recursive schemas

## Tests

```
pnpm test          # elm-test (the AST decoder) + a full generate over the example corpus
pnpm test:watch    # both, in watch mode
```

`tests/schemaVariants.ts` is the example corpus and the integration-test fixture: `pnpm test`
regenerates it and fails if anything lands in the error module, so it doubles as a regression guard
for the supported-construct list above.

## Layout

| path | what |
|------|------|
| `index.ts` | entry point — builds run-props from the config and runs each section |
| `src/ouroboros.ts` | **the config** — sections, input/output paths |
| `src/astify.ts` | loads a `.ts` module and extracts its Zod schemas |
| `src/Ast.elm` | the typed AST + its JSON decoder (the Zod wire format → `Ast.Value`) |
| `src/Builder.elm` | `Ast.Value` → Elm type + decoder, via [elm-codegen](https://github.com/mdgriffith/elm-codegen) |
| `codegen/GenerateZodBindings.elm` | the elm-codegen entry that drives `Builder` |
| `tests/schemaVariants.ts` | example corpus / integration fixture |
