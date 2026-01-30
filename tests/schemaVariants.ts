import z from "zod"

// category: primitives
// typescript-specific primitives
export const unknown_ = z.unknown()
export const any_ = z.any()
export const void_ = z.void()
export const nan_ = z.nan()
export const undefined_ = z.undefined()
export const symbol_ = z.symbol()

// core primitives
export const string_ = z.string()
export const bool_ = z.boolean()
export const number_ = z.number()
export const null_ = z.null()

// zod primivites
export const bigint_ = z.bigint()
export const int_ = z.int()
export const date_ = z.date()
export const email_ = z.email()
export const uuid_ = z.uuid()

// category: optional primitives
// typescript-specific optional primitives
export const optUnknown = z.unknown().optional()
export const optAny = z.any().optional()
export const optVoid = z.void().optional()
export const optNan = z.nan().optional()
export const optUndefined = z.undefined().optional()
export const optSymbol = z.symbol().optional()

// core optional primitives
export const optString = z.string().optional()
export const optBool = z.boolean().optional()
export const optNumber = z.number().optional()
export const optNull = z.null().optional()

// zod optional primitives
export const optBigint = z.bigint().optional()
export const optInt = z.int().optional()
export const optDate = z.date().optional()
export const optEmail = z.email().optional()
export const optUuid = z.uuid().optional()

// category: nullable primitives
// typescript-specific nullable primitives
export const nullableUnknown = z.unknown().nullable()
export const nullableSymbol = z.symbol().nullable()

// core nullable primitives
export const nullableString = z.string().nullable()
export const nullableBool = z.boolean().nullable()
export const nullableNumber = z.number().nullable()

// zod nullable primitives
export const nullableBigint = z.bigint().nullable()
export const nullableInt = z.int().nullable()
export const nullableDate = z.date().nullable()
export const nullableEmail = z.email().nullable()
export const nullableUuid = z.uuid().nullable()

// category: nullish primitives
// typescript-specific nullish primitives
export const nullishUnknown = z.unknown().nullish()
export const nullishSymbol = z.symbol().nullish()

// core nullish primitives
export const nullishString = z.string().nullish()
export const nullishBool = z.boolean().nullish()
export const nullishNumber = z.number().nullish()

// zod nullish primitives
export const nullishBigint = z.bigint().nullish()
export const nullishInt = z.int().nullish()
export const nullishDate = z.date().nullish()
export const nullishEmail = z.email().nullish()
export const nullishUuid = z.uuid().nullish()

// category: objects
export const objHeight1 = z.object({
  unknown_,
  any_,
  void_,
  nan_,
  undefined_,
  symbol_,
  string_,
  bool_,
  number_,
  null_,
  bigint_,
  int_,
  date_,
  email_,
  uuid_,
  optUnknown,
  optAny,
  optVoid,
  optNan,
  optUndefined,
  optSymbol,
  optString,
  optBool,
  optNumber,
  optNull,
  optBigint,
  optInt,
  optDate,
  optEmail,
  optUuid,
  nullableUnknown,
  nullableSymbol,
  nullableString,
  nullableBool,
  nullableNumber,
  nullableBigint,
  nullableInt,
  nullableDate,
  nullableEmail,
  nullableUuid,
  nullishUnknown,
  nullishSymbol,
  nullishString,
  nullishBool,
  nullishNumber,
  nullishBigint,
  nullishInt,
  nullishDate,
  nullishEmail,
  nullishUuid,
})

export const objHeight2 = z.object({
  obj: objHeight1,
  optObj: z.optional(objHeight1),
  nullableObj: z.nullable(objHeight1),
  nullishObj: z.nullish(objHeight1),
})

// category: arrays
// typescript-specific array primitives
export const arrUnknown = z.array(unknown_)
export const arrAny = z.array(any_)
export const arrVoid = z.array(void_)
export const arrNan = z.array(nan_)
export const arrUndefined = z.array(undefined_)
export const arrSymbol = z.array(symbol_)

// core array primitives
export const arrString = z.array(string_)
export const arrBool = z.array(bool_)
export const arrNumber = z.array(number_)
export const arrNull = z.array(null_)

// zod array primitives
export const arrBigint = z.array(bigint_)
export const arrInt = z.array(int_)
export const arrDate = z.array(date_)
export const arrEmail = z.array(email_)
export const arrUuid = z.array(uuid_)

// typescript-specific optional array primitives
export const optArrUnknown = z.array(unknown_).optional()
export const optArrAny = z.array(any_).optional()
export const optArrVoid = z.array(void_).optional()
export const optArrNan = z.array(nan_).optional()
export const optArrUndefined = z.array(undefined_).optional()
export const optArrSymbol = z.array(symbol_).optional()

// core optional array primitives
export const optArrString = z.array(string_).optional()
export const optArrBool = z.array(bool_).optional()
export const optArrNumber = z.array(number_).optional()
export const optArrNull = z.array(null_).optional()

// zod optional array primitives
export const optArrBigint = z.array(bigint_).optional()
export const optArrInt = z.array(int_).optional()
export const optArrDate = z.array(date_).optional()
export const optArrEmail = z.array(email_).optional()
export const optArrUuid = z.array(uuid_).optional()

// typescript-specific nullable array primitives
export const nullableArrUnknown = z.array(unknown_).nullable()
export const nullableArrSymbol = z.array(symbol_).nullable()

// core nullable array primitives
export const nullableArrString = z.array(string_).nullable()
export const nullableArrBool = z.array(bool_).nullable()
export const nullableArrNumber = z.array(number_).nullable()

// zod nullable array primitives
export const nullableArrBigint = z.array(bigint_).nullable()
export const nullableArrInt = z.array(int_).nullable()
export const nullableArrDate = z.array(date_).nullable()
export const nullableArrEmail = z.array(email_).nullable()
export const nullableArrUuid = z.array(uuid_).nullable()

// typescript-specific nullish array primitives
export const nullishArrUnknown = z.array(unknown_).nullish()
export const nullishArrSymbol = z.array(symbol_).nullish()

// core nullish array primitives
export const nullishArrString = z.array(string_).nullish()
export const nullishArrBool = z.array(bool_).nullish()
export const nullishArrNumber = z.array(number_).nullish()

// zod nullish array primitives
export const nullishArrBigint = z.array(bigint_).nullish()
export const nullishArrInt = z.array(int_).nullish()
export const nullishArrDate = z.array(date_).nullish()
export const nullishArrEmail = z.array(email_).nullish()
export const nullishArrUuid = z.array(uuid_).nullish()

// category: real-world types (a mix of everything)
const nonAdminGroups = z.union([z.literal("user"), z.literal("moderator")])
export const user = z.object({
  id: z.uuid(),
  identities: z.array(
    z.object({
      email: z.email(),
      nickName: z.string().optional(),
      firstName: z.string().optional(),
      lastName: z.string().optional(),
      tel: z.string().optional(),
      avatarUrl: z.string().optional(),
      identityProvider: z.union([
        z.literal("github"),
        z.literal("facebook"),
        z.literal("google"),
        z.literal("email"),
      ]),
    })
  ),
  permissions: z.nullish(
    z.object({
      group: z.union([nonAdminGroups, z.literal("admin")]),
      canReadPosts: z.nullish(z.boolean()),
      canEditOwnPosts: z.nullish(z.boolean()),
      canWritePosts: z.nullish(z.boolean()),
      canEditPostsForMembersOfGroups: z.nullish(z.array(nonAdminGroups)),
    })
  ),
  signedUpAt: z.date(),
  lastLoggedInAt: z.nullable(z.date()),
})

export const simpleUser = z.object({
  id: z.string(),
  username: z.string(),
  emailAddresses: z.array(z.string()),
  phoneNumber: z.optional(z.string()),
  prefs: z.object({
    lightMode: z.boolean(),
    theme: z.string(),
  }),
})
