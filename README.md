# typewriter

is a npm package for turning Zod schemas into Elm types + decoders.

## quickstart

```
npm install @jmpavlick/typewriter
npx typewriter init
npx typewriter generate
```

will

- install the npm package
- give you a sample module with a sample schema, and a starting-point config that references that sample module
- generate Elm types and decoders for that module's exported Zod schemas


## careful, now

- unions, literals, a handful of other things aren't supported yet but should be soon
- Configuration via Elm should be supported soon and will provide for more finely-grained control over the output of the codegen
- still super alpha in here
