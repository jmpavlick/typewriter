import "./lib/serializeErrorPrototype.js"
import { type Config, toConfig } from "./src/config.js"
import * as ElmCodegen from "./lib/elmCodegen.js"
import zx from "./lib/zod/ext.js"
import z from "zod"
import { ResultAsync, okAsync, errAsync } from "neverthrow"
import path from "path"
import * as Astify from "./src/astify.js"
import { doAsync } from "./lib/neverthrow/ext.js"
import * as fs from "./lib/fs.js"

/** a `Config` describes all of the program's executions; `RunProps` describes a single execution of the program

  a `Config` becomes many `RunProps`es
 */
const runProps = z.object({
  label: z.string(),
  inputPath: z.string(),
  elmCodegenConfig: ElmCodegen.config,
  debugZodAstOutputPath: z.string(),
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

const run = ({ label, inputPath, elmCodegenConfig, debugZodAstOutputPath }: RunProps) =>
  doAsync(() => {
    console.log(`section: ${label}\ninput: ${inputPath}`)
  })
    .andThen(() => Astify.execute(inputPath))
    .andThrough((zodDecls) =>
      elmCodegenConfig.debug
        ? fs.writeFile(debugZodAstOutputPath, JSON.stringify(zodDecls, null, 2))
        : okAsync(undefined)
    )
    .andThen(ElmCodegen.execute(elmCodegenConfig))
