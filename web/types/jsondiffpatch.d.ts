declare module 'jsondiffpatch' {
  export const diff: (left: any, right: any) => any
  export const patch: (left: any, delta: any) => any
  export const unpatch: (right: any, delta: any) => any
  export const formatters: {
    html: {
      format: (delta: any, left: any) => string
      hideUnchanged: (node?: any, delay?: number) => void
      showUnchanged: (show?: boolean, node?: any, delay?: number) => void
    }
    annotated: {
      format: (delta: any, left: any) => string
    }
    console: {
      format: (delta: any, left: any) => string
    }
  }
}
