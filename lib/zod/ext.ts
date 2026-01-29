import z from "zod"
import { ResultAsync, okAsync, errAsync } from "neverthrow"

const parseResultAsync =
  <T extends z.ZodType>(schema: T) =>
  (
    input: unknown,
    params?: z.core.ParseContext<z.core.$ZodIssue> | undefined
  ): ResultAsync<z.core.output<T>, z.ZodError<z.core.output<T>>> =>
    ResultAsync.fromSafePromise(schema.safeParseAsync(input)).andThen((zodResult) =>
      zodResult.success ? okAsync(zodResult.data) : errAsync(zodResult.error)
    )

export default { parseResultAsync }
