#!/usr/bin/env node
import "./lib/serializeErrorPrototype.js"
import z from "zod"
import zx from "./lib/zod/ext.js"
import { ConfigParams, configParams, type Config } from "./src/config.js"
import * as ElmCodegen from "./lib/elmCodegen.js"
import path from "path"
import { type RunProps, run } from "./src/main.js"
import ouroboros from "./src/ouroboros.js"
import { md5Async, parseJsonSafe } from "./lib/neverthrow/ext.js"
import * as fs from "./lib/fs.js"
import { fromPromise, okAsync, ResultAsync } from "neverthrow"
import { fileURLToPath } from "url"
import { init } from "./src/init.js"

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
      // outdir: path.join(root, relativeOutdir),
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
  .orElse(() =>
    fs.cwd().andThen((cwd) => fromPromise(import(path.join(cwd, "typewriter.config.ts")), (e) => e))
  )
  .orElse(() => okAsync({ root: base.root, sections: {} }))
  .andThen(zx.parseResultAsync(configParams))
  .map((userConfigParams) => ({ ...base, configParams: userConfigParams }))

const generate = compareBaseConfigHashes
  .andThrough(runBaseSetup)
  .andThrough((configStatus) =>
    getUserConfig.map(toRunPropsEntries).andThen(runAllRunPropsEntries(configStatus))
  )

const command = z.union([z.literal("init"), z.literal("generate")])
type Command = z.infer<typeof command>
const toCommand = zx.parseResultAsync(command)

// Only run if this is the main module
if (
  import.meta.url === `file://${process.argv[1]}` ||
  fileURLToPath(import.meta.url) === process.argv[1]
) {
  const commandArg = process.argv[2]

  toCommand(commandArg)
    .orElse(() => okAsync("generate" as const))
    .andThen((cmd) => {
      switch (cmd) {
        case "init":
          return init()
        case "generate":
          return generate
      }
    })
    .orTee((err) => {
      console.error(err)
    })
}

// Export types for users
export type { Config, ConfigParams } from "./src/config.js"
