"use client";

import { User } from "lucide-react";
import type { SettingsUser } from "@/lib/services/settings/settings-service";

export function ProfileSettingsCard({ user }: { user: SettingsUser }) {
  return (
    <div className="rounded-2xl border border-[var(--border)] p-4 bg-slate-50/70 dark:bg-slate-900/30">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-full bg-indigo-600 text-white flex items-center justify-center font-bold">
          {user.name.slice(0, 1).toUpperCase()}
        </div>
        <div>
          <p className="text-sm font-bold">{user.name}</p>
          <p className="text-xs text-slate-500 dark:text-slate-400">{user.email}</p>
        </div>
        <User className="ml-auto h-4 w-4 text-slate-400" />
      </div>
    </div>
  );
}
