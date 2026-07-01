import { test } from "node:test"
import assert from "node:assert/strict"
import * as path from "path"
import { fileURLToPath } from "url"
import { type ConfigParams, packageRoot, toConfig } from "../src/config.js"
import { toRunPropsEntries, toSerializable } from "../src/main.js"
import ouroboros from "../src/ouroboros.js"

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
    entries[0].debugZodAstOutputPath,
    path.join("/app", ".typewriter", "a/schemas.json"),
  )
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

test("toRunPropsEntries threads cleanFirst/debug overrides into elmCodegenConfig", () => {
  const entries = toRunPropsEntries(
    toConfig({
      root: ".",
      sections: {
        s: { relativeInputPaths: ["x.ts"], relativeOutdir: "o", cleanFirst: true, debug: true },
      },
    }),
  )
  assert.equal(entries[0].elmCodegenConfig.cleanFirst, true)
  assert.equal(entries[0].elmCodegenConfig.debug, true)
})

test("ouroboros stays a valid config that plans its own self-codegen sections", () => {
  // runAll always runs ouroboros first; this guards that ouroboros keeps planning
  // cleanly (one entry per section) so that contract can't silently rot.
  const entries = toRunPropsEntries(ouroboros)
  assert.deepEqual(
    entries.map((e) => e.label).sort(),
    ["main", "tests"],
  )
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

test("ouroboros plans absolute, package-rooted paths so runAll is cwd-independent", () => {
  // a consumer launches runAll from THEIR repo root; ouroboros (always first) must
  // still resolve its own inputs and write its outputs under typewriter's package
  // dir — never scattering self-codegen into the caller's tree.
  for (const e of toRunPropsEntries(ouroboros)) {
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
