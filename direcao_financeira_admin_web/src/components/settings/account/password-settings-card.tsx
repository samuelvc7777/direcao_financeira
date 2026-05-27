"use client";

import { useState } from "react";
import { KeyRound } from "lucide-react";

export function PasswordSettingsCard() {
  const [saved, setSaved] = useState(false);
  return (
    <div className="rounded-2xl border border-[var(--border)] p-4 bg-slate-50/70 dark:bg-slate-900/30 space-y-3">
      <div className="flex items-center gap-2"><KeyRound className="h-4 w-4 text-slate-500" /><p className="text-sm font-semibold">Trocar senha</p></div>
      <button onClick={() => setSaved(true)} className="rounded-xl bg-indigo-600 text-white px-3 py-2 text-xs font-bold">Solicitar troca de senha</button>
      {saved && <p className="text-xs text-emerald-600">Solicitacao registrada com sucesso.</p>}
    </div>
  );
}
