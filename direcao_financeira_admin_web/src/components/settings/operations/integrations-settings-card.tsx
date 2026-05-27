"use client";

import { RefreshCw } from "lucide-react";

export function IntegrationsSettingsCard() {
  return (
    <div className="rounded-2xl border border-[var(--border)] p-4 bg-slate-50/70 dark:bg-slate-900/30 space-y-3">
      <p className="text-sm font-semibold">Integracoes</p>
      <div className="text-xs text-slate-500">API Principal: ativa</div>
      <button className="rounded-xl border border-[var(--border)] px-3 py-2 text-xs font-bold inline-flex items-center gap-2"><RefreshCw className="h-3 w-3" />Reconectar</button>
    </div>
  );
}
