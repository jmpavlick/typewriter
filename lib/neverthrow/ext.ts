import { ResultAsync, okAsync, errAsync } from "neverthrow"
import crypto from "crypto"
import stringify from "safe-stable-stringify"

export const ternary = <T, E, U = T>(toBoolean: (t: T) => boolean) => {
  const exec =
    (bindFromTrue: (t: T) => ResultAsync<U, E>) =>
    (bindFromFalse: (t: T) => ResultAsync<U, E>) =>
    (input: T) => (toBoolean(input) ? bindFromTrue(input) : bindFromFalse(input))

  const liftOk = <V>(value: V | ResultAsync<V, E> | ResultAsync<V, never>) =>
    value instanceof ResultAsync ? value.mapErr((nvr) => nvr as E) : okAsync<V, E>(value)

  const toWhenFalse = (okThunk: (t: T) => ResultAsync<U, E>) => ({
    whenFalse: (fnOrErr: ResultAsync<never, E> | ((t: T) => U | ResultAsync<U, E | never>)) =>
      typeof fnOrErr === "function"
        ? exec(okThunk)((v) => liftOk(fnOrErr(v)))
        : (fnOrErr as ResultAsync<U, E>),
  })

  return {
    whenTrue: <V extends U>(value: V | ResultAsync<V, E> | ResultAsync<V, never>) =>
      toWhenFalse(() => liftOk<V>(value)),
    whenFalse: (fnOrErr: ResultAsync<never, E> | ((t: T) => U | ResultAsync<U, E | never>)) =>
      typeof fnOrErr === "function"
        ? exec((t) => okAsync(t as unknown as U))((v) => liftOk(fnOrErr(v)))
        : exec((t) => okAsync(t as unknown as U))(() => fnOrErr.map((nvr) => nvr as U)),
  }
}

export const parseJsonSafe = (jsonStr: string) =>
  ResultAsync.fromPromise(Promise.resolve(JSON.parse(jsonStr)), (e) => e)

export const doAsync = <T>(syncExec: () => T): ResultAsync<T, unknown> =>
  ResultAsync.fromPromise(Promise.resolve(syncExec()), (e) => e)

export const md5Async = (obj: unknown): ResultAsync<string, unknown> =>
  doAsync(() => crypto.createHash("md5").update(stringify(obj!)).digest("hex"))
