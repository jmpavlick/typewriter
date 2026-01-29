/** committing crimes: fucking with the prototype chain so that all errors are spreadable by default
    i'm not sure if this is always a good idea or not but so far, so good
    so if you're reading this codebase and looking for something to criticize: start here ;)
 */
;(function patchError() {
  if ((Error as any)._isPatched) return

  const OriginalError = Error

  ;(globalThis as any).Error = function Error(message?: string, options?: ErrorOptions) {
    const err = new OriginalError(message, options)

    // get all props (not just the standard ones)
    for (const key of Object.getOwnPropertyNames(err)) {
      const descriptor = Object.getOwnPropertyDescriptor(err, key)

      // skip if enumerable or obviously non-serializable
      if (!descriptor || descriptor.enumerable || typeof descriptor.value === "function") {
        continue
      }

      // make it enumerable
      Object.defineProperty(err, key, {
        ...descriptor,
        enumerable: true,
      })
    }

    return err
  } as any as ErrorConstructor
  ;(globalThis as any).Error.prototype = OriginalError.prototype
  ;(globalThis.Error as any)._isPatched = true
})()

export {}
