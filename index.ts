#!/usr/bin/env node
import path from "path"
import { type Config } from "./src/config.js"
import * as ElmCodegen from "./lib/elmCodegen.js"
import { type RunProps, run } from "./src/main.js"
import ouroboros from "./src/ouroboros.js"

// the configuration lives in src/ouroboros.ts — edit that to add/point sections at your schemas
const base: Config = {
  ...ouroboros,
  root: path.resolve(ouroboros.root),
}

const toRunPropsEntries = ({
  root,
  elmCodegenConfig: globalElmCodegenConfig,
  sections,
  workdirPath,
}: Config): RunProps[] => {
  const fromSection = ([
    label,
    {
      relativeInputPaths,
      relativeOutdir,
      cleanFirst,
      debug,
      elmCodegenOverrides,
      outputModuleNamespace,
    },
  ]: [string, Config["sections"][number]]): RunProps[] => {
    const elmCodegenConfig: ElmCodegen.Config = {
      ...globalElmCodegenConfig,
      outdir: relativeOutdir,
      ...(cleanFirst === undefined ? {} : { cleanFirst }),
      ...(debug === undefined ? {} : { debug }),
      ...{ ...elmCodegenOverrides },
    }

    return relativeInputPaths.map((rip) => {
      const inputPath = path.join(root, rip)
      const relativeWithoutExt = rip.replace(/\.[^.]+$/, "")
      const debugZodAstOutputPath = path.join(workdirPath, `${relativeWithoutExt}.json`)

      return {
        label,
        inputPath,
        outputModuleNamespace: outputModuleNamespace ?? [],
        elmCodegenConfig,
        debugZodAstOutputPath,
      }
    })
  }

  return Array.from(Object.entries(sections)).flatMap(fromSection)
}

// run every section; collect all failures (so one bad section doesn't hide the others)
const outcomes = await Promise.allSettled(toRunPropsEntries(base).map(run))
const failures = outcomes.flatMap((o) => (o.status === "rejected" ? [o.reason] : []))

if (failures.length > 0) {
  for (const failure of failures) {
    console.error(failure)
  }
  // non-zero exit if any section failed or emitted an error module — see src/main.ts
  process.exit(1)
}
