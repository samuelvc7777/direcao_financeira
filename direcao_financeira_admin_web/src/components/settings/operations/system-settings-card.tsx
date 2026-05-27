"use client";

export function SystemSettingsCard() {
  return (
    <div className="rounded-2xl border border-[var(--border)] p-4 bg-slate-50/70 dark:bg-slate-900/30 space-y-1">
      <p className="text-sm font-semibold">Sistema</p>
      <p className="text-xs text-slate-500">Versao: 0.1.0</p>
      <p className="text-xs text-slate-500">Changelog: melhoria da tela de configuracoes.</p>
    </div>
  );
}
