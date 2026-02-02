#!/usr/bin/env node
import "./lib/serializeErrorPrototype.js"
import zx from "./lib/zod/ext.js"
import { ConfigParams, configParams, type Config } from "./src/config.js"
import * as ElmCodegen from "./lib/elmCodegen.js"
import path from "path"
import { type RunProps, run } from "./src/main.js"
import ouroboros from "./src/ouroboros.js"
import { md5Async, parseJsonSafe } from "./lib/neverthrow/ext.js"
import * as fs from "./lib/fs.js"
import { okAsync, ResultAsync } from "neverthrow"
import { fileURLToPath } from "url"

const base = {
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
    { relativeInputPaths, relativeOutdir, cleanFirst, debug, elmCodegenOverrides },
  ]: [string, Config["sections"][number]]) => {
    const elmCodegenConfig: ElmCodegen.Config = {
      ...globalElmCodegenConfig,
      // outdir: path.join(root, relativeOutdir),
      outdir: relativeOutdir,
      ...(cleanFirst === undefined ? {} : { cleanFirst }),
      ...(debug === undefined ? {} : { debug }),
      ...{ ...elmCodegenOverrides },
    }

    return relativeInputPaths.map((rip) => {
      const relativeInputPath = rip
      const relativeWithoutExt = rip.replace(/\.[^.]+$/, "")
      const debugZodAstOutputPath = path.join(workdirPath, `${relativeWithoutExt}.json`)

      return {
        root,
        label,
        relativeInputPath,
        elmCodegenConfig,
        debugZodAstOutputPath,
      }
    })
  }

  return Array.from(Object.entries(sections)).flatMap(fromSection)
}

const compareBaseConfigHashes: ResultAsync<{ configWasWritten: boolean }, unknown> = md5Async(base)
  .andThen((baseMd5) =>
    fs
      .readFile(base.baseConfigMd5Path)
      .orElse((err) => okAsync(""))
      .map((workdirBaseMd5) => ({
        baseMd5,
        workdirBaseMd5,
      }))
  )
  .andThen(({ baseMd5, workdirBaseMd5 }) => {
    const writeIO = fs.writeFileUtf8(base.baseConfigMd5Path, baseMd5, {
      overwrite: true,
    })

    return baseMd5 === workdirBaseMd5
      ? okAsync({ configWasWritten: false })
      : writeIO.map(() => ({ configWasWritten: true }))
  })

const runAllRunPropsEntries =
  ({ configWasWritten }: { configWasWritten: boolean }) =>
  (runPropsEntries: RunProps[]): ResultAsync<void, unknown> =>
    ResultAsync.combineWithAllErrors(
      runPropsEntries
        .map((rp) =>
          configWasWritten === false
            ? rp
            : { ...rp, elmCodegenConfig: { ...rp.elmCodegenConfig, cleanFirst: true } }
        )
        .map(run)
    )
      .map(() => {})
      .mapErr((errs) => errs as unknown)

const runBaseSetup = ({
  configWasWritten,
}: {
  configWasWritten: boolean
}): ResultAsync<void, unknown> => {
  const runPropsEntries = toRunPropsEntries(base)

  const runIO = runAllRunPropsEntries({ configWasWritten })(runPropsEntries)

  return configWasWritten ? runIO.map(() => {}) : okAsync()
}

const getUserConfig: ResultAsync<Config, unknown> = fs
  .readFile(base.userConfigParamsPath)
  .orElse(() => okAsync({ root: base.root, sections: {} }))
  .andThen(zx.parseResultAsync(configParams))
  .map((userConfigParams) => ({ ...base, configParams: userConfigParams }))

const execute = compareBaseConfigHashes
  .andThrough(runBaseSetup)
  .andThrough((configStatus) =>
    getUserConfig.map(toRunPropsEntries).andThen(runAllRunPropsEntries(configStatus))
  )
  .orTee((err) => {
    console.error(err)
  })

// Only run if this is the main module
if (
  import.meta.url === `file://${process.argv[1]}` ||
  fileURLToPath(import.meta.url) === process.argv[1]
) {
  execute
}
