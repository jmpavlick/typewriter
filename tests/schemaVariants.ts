import z from "zod"

// category: primitives
// typescript-specific primitives
export const unknown_ = z.unknown()
export const any_ = z.any()
export const void_ = z.void()
export const nan_ = z.nan()
export const undefined_ = z.undefined()
export const url_ = z.url()

// core primitives
export const string_ = z.string()
export const bool_ = z.boolean()
export const number_ = z.number()
export const null_ = z.null()

// zod primivites
export const bigInt_ = z.bigint()
export const int_ = z.int()
export const date_ = z.date()
export const datetime_ = z.iso.datetime()
export const isoDate_ = z.iso.date()
export const isoTime_ = z.iso.time()
export const email_ = z.email()
export const uuid_ = z.uuid()

// category: optional primitives
// typescript-specific optional primitives
export const optUnknown = z.unknown().optional()
export const optAny = z.any().optional()
export const optVoid = z.void().optional()
export const optNan = z.nan().optional()
export const optUndefined = z.undefined().optional()

// core optional primitives
export const optString = z.string().optional()
export const optBool = z.boolean().optional()
export const optNumber = z.number().optional()
export const optNull = z.null().optional()

// zod optional primitives
export const optBigInt = z.bigint().optional()
export const optInt = z.int().optional()
export const optDate = z.date().optional()
export const optDatetime = z.iso.datetime().optional()
export const optIsoDate = z.iso.date().optional()
export const optIsoTime = z.iso.time().optional()
export const optEmail = z.email().optional()
export const optUuid = z.uuid().optional()
export const optUrl = z.url().optional()

// category: nullable primitives
// typescript-specific nullable primitives
export const nullableUnknown = z.unknown().nullable()

// core nullable primitives
export const nullableString = z.string().nullable()
export const nullableBool = z.boolean().nullable()
export const nullableNumber = z.number().nullable()

// zod nullable primitives
export const nullableBigInt = z.bigint().nullable()
export const nullableInt = z.int().nullable()
export const nullableDate = z.date().nullable()
export const nullableDatetime = z.iso.datetime().nullable()
export const nullableIsoDate = z.iso.date().nullable()
export const nullableIsoTime = z.iso.time().nullable()
export const nullableEmail = z.email().nullable()
export const nullableUuid = z.uuid().nullable()
export const nullableUrl = z.url().nullable()

// category: nullish primitives
// typescript-specific nullish primitives
export const nullishUnknown = z.unknown().nullish()

// core nullish primitives
export const nullishString = z.string().nullish()
export const nullishBool = z.boolean().nullish()
export const nullishNumber = z.number().nullish()

// zod nullish primitives
export const nullishBigInt = z.bigint().nullish()
export const nullishInt = z.int().nullish()
export const nullishDate = z.date().nullish()
export const nullishDatetime = z.iso.datetime().nullish()
export const nullishIsoDate = z.iso.date().nullish()
export const nullishIsoTime = z.iso.time().nullish()
export const nullishEmail = z.email().nullish()
export const nullishUuid = z.uuid().nullish()
export const nullishUrl = z.url().nullish()

// category: objects
export const objHeight1 = z.object({
  unknown_,
  any_,
  void_,
  nan_,
  undefined_,
  string_,
  bool_,
  number_,
  null_,
  bigInt_,
  int_,
  date_,
  datetime_,
  isoDate_,
  isoTime_,
  email_,
  uuid_,
  url_,
  optUnknown,
  optAny,
  optVoid,
  optNan,
  optUndefined,
  optString,
  optBool,
  optNumber,
  optNull,
  optBigInt,
  optInt,
  optDate,
  optDatetime,
  optIsoDate,
  optIsoTime,
  optEmail,
  optUuid,
  optUrl,
  nullableUnknown,
  nullableString,
  nullableBool,
  nullableNumber,
  nullableBigInt,
  nullableInt,
  nullableDate,
  nullableDatetime,
  nullableIsoDate,
  nullableIsoTime,
  nullableEmail,
  nullableUuid,
  nullableUrl,
  nullishUnknown,
  nullishString,
  nullishBool,
  nullishNumber,
  nullishBigInt,
  nullishInt,
  nullishDate,
  nullishDatetime,
  nullishIsoDate,
  nullishIsoTime,
  nullishEmail,
  nullishUuid,
  nullishUrl,
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

// core array primitives
export const arrString = z.array(string_)
export const arrBool = z.array(bool_)
export const arrNumber = z.array(number_)
export const arrNull = z.array(null_)

// zod array primitives
export const arrBigInt = z.array(bigInt_)
export const arrInt = z.array(int_)
export const arrDate = z.array(date_)
export const arrDatetime = z.array(datetime_)
export const arrIsoDate = z.array(isoDate_)
export const arrIsoTime = z.array(isoTime_)
export const arrEmail = z.array(email_)
export const arrUuid = z.array(uuid_)
export const arrUrl = z.array(url_)

// typescript-specific optional array primitives
export const optArrUnknown = z.array(unknown_).optional()
export const optArrAny = z.array(any_).optional()
export const optArrVoid = z.array(void_).optional()
export const optArrNan = z.array(nan_).optional()
export const optArrUndefined = z.array(undefined_).optional()

// core optional array primitives
export const optArrString = z.array(string_).optional()
export const optArrBool = z.array(bool_).optional()
export const optArrNumber = z.array(number_).optional()
export const optArrNull = z.array(null_).optional()

// zod optional array primitives
export const optArrBigInt = z.array(bigInt_).optional()
export const optArrInt = z.array(int_).optional()
export const optArrDate = z.array(date_).optional()
export const optArrDatetime = z.array(datetime_).optional()
export const optArrIsoDate = z.array(isoDate_).optional()
export const optArrIsoTime = z.array(isoTime_).optional()
export const optArrEmail = z.array(email_).optional()
export const optArrUuid = z.array(uuid_).optional()
export const optArrUrl = z.array(url_).optional()

// typescript-specific nullable array primitives
export const nullableArrUnknown = z.array(unknown_).nullable()

// core nullable array primitives
export const nullableArrString = z.array(string_).nullable()
export const nullableArrBool = z.array(bool_).nullable()
export const nullableArrNumber = z.array(number_).nullable()

// zod nullable array primitives
export const nullableArrBigInt = z.array(bigInt_).nullable()
export const nullableArrInt = z.array(int_).nullable()
export const nullableArrDate = z.array(date_).nullable()
export const nullableArrDatetime = z.array(datetime_).nullable()
export const nullableArrIsoDate = z.array(isoDate_).nullable()
export const nullableArrIsoTime = z.array(isoTime_).nullable()
export const nullableArrEmail = z.array(email_).nullable()
export const nullableArrUuid = z.array(uuid_).nullable()
export const nullableArrUrl = z.array(url_).nullable()

// typescript-specific nullish array primitives
export const nullishArrUnknown = z.array(unknown_).nullish()

// core nullish array primitives
export const nullishArrString = z.array(string_).nullish()
export const nullishArrBool = z.array(bool_).nullish()
export const nullishArrNumber = z.array(number_).nullish()

// zod nullish array primitives
export const nullishArrBigInt = z.array(bigInt_).nullish()
export const nullishArrInt = z.array(int_).nullish()
export const nullishArrDate = z.array(date_).nullish()
export const nullishArrDatetime = z.array(datetime_).nullish()
export const nullishArrIsoDate = z.array(isoDate_).nullish()
export const nullishArrIsoTime = z.array(isoTime_).nullish()
export const nullishArrEmail = z.array(email_).nullish()
export const nullishArrUuid = z.array(uuid_).nullish()
export const nullishArrUrl = z.array(url_).nullish()

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
