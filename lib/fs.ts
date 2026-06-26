import * as fs from "fs"
import path from "path"
import { fileURLToPath } from "url"

export const readFile = (filePath: string, encoding: BufferEncoding = "utf-8"): Promise<string> =>
  fs.promises.readFile(filePath, encoding)

export const rm = (filePath: string, options?: fs.RmOptions): Promise<void> =>
  fs.promises.rm(filePath, options)

export const writeFileUtf8 = async (
  outputPath: string,
  content: string,
  options?: { overwrite?: boolean; mkdirP?: boolean }
): Promise<void> => {
  if (options?.mkdirP) {
    await fs.promises.mkdir(path.dirname(outputPath), { recursive: true })
  }
  await fs.promises.writeFile(outputPath, content, {
    encoding: "utf8",
    flag: options?.overwrite ? "w" : "wx",
  })
}

/** Converts import.meta.url to the module's directory path. */
export const toModuleDir = (importMetaUrl: string): string =>
  path.dirname(fileURLToPath(importMetaUrl))
