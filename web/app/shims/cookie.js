// ESM shim for the 'cookie' package (CJS-only, breaks Vite browser bundling)
import cookiePkg from 'cookie'

export const parse = cookiePkg.parse ?? cookiePkg.parseCookie
export const serialize = cookiePkg.serialize ?? cookiePkg.stringifySetCookie

export default cookiePkg
