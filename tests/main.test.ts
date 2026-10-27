import { test } from "node:test"
import assert from "node:assert/strict"
import z from "zod"
import * as path from "path"
import { fileURLToPath } from "url"
import { type ConfigParams, packageRoot, toConfig } from "../src/config.js"
import { manifest, toElmModuleSegment, toRunPropsEntries, toSerializable } from "../src/main.js"
import corpus from "./corpus.config.js"

// the package root, derived the same way config.ts derives it — tests/ → ..
const packageRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")

test("toConfig locates the generator at <package>/codegen, independent of caller root", () => {
  // the unlock for external use: a caller rooting inputs in another repo must still
  // find typewriter's own codegen/ project.
  const cfg = toConfig({ root: "/somewhere/else", sections: {} })
  assert.equal(cfg.elmCodegenConfig.cwd, path.join(packageRoot, "codegen"))
})

test("toConfig roots the debug workdir at the caller's root", () => {
  const cfg = toConfig({ root: "/somewhere/else", sections: {} })
  assert.equal(cfg.workdirPath, path.join("/somewhere/else", ".typewriter"))
})

test("toConfig defaults root to '.' when absent", () => {
  const cfg = toConfig({ sections: {} })
  assert.equal(cfg.root, ".")
})

test("toRunPropsEntries emits one RunProps per (section × input path)", () => {
  const params: ConfigParams = {
    root: "/app",
    sections: {
      models: {
        relativeInputPaths: ["a/schemas.ts", "b/schemas.ts"],
        relativeOutdir: "out/elm",
        outputModuleNamespace: ["Api", "Gen"],
      },
    },
  }

  const entries = toRunPropsEntries(toConfig(params))

  assert.equal(entries.length, 2)
  assert.deepEqual(
    entries.map((e) => e.label),
    ["models", "models"],
  )
  // root is resolved to absolute; outputs stay as the caller's relativeOutdir
  assert.equal(entries[0].inputPath, path.join("/app", "a/schemas.ts"))
  assert.equal(entries[1].inputPath, path.join("/app", "b/schemas.ts"))
  assert.equal(entries[0].elmCodegenConfig.outdir, "out/elm")
  assert.deepEqual(entries[0].outputModuleNamespace, ["Api", "Gen"])
  assert.equal(
    entries[0].zodAstOutputPath,
    path.join("/app", ".typewriter", "models", "a/schemas.json"),
  )
  assert.equal(
    entries[0].manifestPath,
    path.join("/app", ".typewriter", "models", "a/schemas.manifest.json"),
  )
})

test("toRunPropsEntries keys the workdir by section, so sections sharing an input don't share a manifest", () => {
  const entries = toRunPropsEntries(
    toConfig({
      root: ".",
      sections: {
        a: { relativeInputPaths: ["x.ts"], relativeOutdir: "o" },
        b: { relativeInputPaths: ["x.ts"], relativeOutdir: "o" },
      },
    }),
  )
  assert.notEqual(entries[0].manifestPath, entries[1].manifestPath)
})

test("toRunPropsEntries defaults an absent outputModuleNamespace to []", () => {
  const entries = toRunPropsEntries(
    toConfig({
      root: ".",
      sections: { s: { relativeInputPaths: ["x.ts"], relativeOutdir: "o" } },
    }),
  )
  assert.deepEqual(entries[0].outputModuleNamespace, [])
})

test("toRunPropsEntries threads elmCodegenOverrides into elmCodegenConfig", () => {
  const entries = toRunPropsEntries(
    toConfig({
      root: ".",
      sections: {
        s: { relativeInputPaths: ["x.ts"], relativeOutdir: "o", elmCodegenOverrides: { debug: true } },
      },
    }),
  )
  assert.equal(entries[0].elmCodegenConfig.debug, true)
})

test("manifest only admits .elm paths, so a mangled one can't aim the delete elsewhere", () => {
  assert.equal(manifest.safeParse({ files: ["/out/Locale.elm"] }).success, true)
  assert.equal(manifest.safeParse({ files: ["/out/elm.json"] }).success, false)
})

test("toSerializable drops true cycles but keeps shared (DAG) references and all fields", () => {
  const shared: Record<string, unknown> = { v: 1 }
  const root: Record<string, unknown> = { type: "object", a: shared, b: shared }
  root.self = root // direct cycle
  shared.parent = root // cycle through a shared node

  // would throw under plain JSON.stringify; must not here
  const out = toSerializable(root) as Record<string, any>

  assert.equal(out.type, "object") // structural field preserved
  assert.equal(out.self, undefined) // back-edge dropped
  // the shared node survives in BOTH positions (DAG kept, not collapsed/dropped)
  assert.deepEqual(out.a, { v: 1 })
  assert.deepEqual(out.b, { v: 1 })
  assert.equal(out.a.parent, undefined) // only its cyclic back-edge is gone
})

test("toSerializable stamps `partial` onto enum-keyed partialRecord defs (zod keeps partiality in internal state stringify never emits)", () => {
  const out = toSerializable({
    part: z.partialRecord(z.enum(["a", "b"]), z.string()),
    full: z.record(z.enum(["a", "b"]), z.string()),
    stringKeyed: z.partialRecord(z.string(), z.string()),
  }) as Record<string, any>

  assert.equal(out.part.def.partial, true)
  assert.equal("partial" in out.full.def, false)
  // string-keyed records generate as Dict — missing keys are already the natural case
  assert.equal("partial" in out.stringKeyed.def, false)
})

test("the corpus config plans absolute, package-rooted paths so `pnpm generate` is cwd-independent", () => {
  for (const e of toRunPropsEntries(corpus)) {
    assert.ok(path.isAbsolute(e.inputPath), `input absolute: ${e.inputPath}`)
    assert.ok(e.inputPath.startsWith(packageRoot), `input under packageRoot: ${e.inputPath}`)
    assert.ok(
      path.isAbsolute(e.elmCodegenConfig.outdir),
      `outdir absolute: ${e.elmCodegenConfig.outdir}`,
    )
    assert.ok(
      e.elmCodegenConfig.outdir.startsWith(packageRoot),
      `outdir under packageRoot: ${e.elmCodegenConfig.outdir}`,
    )
  }
})

// must agree with Builder.elm's `String.Extra.camelize >> toTitleCase`, or a generated module reads as missing
for (const [input, expected] of [
  ["storePageProjection", "StorePageProjection"],
  ["StorePageProjection", "StorePageProjection"],
  ["store_page_projection", "StorePageProjection"],
  ["store-page", "StorePage"],
  ["trailing_", "Trailing"],
  ["v2Thing", "V2Thing"],
] as const) {
  test(`toElmModuleSegment(${JSON.stringify(input)}) === ${JSON.stringify(expected)}`, () => {
    assert.equal(toElmModuleSegment(input), expected)
  })
}
