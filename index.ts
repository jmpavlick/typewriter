#!/usr/bin/env node
import { runAll } from "./src/main.js"
import ouroboros from "./src/ouroboros.js"

// typewriter generating its own bindings: the CLI is the ouroboros path — it
// regenerates typewriter's own Elm bindings (platformWorkerConfig/, generated/).
// callers that want to generate from their own schemas import { runAll } and pass
// their config(s); runAll no longer self-gens, so consumer runs never write inside
// this package — see src/main.ts.
try {
  await runAll(ouroboros)
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
