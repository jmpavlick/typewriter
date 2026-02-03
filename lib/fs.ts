import { okAsync, ResultAsync } from "neverthrow"
import * as fs from "fs"
import path from "path"
import { fileURLToPath } from "url"

export const readFile = (
  path: string,
  encoding: BufferEncoding = "utf-8"
): ResultAsync<string, unknown> =>
  ResultAsync.fromPromise(
    fs.promises.readFile(path, encoding),
    (e) => `Failed to read file at ${path}: ${e}`
  )

export const rm = (path: string, options?: fs.RmOptions): ResultAsync<void, unknown> =>
  ResultAsync.fromPromise(fs.promises.rm(path, options), (e) => `Failed to remove ${path}: ${e}`)

export const mkdir = (
  path: string,
  options?: fs.MakeDirectoryOptions
): ResultAsync<string | undefined, unknown> =>
  ResultAsync.fromPromise(
    fs.promises.mkdir(path, options),
    (e) => `Failed to create directory at ${path}: ${e}`
  )

export const writeFileUtf8 = (
  outputPath: string,
  content: string,
  options?: {
    overwrite?: boolean
    mkdirP?: boolean
  }
): ResultAsync<void, unknown> =>
  (options?.mkdirP
    ? mkdir(path.dirname(outputPath), { recursive: true })
    : (okAsync() as ResultAsync<unknown, unknown>)
  ).andThen(() =>
    ResultAsync.fromPromise(
      fs.promises.writeFile(outputPath, content, {
        encoding: "utf8",
        flag: options?.overwrite ? "w" : "wx",
      }),
      (e) => `Failed to write file at ${outputPath}: ${e}`
    )
  )

export const cwd = (): {
  value: ResultAsync<string, unknown>
  join: (...paths: string[]) => ResultAsync<string, unknown>
} => {
  const join = (...paths: string[]) =>
    ResultAsync.fromSafePromise(Promise.resolve(process.cwd())).map((v) => path.join(v, ...paths))

  return { value: join(...[]), join }
}

export const copyFile = (
  src: string,
  dest: string,
  options?: {
    overwrite?: boolean
  }
): ResultAsync<void, unknown> => {
  const mode = options?.overwrite ? 0 : fs.constants.COPYFILE_EXCL

  return ResultAsync.fromPromise(
    fs.promises.copyFile(src, dest, mode),
    (e) => `Failed to copy file from ${src} to ${dest}: ${e}`
  )
}

/**
 * Converts import.meta.url to the module's directory path.
 * Usage: `const __dirname = toModuleDir(import.meta.url)`
 */
export const toModuleDir = (importMetaUrl: string): string =>
  path.dirname(fileURLToPath(importMetaUrl))
