import "./lib/serializeErrorPrototype.js"
import { type Config } from "./src/config.js"
import * as ElmCodegen from "./lib/elmCodegen.js"
import path from "path"
import { type RunProps } from "./src/main.js"

const toRunPropsEntries = ({
  root,
  elmCodegenConfig: globalElmCodegenConfig,
  sections,
  workdirPath,
}: Config): RunProps[] => {
  const fromSection = ([
    label,
    { relativeInputPaths, relativeOutdir, cleanFirst, debug, elmCodegenOverrides },
  ]: [string, Config["sections"][number]]) => {
    const elmCodegenConfig: ElmCodegen.Config = {
      ...globalElmCodegenConfig,
      outdir: path.join(globalElmCodegenConfig.outdir, relativeOutdir),
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
        elmCodegenConfig,
        debugZodAstOutputPath,
      }
    })
  }

  return Array.from(Object.entries(sections)).flatMap(fromSection)
}
