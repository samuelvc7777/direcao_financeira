"use client";

export function RegionalSettingsCard({ locale, onChange }: { locale: string; onChange: (v: string) => void }) {
  return (
    <div className="rounded-2xl border border-[var(--border)] p-4 bg-slate-50/70 dark:bg-slate-900/30 space-y-3">
      <p className="text-sm font-semibold">Idioma e formato regional</p>
      <select className="w-full rounded-xl border border-[var(--border)] bg-white dark:bg-slate-950 px-3 py-2 text-sm" value={locale} onChange={(e) => onChange(e.target.value)}>
        <option value="pt-BR">Portugues (Brasil)</option>
        <option value="en-US">English (US)</option>
      </select>
    </div>
  );
}
