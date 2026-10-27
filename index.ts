#!/usr/bin/env node
import { runAll } from "./src/main.js"
import corpus, { imported } from "./tests/corpus.config.js"

// `pnpm generate`: regenerate the example corpus. real callers import { toConfig } and { runAll }
// and pass their own config.
try {
  await runAll(imported, corpus)
} catch (err) {
  // runAll throws AggregateError when one or more sections fail; surface each, then
  // exit non-zero so the failure can't pass silently.
  if (err instanceof AggregateError) {
    for (const e of err.errors) console.error(e)
  } else {
    console.error(err)
  }
  process.exit(1)
}
