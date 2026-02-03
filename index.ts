#!/usr/bin/env node
import "./lib/serializeErrorPrototype.js"
import z from "zod"
import zx from "./lib/zod/ext.js"
import { ConfigParams, configParams, type Config } from "./src/config.js"
import * as ElmCodegen from "./lib/elmCodegen.js"
import path from "path"
import { type RunProps, run } from "./src/main.js"
import { importAsync, md5Async, parseJsonSafe } from "./lib/neverthrow/ext.js"
import * as fs from "./lib/fs.js"
import { errAsync, fromPromise, okAsync, ResultAsync } from "neverthrow"
import { fileURLToPath } from "url"
import { init } from "./src/init.js"
import { toConfig } from "./src/config.js"

const toRunPropsEntries = ({
  root: relativeRoot,
  elmCodegenConfig: globalElmCodegenConfig,
  sections,
  workdirPath,
}: Config): RunProps[] => {
  // hack
  const root = path.join(process.cwd(), relativeRoot)
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
      .orElse((err) => fs.cwd().value.map((cwd) => ({ cwd, userConfigParams: { sections: {} } })))
      .andThen(({ cwd, userConfigParams }) =>
        zx
          .parseResultAsync(configParams)(userConfigParams)
          .map((params) => ({ cwd, params }))
      )
      .map(({ cwd, params }) =>
        toConfig({ root: params.root ? path.resolve(cwd, params.root) : cwd, ...params })
      )

  const argsConfigIO = (path: string) =>
    fs
      .cwd()
      .join(path)
      .andThen((fullPath) =>
        importAsync(z.object({ default: configParams }))(fullPath).map((v) =>
          toConfig((v as any).default)
        )
      )

  return configFilePath === undefined
    ? fs.cwd().value.andThen(defaultConfigIO)
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

const generateFlags = z.union([
  z
    .array(z.any())
    .refine((arr) => arr.length === 0, {
      message: "invalid value; expected either a flag and value, or an empty array",
    })
    .refine(() => "default" as const),
  z.tuple([z.literal("--config"), z.string()]),
])

// Only run if this is the main module
if (
  import.meta.url === `file://${process.argv[1]}` ||
  fileURLToPath(import.meta.url) === process.argv[1]
) {
  const commandArg = process.argv[2]

  await toCommand(commandArg)
    .orElse(() => okAsync("generate" as const))
    .andThen((cmd) => {
      switch (cmd) {
        case "init":
          return init()
        case "generate":
          return zx
            .parseResultAsync(generateFlags)(process.argv.slice(3))
            .andThen((maybeArg) => {
              if (maybeArg.length === 0) return generate()
              const tag = maybeArg[0]
              switch (tag) {
                case "--config":
                  return generate(maybeArg[1])
                case "--default":
                  return generate()
                default:
                  return errAsync(`unhandled tag: ${tag}`)
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
