# Union Type Codegen Plan

## Status — 2026-06-26 attempt (go/no-go)

**GO — full union support across the test suite. Zero codegen errors; the `AaaaaaaaaErrors` module is no longer emitted.** All 132 generated modules compile; 10 Elm tests pass. Covers unit-variant unions (`z.literal`, `z.enum`, `z.union` of literals) **and** discriminated unions (`z.discriminatedUnion`), at the root of a decl and nested inside records/arrays.

What now works (all previously in the error module):
- `stringLiteral` → `type Value = StringLiteral` + decoder matching `"stringLiteral"`
- `stringLiteralsAsEnum` → `type Value = Blue | Red | Yellow` + string-matching decoder
- `user` → nested unions are **hoisted to named top-level types** and referenced from the record:
  `identityProvider : IdentityProvider`, `group : Group`, `canEditPostsForMembersOfGroups : Maybe (List CanEditPostsForMembersOfGroups)`, each with a generated decoder.
- `systemUser` → `type Value = PrivilegedUser { ... } | User { ... }` with a `D.field "tag"`-dispatched decoder; its nested `role` enum is hoisted to `type Role = RoleAdmin | RoleModerator` and referenced from the payload.

### Discriminated unions — how it landed
A dedicated AST node `SDiscriminatedUnion { discriminator, variants : Dict wireValue Value }` (additive — new `Props` field, `para` case, `optPara` base entry, `onDiscriminatedUnion` attr; existing `SUnion` untouched). The `"union"` decoder reads `def.discriminator`, decodes each object option, pulls the discriminant field's literal as the variant key, and strips it from the payload (`extractDiscriminatedVariants` in `Ast.elm`); it falls back through `D.oneOf` to the plain-union and `SUnimplemented` paths. The Builder generates `variantWith` constructors carrying the payload record and a `D.field discriminator |> D.andThen (case ...)` decoder (`discriminatedUnionTypeDecl` / `discriminatedUnionDecoder`). `collectUnions` recurses into payloads so nested unions there still hoist.

**Test-schema fix:** `systemUser` was written `z.object({ tag: "user", ... })` with a raw string, which is **invalid Zod v4** (it throws at parse time — a raw string isn't a schema, so the discriminated-union machinery hits `undefined.values`). Corrected to `z.object({ tag: z.literal("user"), ... })`, the idiomatic form.

### Nested-union hoisting — how it landed (lighter than the planned GenMonad)
Rather than the writer monad, a **pre-pass builds a symbol table** (`collectUnions` + `buildUnionTable` in `Builder.elm`) keyed by structural identity. The `optPara` traversal then just *looks up* a union's hoisted name (returning `Type.named [] name` / `Elm.val (decoderName name)`), and `build` appends the hoisted `type`/`decoder` declarations. The table is computed once and threaded into both attr passes — no `succeedWith`/accumulator-draining needed because naming is resolved up front, exactly as the SymbolTable section intended. `src/GenMonad.elm` was never needed; the SymbolTable lives inline in `Builder.elm`.

Naming: nested unions are named from their object-field breadcrumb (`group` → `Group`); structurally identical unions at different paths dedupe to one declaration; name clashes between structurally distinct unions get a numeric suffix. Because Elm custom-type constructors share the module namespace, **hoisted** unions prefix their constructors with the type name (`Group` → `GroupAdmin | GroupModerator | GroupUser`) to avoid collisions; root-level unions stay clean (`Value = Red | …`) since they're the only type in their module.

What changed vs. the original plan's assumptions:
- **The AST was *not* actually done.** The `enum`/`literal` decoders threw away the wire value (`"red"` → ctor `Red`, args `[]`), making a correct decoder impossible. Fix: each unit variant now carries its wire value as a single literal leaf in its args (`("Red", [SLiteralString "red"])`). No change to the `SUnion`/`Props`/`para` signatures — `onUnion` already receives the raw variant dict, so the wire value is readable there.
- **There was no `"union"` decoder case at all** — `z.union`/`z.discriminatedUnion` fell through to `SUnimplemented`. Added one that flattens literal options into a single variant dict and degrades gracefully (`D.oneOf [..., D.succeed SUnimplemented]`) for shapes it can't handle, so a bad union never hard-fails the whole file's decode.
- **Record dispatch bug** (separate from unions): `para` routed `SRecord` through `props.sArray` (`Ast.elm:200`), so `z.record(z.string(), V)` came out as `List V` instead of `Dict String V`. One-line fix; `recordInObject` now correctly emits `Dict.Dict String {...}`.

### Remaining edges (none block the test suite)
- **Nested discriminated unions**: a `z.discriminatedUnion` *inside* a record is not yet hoisted — `onDiscriminatedUnion` isn't wired into the attr passes, so a nested one degrades (returns Nothing → its enclosing object would error). Root-level discriminated unions work; nested ones would need the same symbol-table hoisting the unit unions already get. (Not exercised by the current test schema.)
- **int/bool-valued unit unions**: the classifier accepts them into the *type*, and `hoistedUnionDecls` still emits the type even when the decoder can't be built, but `unitUnionDecoder` only builds string-matching decoders so far (`Elm.Case.string`). Int needs if-chains or `Elm.Case.custom`; bool an `ifThen`. (Mixed-wire unions like `z.literal(["a", 1, true])` are inherently un-decodable from a single base decoder.)
- **Plain object unions without a discriminant** (`z.union([objA, objB])`, no shared literal tag): still degrade — they need positional `D.oneOf` variant decoders. Only discriminated object unions are handled.
- **Cross-module dedup**: the symbol table is per-decl/per-module; the same structural union referenced from two schemas gets its own copy in each output module. Fine for now (each module is self-contained).

Touched: `src/Ast.elm` (record dispatch fix, wire-preserving enum/literal decoders, new `"union"` case, `SDiscriminatedUnion` node + `extractDiscriminatedVariants`), `src/Builder.elm` (root-union codegen, nested-union symbol table, discriminated-union codegen; removed dead `Fragment`/`liftAnnotationMap`), `tests/schemaVariants.ts` (fixed malformed `systemUser`), `tests/Test/Ast.elm` (updated 4 expectations + added discriminated-union test).

---

## Where We Are (original plan, pre-attempt)

The AST (`src/Ast.elm`) now fully represents union types:

```elm
-- a union is a Dict from variant constructor name → list of arg types
SUnion (Dict String (List Value))

-- literals (which appear as union variants in zod wire format)
SLiteralString String
SLiteralInt Int
SLiteralBool Bool
-- SNull covers the null literal case
```

The decoder handles all of these:
- `"literal"` → `SLiteralString / SLiteralInt / SLiteralBool / SNull`
- `"enum"` → `SUnion (Dict.fromList [(String.Ext.toTypename k, []) ...])` — unit variants from `z.enum`
- `"union"` → `SUnion` with per-option key derivation (currently: type tag as key, which collides for multi-object unions — see Known Limitations)

`Builder.elm` currently handles everything *except* `SUnion` and the new literal variants. Those fall through to the error module (`AaaaaaaaaErrors`).

---

## The Core Problem

`elm-codegen` has a fundamental split:

- **Record types / type aliases** are built from `Type.Annotation`, composed bottom-up, and emitted as `Elm.alias "Name" annotation`
- **Custom types** are built from `Elm.Variant` directly into `Elm.Declaration` via `Elm.customType`

The existing `optPara`-based traversal in `Builder.elm` works beautifully for records because `Type.Annotation` is composable — you can build it bottom-up and the parent node just wraps it. Custom types *cannot* be built this way: you need all variants assembled before you can call `Elm.customType`, and the variant constructors require naming that isn't available at the leaf level.

This means a `SUnion` node encountered during traversal needs to produce *two things*:
1. A `Type.Annotation` reference (just a name: `Type.named [] "SomeName"`) for use by the parent
2. A new `Elm.Declaration` (the `type SomeName = ...`) that gets hoisted to the top level of the output file

The current single-pass `optPara` returns one value. We need a writer-monad-style accumulator.

---

## The Plan

### Step 1: Build a `SymbolTable` (first-pass catamorphism)

Before any code generation, walk *all* `Decl`s together to build a mapping from structural union identity → chosen Elm type name.

```elm
-- src/SymbolTable.elm (new file)
type alias SymbolTable =
    Dict StructuralKey String

type alias StructuralKey =
    String  -- sorted, canonical: "Admin|Mod|User" or "object:tag=cat,meows:bool|object:tag=dog,barks:bool"
```

**Naming resolution order:**
1. If `SUnion` is the *root value* of a top-level `Decl` → name is the decl name (e.g. `nonAdminGroups` → `NonAdminGroups`)
2. If an `Attr` config override exists for this path → use that name (see Configurability below)
3. Otherwise → synthesize from breadcrumb field path (e.g. field `group` inside decl `user` → `UserGroup`)
4. If two structurally identical unions want the same synthesized name → they *are* the same name (deduplication)
5. If name collision between structurally *different* unions at same path → append a hash suffix

**Structural key computation** is a simple `para` over `Value` that produces a canonical string:
- `SLiteralString s` → `s`
- `SLiteralInt i` → `String.fromInt i`
- `SLiteralBool b` → `"true"` / `"false"`
- `SUnion dict` → `Dict.keys dict |> List.sort |> String.join "|"`
- For object variants: include the field names in the key

### Step 2: `GenMonad` — writer monad for the traversal

Inspired by `CliMonad` in `elm-open-api-cli`. The key insight from that codebase: when the traversal hits a `OneOf` node, it returns a `Type.Annotation` reference *and simultaneously emits the union declaration data as a side effect* into an output accumulator. After the traversal, you drain the accumulator and generate the actual declarations.

```elm
-- src/GenMonad.elm (new file)
type GenMonad a =
    GenMonad (Input -> Result String ( a, Output ))

type alias Input =
    { symbolTable : SymbolTable
    , path : List String  -- breadcrumb for naming anonymous unions
    }

type alias Output =
    { warnings : List String
    , unions : Dict StructuralKey UnionDef
    }

type alias UnionDef =
    { name : String
    , variants : Dict String (List Value)  -- the original SUnion dict
    }
```

Standard monad operations: `map`, `andThen`, `succeed`, `succeedWith` (the key one — returns a value *and* emits something into `Output`).

The `succeedWith` operation is how a `sUnion` handler fires its side-declaration:

```elm
succeedWith : Output -> a -> GenMonad a
```

### Step 3: Augment `Builder.elm` attrs to return `GenMonad`

Change:
```elm
typeAnnotationAttrs : List (Ast.Attr Type.Annotation)
decoderExprAttrs    : List (Ast.Attr Elm.Expression)
```

To:
```elm
typeAnnotationAttrs : List (Ast.Attr (GenMonad Type.Annotation))
decoderExprAttrs    : List (Ast.Attr (GenMonad Elm.Expression))
```

The `sUnion` handler in `typeAnnotationAttrs`:
```elm
Ast.onUnion
    (\variantDict _ ->
        let key = SymbolTable.structuralKey variantDict
        in SymbolTable.lookup key
            |> GenMonad.andThen (\name ->
                Type.named [] name
                    |> GenMonad.succeedWith
                        { warnings = []
                        , unions = Dict.singleton key { name = name, variants = variantDict }
                        }
            )
    )
```

Returns a `Type.Annotation` reference by name, and *emits* the `UnionDef` into the accumulator. Parent nodes get both values merged automatically because `GenMonad.map2` / `andThen` merge their `Output`s.

The `Fragment` type (`Variants | Annotation`) can be removed — `Variants` was a placeholder for exactly this problem and is now superseded by the `GenMonad` accumulator pattern. Everything becomes `Annotation Type.Annotation` → just `Type.Annotation`.

### Step 4: `toUnionTypeDecl` and `toUnionDecoderDecl`

Two new functions in `Builder.elm`, called *after* the traversal to drain the `Output.unions` accumulator:

```elm
toUnionTypeDecl : UnionDef -> Elm.Declaration
toUnionTypeDecl { name, variants } =
    variants
        |> Dict.toList
        |> List.map (\( variantName, args ) ->
            case args of
                [] ->
                    Elm.variant variantName
                _ ->
                    -- args have already been resolved to Type.Annotations
                    -- by the traversal pass; store them in UnionDef
                    Elm.variantWith variantName argAnnotations
        )
        |> Elm.customType name
        |> Elm.exposeConstructor
```

For the decoder, two shapes:

**Unit-variant unions** (all `args = []` — i.e. `z.enum`, `z.literal` unions):
```elm
-- type Value = Admin | User | Mod
-- decoder matches on a string and succeeds/fails
D.string |> D.andThen (\s -> case s of
    "admin" -> D.succeed Admin
    "user"  -> D.succeed User
    ...
    _       -> D.fail ("Unknown Value: " ++ s))
```

**Structural (object-argument) unions**:
```elm
-- type Value = Cat { meows : Bool } | Dog { barks : Bool }
D.oneOf
    [ D.map Cat catDecoder
    , D.map Dog dogDecoder
    ]
```
Where each variant decoder is built from its `SObject` args using the existing `toObjectDecoder` machinery.

### Step 5: Update `Builder.build` to drain the accumulator

```elm
build : List String -> SymbolTable -> Ast.Decl -> BuildResult

-- after running the GenMonad traversal:
-- 1. collect all UnionDefs from Output.unions
-- 2. deduplicate by structural key (same key = same declaration, emit once)
-- 3. generate toUnionTypeDecl + toUnionDecoderDecl for each
-- 4. assemble Elm.file with: [mainTypeAlias, mainDecoder] ++ unionDecls ++ unionDecoderDecls
```

### Step 6: Update `GenerateZodBindings.elm`

```elm
let
    symbolTable = SymbolTable.build decls  -- first pass
    outputs = List.map (Builder.build outputModuleNamespace symbolTable) decls
```

---

## Handling Literal Variants in Union Decoders

When `SUnion` variants are `SLiteralString / SLiteralInt / SLiteralBool / SNull`, the decoder
matches on the wire value and returns the unit constructor:

| Zod | AST variant | Wire value | Decoder |
|-----|-------------|-----------|---------|
| `z.literal("admin")` | `("Admin", [])` | `"admin"` | `D.string \|> D.andThen ...` |
| `z.literal(42)` | `("Int42", [])` | `42` | `D.int \|> D.andThen ...` |
| `z.literal(true)` | `("LiteralTrue", [])` | `true` | `D.bool \|> D.andThen ...` |
| `z.enum(["a","b"])` | `("A", []), ("B", [])` | `"a"/"b"` | same as string literal |

The decoder needs to know *what the original wire value was*, not just the constructor name.
`UnionDef` needs to carry this alongside the variant:

```elm
type VariantWireValue
    = WireString String
    | WireInt Int
    | WireBool Bool
    | WireNull
    | WireObject   -- structural variant; decoder built from args

type alias UnionDef =
    { name : String
    , variants : Dict String { args : List Value, wire : VariantWireValue }
    }
```

The wire value is derivable from the original `SLiteralString s` / etc. at accumulation time.

---

## Known Limitations & Graceful Degradation

**Multi-object variants with the same `type` tag** (e.g. two `z.object({...})` variants in a
`z.union`) currently collide in `Dict.fromList` — the second one overwrites the first. This is the
structural union keying problem. Options in priority order:

1. If it's a `z.discriminatedUnion("tag", [...])`, the discriminant field value *is* the variant
   key — `astify.ts` needs to thread through the discriminant field name and each variant's
   discriminant value. This is the **right fix** for discriminated unions.
2. If it's a plain `z.union` with object variants and no explicit discriminant, fall back to
   positional indexing (`"object_0"`, `"object_1"`) and emit a warning.
3. Anything that can't be resolved → emit to `AaaaaaaaaErrors` with a descriptive message, don't
   blow out the rest of the codegen.

**Cross-run name stability**: if a union's structural key changes (new variant added), the
generated type name changes too. This is unavoidable without an explicit config override. The
config `Attr` system is the escape hatch — users can pin a union at a given path to a given name.

**Elm nominal typing at module boundaries**: if two modules reference the same structural union,
they'll each get their own `SUnion` in the AST. The `SymbolTable` deduplicates within a single
codegen run (same input file → same output module). Cross-module deduplication is a future concern;
for now, structural equivalence within one run → one type.

---

## Configurability Hook (Future)

The bones are already in place in `src/config.ts` for section-level configuration. The intended
shape for union naming overrides:

```typescript
// typewriter.config.ts
{
  sections: {
    main: {
      relativeInputPaths: ["schemas.ts"],
      relativeOutdir: "generated",
      unionOverrides: [
        // "at the path user.group in the input, name the union type UserGroup"
        { path: ["user", "group"], name: "UserGroup" }
      ]
    }
  }
}
```

This maps cleanly onto `SymbolTable` — the override is inserted at build time before the
auto-naming pass runs, so auto-naming sees it as already claimed.

---

## File Checklist

| File | Status | Work needed |
|------|--------|-------------|
| `src/Ast.elm` | ✅ Done | `SUnion (Dict String (List Value))`, `SLiteralString/Int/Bool`, full `Props`/`para`/`optPara` wiring, decoder for `literal`/`enum`/`union` |
| `src/SymbolTable.elm` | ❌ New | `build`, `lookup`, structural key computation |
| `src/GenMonad.elm` | ❌ New | Writer monad: `map`, `andThen`, `succeed`, `succeedWith`, `Input`, `Output`, `UnionDef` |
| `src/Builder.elm` | 🔧 Modify | Add `GenMonad` to attr types; implement `sUnion` / `sLiteralString` / `sLiteralInt` / `sLiteralBool` handlers; add `toUnionTypeDecl` / `toUnionDecoderDecl`; drain accumulator in `build`; remove `Fragment` / `toCustomTypeVariants` stubs |
| `codegen/GenerateZodBindings.elm` | 🔧 Modify | Thread `SymbolTable` through; call `SymbolTable.build decls` before `Builder.build` |
| `src/astify.ts` | 🔧 Maybe | For discriminated unions: thread discriminant field name + per-variant discriminant value through so the decoder can match on the right field |
| `tests/Test/Ast.elm` | ✅ Done | Literal union, enum, nested union tests |
| `tests/Test/Builder.elm` | ❌ New | Unit tests for `toUnionTypeDecl`, `toUnionDecoderDecl`, `SymbolTable.build` |
