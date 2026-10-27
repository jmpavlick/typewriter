import * as path from "path"
import { packageRoot, toConfig } from "../src/config.js"

// the example corpus → generated/IntegrationTests/*, which tests/Test/*.elm import and the compile
// gate builds. rooted at the package dir (inputs AND outdir absolute) so `pnpm generate` lands here
// no matter where it's launched from.

const outdir = path.join(packageRoot, "generated")

// a config other configs import from; shares the corpus's outdir AND namespace
export const imported = toConfig({
  root: packageRoot,
  sections: {
    imported: {
      relativeInputPaths: ["tests/importedVariants.ts", "tests/defaultExport.ts"],
      relativeOutdir: outdir,
      outputModuleNamespace: ["IntegrationTests"],
    },
  },
})

export default toConfig({
  root: packageRoot,
  sections: {
    corpus: {
      relativeInputPaths: ["tests/schemaVariants.ts"],
      relativeOutdir: outdir,
      outputModuleNamespace: ["IntegrationTests"],
    },
    importing: {
      relativeInputPaths: ["tests/importingVariants.ts"],
      relativeOutdir: outdir,
      outputModuleNamespace: ["IntegrationTests"],
      imports: [{ from: imported, names: ["sharedLocale", "sharedChannel", "sharedSlot"] }],
    },
  },
})
