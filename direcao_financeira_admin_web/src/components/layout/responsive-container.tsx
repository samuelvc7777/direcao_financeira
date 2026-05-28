import type { ReactNode } from "react";

export function ResponsiveContainer({ children }: { children: ReactNode }) {
  return <section className="page-shell">{children}</section>;
}
