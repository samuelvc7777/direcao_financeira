"use client";

export function SupportSettingsCard({ whatsappUrl }: { whatsappUrl: string }) {
  return (
    <div className="rounded-2xl border border-[var(--border)] p-4 bg-slate-50/70 dark:bg-slate-900/30 space-y-2">
      <p className="text-sm font-semibold">Suporte</p>
      <a href={whatsappUrl} target="_blank" rel="noreferrer" className="block text-xs text-indigo-600">Contato via WhatsApp</a>
      <a href="mailto:suporte@direcaofinanceira.com" className="block text-xs text-indigo-600">Contato por email</a>
      <a href="/help-videos" className="block text-xs text-indigo-600">Central de ajuda</a>
    </div>
  );
}
