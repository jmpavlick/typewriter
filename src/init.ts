import * as fs from "../lib/fs.js"
import path from "path"
import { ResultAsync } from "neverthrow"

export const init: ResultAsync<void, unknown> = (() => {
  const __dirname = fs.toModuleDir(import.meta.url)
  const templatesDir = path.join(__dirname, "..", "..", "templates")

  return fs
    .cwd()
    .andThrough((targetDir) => fs.mkdir("./.typewriter"))
    .andThen((targetDir) =>
      ResultAsync.combineWithAllErrors([
        fs.copyFile(
          path.join(templatesDir, "sampleSchema.ts"),
          path.join(targetDir, "sampleSchema.ts"),
          { overwrite: false }
        ),
        fs.copyFile(
          path.join(templatesDir, "typewriter.config.ts"),
          path.join(targetDir, "typewriter.config.ts"),
          { overwrite: false }
        ),
      ]).map(() => {})
    )
})()
