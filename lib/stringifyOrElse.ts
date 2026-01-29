import stringify from "safe-stable-stringify"
import { ResultAsync, Result, okAsync } from "neverthrow"

type Params = Parameters<typeof stringify>

export default (...params: Params) =>
  okAsync().andThen(() => Result.fromThrowable(stringify)(...params))
