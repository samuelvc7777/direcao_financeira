"use client";

import { useState } from "react";

export function DeleteAccountDialog() {
  const [confirm, setConfirm] = useState(false);
  const [done, setDone] = useState(false);

  return (
    <div className="rounded-2xl border border-red-200 dark:border-red-900/30 p-4 bg-red-50/60 dark:bg-red-900/10 space-y-3">
      <p className="text-sm font-semibold text-red-700 dark:text-red-400">Excluir conta</p>
      <label className="flex items-center gap-2 text-xs">
        <input type="checkbox" checked={confirm} onChange={(e) => setConfirm(e.target.checked)} />
        Confirmo que esta acao e irreversivel.
      </label>
      <button disabled={!confirm} onClick={() => setDone(true)} className="rounded-xl bg-red-600 text-white px-3 py-2 text-xs font-bold disabled:opacity-50">Confirmar exclusao</button>
      {done && <p className="text-xs text-red-700 dark:text-red-400">Exclusao confirmada (fluxo de demonstracao).</p>}
    </div>
  );
}
