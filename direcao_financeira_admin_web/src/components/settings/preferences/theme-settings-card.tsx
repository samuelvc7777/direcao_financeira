"use client";

import { SunMoon } from "lucide-react";

export function ThemeSettingsCard({ value, onChange }: { value: string; onChange: (v: string) => void }) {
  return (
    <div className="rounded-2xl border border-[var(--border)] p-4 bg-slate-50/70 dark:bg-slate-900/30 space-y-3">
      <div className="flex items-center gap-2"><SunMoon className="h-4 w-4 text-slate-500" /><p className="text-sm font-semibold">Tema</p></div>
      <select className="w-full rounded-xl border border-[var(--border)] bg-white dark:bg-slate-950 px-3 py-2 text-sm" value={value} onChange={(e) => onChange(e.target.value)}>
        <option value="system">Sistema</option>
        <option value="light">Claro</option>
        <option value="dark">Escuro</option>
      </select>
    </div>
  );
}
