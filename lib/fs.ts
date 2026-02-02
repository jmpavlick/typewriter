import { okAsync, ResultAsync } from "neverthrow"
import * as fs from "fs"
import path from "path"

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
