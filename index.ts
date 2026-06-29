#!/usr/bin/env node
import { runAll } from "./src/main.js"

// typewriter generating its own bindings: runAll always runs ouroboros first, and
// here we pass no extra configs. callers that want to generate from their own
// schemas import { runAll } and pass their config(s) — see src/main.ts.
try {
  await runAll()
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
