import "./lib/serializeErrorPrototype.js"
import { type Config, toConfig } from "./src/config.js"
import * as ElmCodegen from "./lib/elmCodegen.js"
import zx from "./lib/zod/ext.js"
import z from "zod"
import { ResultAsync, okAsync, errAsync } from "neverthrow"
import path from "path"

/** a `Config` describes all of the program's executions; `RunProps` describes a single execution of the program

  a `Config` becomes many `RunProps`es
 */
const runProps = z.object({
  label: z.string(),
  inputPath: z.string(),
  elmCodegenConfig: ElmCodegen.config,
  workdirPath: z.string(),
})
type RunProps = z.infer<typeof runProps>

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

    return relativeInputPaths.map((rip) => ({
      label,
      inputPath: path.join(root, rip),
      elmCodegenConfig,
      workdirPath,
    }))
  }

  return Array.from(Object.entries(sections)).flatMap(fromSection)
}

const run = ({ label, inputPath, elmCodegenConfig, workdirPath }: RunProps) => {}
