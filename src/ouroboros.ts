import * as path from "path"
import { type ConfigParams, packageRoot, toConfig } from "./config.js"

// ouroboros (typewriter generating its OWN bindings) always runs first inside
// runAll — possibly launched from a consumer's cwd in another repo. so root and
// outdirs are absolute, anchored at typewriter's package dir: inputs resolve and
// outputs land HERE regardless of where runAll was invoked. unchanged source →
// byte-identical regen → no working-tree churn (incl. when vendored + drift-gated).
const configParams: ConfigParams = {
  root: packageRoot,
  sections: {
    tests: {
      relativeInputPaths: ["tests/schemaVariants.ts"],
      relativeOutdir: path.join(packageRoot, "generated"),
      cleanFirst: true,
      debug: true,
      outputModuleNamespace: ["IntegrationTests"],
    },
    main: {
      relativeInputPaths: ["src/config.ts"],
      relativeOutdir: path.join(packageRoot, "platformWorkerConfig"),
      cleanFirst: true,
      debug: true,
      outputModuleNamespace: [],
    },
  },
}

export default toConfig(configParams)
