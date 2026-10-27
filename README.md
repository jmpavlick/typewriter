# typewriter

Generates Elm types, decoders, and encoders from [Zod](https://zod.dev) schemas.

Point it at a `.ts` file that exports Zod schemas, run it, and get a directory of Elm modules —
one per exported schema, each with a `Value` type, a `Json.Decode.Decoder Value`, and a matching
`Value -> Json.Encode.Value` encoder, generated so that `decodeValue decoder (encoder v) == Ok v`.

## How to hold it

### Prerequisites

- Node + [pnpm](https://pnpm.io)
- Elm 0.19.1 (installed via the `elm` dev dependency / `elm-tooling`)

```
pnpm install
```

### Configure

Configuration lives in code: build a config with `toConfig` and hand it to `runAll`. A config is a
set of **sections**; each section reads one or more `.ts` files and writes Elm into an output
directory under a module namespace:

```ts
import { toConfig } from "typewriter/src/config"
import { runAll } from "typewriter/src/main"

await runAll(
  toConfig({
    root: ".",
    sections: {
      myApp: {
        relativeInputPaths: ["src/schemas.ts"],
        relativeOutdir: "elm/generated",
        outputModuleNamespace: ["Api", "Generated"],
      },
    },
  })
)
```

`root` anchors the input paths; `relativeOutdir` resolves against the cwd you launch from.
[`tests/corpus.config.ts`](tests/corpus.config.ts) is a working example.

Per-section options:

| field | meaning |
|-------|---------|
| `relativeInputPaths` | `.ts` files (relative to `root`) whose exported Zod schemas get generated |
| `relativeOutdir` | where the Elm files are written |
| `outputModuleNamespace` | module-name prefix, e.g. `["Api", "Generated"]` → `module Api.Generated.User` |
| `elmCodegenOverrides` | optional; override elm-codegen's `generatorModulePath` / `debug` |

The input file just needs to `export` Zod schemas — anything that's a `ZodType` is picked up;
everything else is ignored.

### Generate

```
pnpm generate
```

Output directories can be shared — with other sections, other configs, or hand-written Elm — so a
run never wipes one. Instead each run records the files it wrote in a manifest under
`.typewriter/<section>/` (next to the intermediate Zod AST dump), and the next run deletes exactly
those before regenerating. Deleting a schema removes its module; anything typewriter didn't write is
left alone. With no manifest (first run, fresh clone — `.typewriter/` is gitignored) nothing is
deleted, only overwritten. Output for one schema looks like:

```elm
-- export const user = z.object({ id: z.string(), role: z.enum(["admin", "user"]) })

module Api.Generated.User exposing (..)

type alias Value =
    { id : String, role : Role }

decoder : Json.Decode.Decoder Value
decoder = ...

encoder : Value -> Json.Encode.Value
encoder = ...

type Role = RoleAdmin | RoleUser   -- nested unions are hoisted to named types

roleDecoder : Json.Decode.Decoder Role
roleDecoder = ...

roleEncoder : Role -> Json.Encode.Value
roleEncoder = ...
```

### The safety net

If any schema uses something not yet supported, codegen writes a placeholder into an
`AaaaaaaaaErrors` module **and the run fails with a non-zero exit** (see `assertNoErrorModule` in
[`src/main.ts`](src/main.ts)) — listing exactly which schemas fell through. Nothing is ever silently
half-generated. So the way to find out whether your schemas are fully supported is to just run it.

## What's supported

Generates a type, a working decoder, **and** a matching encoder, compiling cleanly. The
encoder is the decoder's inverse: `Json.Decode.decodeValue decoder (encoder v) == Ok v` for
every generated module (`tests/Test/Roundtrip.elm` holds the law to the fire). A few encoding
choices worth knowing: flattened `optional` / `nullable` / `nullish` values encode `Nothing`
as `null` (with the field present), `bigint` encodes as a decimal string, and the phantom
leaves (`nan` / `void` / `undefined` / `null`) all encode as `null`.

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
| `index.ts` | `pnpm generate` — runs the corpus config |
| `src/config.ts` | config schema + `toConfig` |
| `src/main.ts` | `runAll`: per-section run, manifest-scoped cleanup, safety-net checks |
| `src/astify.ts` | loads a `.ts` module and extracts its Zod schemas |
| `src/Ast.elm` | the typed AST + its JSON decoder (the Zod wire format → `Ast.Value`) |
| `src/Builder.elm` | `Ast.Value` → Elm type + decoder, via [elm-codegen](https://github.com/mdgriffith/elm-codegen) |
| `codegen/GenerateZodBindings.elm` | the elm-codegen entry that drives `Builder` |
| `tests/schemaVariants.ts` | example corpus / integration fixture |
| `tests/corpus.config.ts` | the config that generates the corpus into `generated/IntegrationTests/` |
