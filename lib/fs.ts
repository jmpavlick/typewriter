import { ResultAsync } from "neverthrow"
import * as fs from "fs"

export const readFile = (
  path: string,
  encoding: BufferEncoding = "utf-8"
): ResultAsync<string, unknown> =>
  ResultAsync.fromPromise(
    fs.promises.readFile(path, encoding),
    (e) => `Failed to read file at ${path}: ${e}`
  )

export const writeFile = (
  path: string,
  content: string,
  encoding: BufferEncoding = "utf-8"
): ResultAsync<void, unknown> =>
  ResultAsync.fromPromise(
    fs.promises.writeFile(path, content, encoding),
    (e) => `Failed to write file at ${path}: ${e}`
  )

export const rm = (
  path: string,
  options?: fs.RmOptions
): ResultAsync<void, unknown> =>
  ResultAsync.fromPromise(
    fs.promises.rm(path, options),
    (e) => `Failed to remove ${path}: ${e}`
  )

export const mkdir = (
  path: string,
  options?: fs.MakeDirectoryOptions
): ResultAsync<string | undefined, unknown> =>
  ResultAsync.fromPromise(
    fs.promises.mkdir(path, options),
    (e) => `Failed to create directory at ${path}: ${e}`
  )
