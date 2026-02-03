#!/usr/bin/env node
import "./lib/serializeErrorPrototype.js"
import z from "zod"
import zx from "./lib/zod/ext.js"
import { ConfigParams, configParams, type Config } from "./src/config.js"
import * as ElmCodegen from "./lib/elmCodegen.js"
import path from "path"
import { type RunProps, run } from "./src/main.js"
import { debugLog, importAsync, md5Async, parseJsonSafe } from "./lib/neverthrow/ext.js"
import * as fs from "./lib/fs.js"
import { errAsync, fromPromise, okAsync, ResultAsync } from "neverthrow"
import { fileURLToPath } from "url"
import { init } from "./src/init.js"
import { toConfig } from "./src/config.js"

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

const runAllRunPropsEntries = (runPropsEntries: RunProps[]): ResultAsync<void, unknown> =>
  ResultAsync.combineWithAllErrors(runPropsEntries.map(run))
    .map(() => {})
    .mapErr((errs) => errs as unknown)

const getUserConfig = (configFilePath?: string): ResultAsync<Config, unknown> => {
  const defaultConfigIO = (cwd: string) =>
    okAsync(cwd)
      .andThen((cwd) =>
        fromPromise(import(path.join(cwd, "typewriter.config.ts")), (e) => e)
          .map((module: any) => module.default)
          .map((userConfigParams) => ({ cwd, userConfigParams }))
      )
      .orElse((err) => fs.cwd().map((cwd) => ({ cwd, userConfigParams: { sections: {} } })))
      .andThen(({ cwd, userConfigParams }) =>
        zx
          .parseResultAsync(configParams)(userConfigParams)
          .map((params) => ({ cwd, params }))
      )
      .map(({ cwd, params }) =>
        toConfig({ root: params.root ? path.resolve(cwd, params.root) : cwd, ...params })
      )

  const argsConfigIO = (path: string) =>
    importAsync(path, z.object({ default: configParams })).map(toConfig)

  return configFilePath === undefined
    ? fs.cwd().andThen(defaultConfigIO)
    : argsConfigIO(configFilePath)
}

const generate = (configFilePath?: string): ResultAsync<void, unknown> =>
  getUserConfig(configFilePath)
    .orTee((err) => {
      console.error("Failed to load user config:", err)
    })
    .map(toRunPropsEntries)
    .andThen(runAllRunPropsEntries)
    .orTee((err) => {
      console.error("Failed to generate:", err)
    })

const command = z.union([z.literal("init"), z.literal("generate")])
type Command = z.infer<typeof command>
const toCommand = zx.parseResultAsync(command)

const generateFlags = z.union([z.undefined(), z.tuple([z.literal("--config"), z.string()])])

// Only run if this is the main module
if (
  import.meta.url === `file://${process.argv[1]}` ||
  fileURLToPath(import.meta.url) === process.argv[1]
) {
  const commandArg = debugLog("process.argv[2]", process.argv[2])

  await toCommand(commandArg)
    .orElse(() => okAsync("generate" as const))
    .andThen((cmd) => {
      switch (cmd) {
        case "init":
          return init()
        case "generate":
          return zx
            .parseResultAsync(generateFlags)(
              debugLog("process.argv.slice(2, 2)", process.argv.slice(2, 2))
            )
            .andThen((maybeArg) => {
              if (maybeArg === undefined) return generate()
              const tag = maybeArg[0]
              switch (tag) {
                case "--config":
                  return generate(maybeArg[1])
                default:
                  const _: never = tag
                  return errAsync("typescript moment")
              }
            })
        default:
          const _: never = cmd
          return errAsync("typescript moment")
      }
    })
    .match(
      () => {
        console.log("✓ Done")
      },
      (err) => {
        console.error("✗ Error:", err)
        process.exit(1)
      }
    )
}

// Export types for users
export type { Config, ConfigParams } from "./src/config.js"
