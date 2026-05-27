"use client";

export function NotificationSettingsCard({ enabled, onToggle }: { enabled: boolean; onToggle: () => void }) {
  return (
    <div className="rounded-2xl border border-[var(--border)] p-4 bg-slate-50/70 dark:bg-slate-900/30 space-y-3">
      <p className="text-sm font-semibold">Notificacoes de faturamento</p>
      <button onClick={onToggle} className="rounded-xl border border-[var(--border)] px-3 py-2 text-xs font-bold">
        {enabled ? "Ativado" : "Desativado"}
      </button>
    </div>
  );
}
