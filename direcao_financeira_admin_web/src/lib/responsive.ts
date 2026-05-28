export const viewport = {
  mobile: 480,
  tablet: 768,
  desktop: 1024,
  wide: 1280,
} as const;

export type ViewportKey = keyof typeof viewport;
