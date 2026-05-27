"use client";

import { useState } from "react";

export function SessionsSettingsCard() {
  const [done, setDone] = useState(false);
  return (
    <div className="rounded-2xl border border-[var(--border)] p-4 bg-slate-50/70 dark:bg-slate-900/30 space-y-3">
      <p className="text-sm font-semibold">Sessoes ativas</p>
      <button onClick={() => setDone(true)} className="rounded-xl border border-[var(--border)] px-3 py-2 text-xs font-bold">Encerrar outras sessoes</button>
      {done && <p className="text-xs text-emerald-600">Outras sessoes foram encerradas.</p>}
    </div>
  );
}
