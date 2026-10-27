import * as path from "path"
import { packageRoot, toConfig } from "../src/config.js"

// the example corpus → generated/IntegrationTests/*, which tests/Test/*.elm import and the compile
// gate builds. rooted at the package dir (inputs AND outdir absolute) so `pnpm generate` lands here
// no matter where it's launched from.
export default toConfig({
  root: packageRoot,
  sections: {
    corpus: {
      relativeInputPaths: ["tests/schemaVariants.ts"],
      relativeOutdir: path.join(packageRoot, "generated"),
      outputModuleNamespace: ["IntegrationTests"],
    },
  },
})
