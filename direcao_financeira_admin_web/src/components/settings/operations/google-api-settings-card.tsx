"use client";

import { Loader2, Save } from "lucide-react";
import type { ActionFeedback } from "@/lib/services/settings/types";

type GoogleApiSettingsCardProps = {
  value: string;
  onChange: (value: string) => void;
  onSave: () => Promise<void>;
  feedback: ActionFeedback;
  saving: boolean;
};

export function GoogleApiSettingsCard({
  value,
  onChange,
  onSave,
  feedback,
  saving,
}: GoogleApiSettingsCardProps) {
  return (
    <div className="rounded-2xl border border-[var(--border)] p-4 bg-slate-50/70 dark:bg-slate-900/30 space-y-3">
      <p className="text-sm font-semibold">API Google (OCR e Print)</p>
      <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder="Cole a chave da API Google"
        className="w-full rounded-xl border border-[var(--border)] bg-white dark:bg-slate-950 px-3 py-2 text-sm"
      />
      <button
        onClick={() => void onSave()}
        disabled={saving}
        className="rounded-xl bg-indigo-600 text-white px-3 py-2 text-xs font-bold inline-flex items-center gap-2 disabled:opacity-70"
      >
        {saving ? <Loader2 className="h-3 w-3 animate-spin" /> : <Save className="h-3 w-3" />}
        Salvar API Google
      </button>
      {feedback.message && (
        <p className={`text-xs ${feedback.state === "error" ? "text-red-600" : "text-emerald-600"}`}>
          {feedback.message}
        </p>
      )}
    </div>
  );
}
