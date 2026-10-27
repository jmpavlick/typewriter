import z from "zod"

// a lone default export generates under the file's name: `DefaultExport.elm`
export default z.enum(["on", "off"])
