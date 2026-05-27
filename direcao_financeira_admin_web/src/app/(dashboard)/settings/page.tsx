"use client";

import { useEffect, useMemo, useState } from "react";
import { Loader2, Save } from "lucide-react";
import { ResponsiveContainer } from "@/components/layout/responsive-container";
import { SettingsSectionCard } from "@/components/settings/settings-section-card";
import { ProfileSettingsCard } from "@/components/settings/account/profile-settings-card";
import { PasswordSettingsCard } from "@/components/settings/account/password-settings-card";
import { SessionsSettingsCard } from "@/components/settings/account/sessions-settings-card";
import { DeleteAccountDialog } from "@/components/settings/account/delete-account-dialog";
import { ThemeSettingsCard } from "@/components/settings/preferences/theme-settings-card";
import { RegionalSettingsCard } from "@/components/settings/preferences/regional-settings-card";
import { NotificationSettingsCard } from "@/components/settings/preferences/notification-settings-card";
import { IntegrationsSettingsCard } from "@/components/settings/operations/integrations-settings-card";
import { SystemSettingsCard } from "@/components/settings/operations/system-settings-card";
import { SupportSettingsCard } from "@/components/settings/operations/support-settings-card";
import { GoogleApiSettingsCard } from "@/components/settings/operations/google-api-settings-card";
import { idleFeedback, loadingFeedback } from "@/lib/services/settings/settings-feedback";
import { loadCompanySettings, loadCurrentUser, loadPreferences, saveCompanyPhone, saveGoogleApiKey, savePreferences, type SettingsPreferences, type SettingsUser } from "@/lib/services/settings/settings-service";
import type { ActionFeedback } from "@/lib/services/settings/types";

function toWhatsappUrl(phone: string) {
  const digits = phone.replace(/\D/g, "");
  if (!digits) return "https://wa.me/";
  return `https://wa.me/55${digits}`;
}

export default function SettingsPage() {
  const [user, setUser] = useState<SettingsUser | null>(null);
  const [loading, setLoading] = useState(true);
  const [companyPhone, setCompanyPhone] = useState("");
  const [googleApiKey, setGoogleApiKey] = useState("");
  const [preferences, setPreferences] = useState<SettingsPreferences>({ theme: "system", locale: "pt-BR", billingNotifications: true });
  const [profileFeedback, setProfileFeedback] = useState<ActionFeedback>(idleFeedback());
  const [googleApiFeedback, setGoogleApiFeedback] = useState<ActionFeedback>(idleFeedback());
  const [preferencesFeedback, setPreferencesFeedback] = useState<ActionFeedback>(idleFeedback());
  const [savingGoogleApi, setSavingGoogleApi] = useState(false);

  useEffect(() => {
    async function run() {
      try {
        const [me, localPrefs, companySettings] = await Promise.all([
          loadCurrentUser(),
          Promise.resolve(loadPreferences()),
          loadCompanySettings(),
        ]);
        setUser(me);
        setCompanyPhone(me.companyPhone ?? "");
        setGoogleApiKey(companySettings.googleApiKey ?? "");
        setPreferences(localPrefs);
      } finally {
        setLoading(false);
      }
    }
    void run();
  }, []);

  async function handleSaveCompanyPhone() {
    if (!user) return;
    setProfileFeedback(loadingFeedback());
    const result = await saveCompanyPhone(user.id, companyPhone);
    setProfileFeedback(result);
  }

  async function handleSaveGoogleApiKey() {
    if (savingGoogleApi) return;
    setSavingGoogleApi(true);
    setGoogleApiFeedback(loadingFeedback());
    const result = await saveGoogleApiKey(googleApiKey);
    setGoogleApiFeedback(result);
    setSavingGoogleApi(false);
  }

  function handleSavePreferences() {
    setPreferencesFeedback(loadingFeedback());
    const result = savePreferences(preferences);
    setPreferencesFeedback(result);
  }

  const whatsappUrl = useMemo(() => toWhatsappUrl(companyPhone), [companyPhone]);

  if (loading || !user) {
    return <div className="flex h-[60vh] items-center justify-center"><Loader2 className="h-10 w-10 animate-spin text-indigo-600" /></div>;
  }

  return (
    <ResponsiveContainer>
      <div className="space-y-6 py-6">
        <SettingsSectionCard title="Conta e seguranca" description="Gerencie perfil, senha, sessoes e exclusao de conta.">
          <div className="grid gap-4 md:grid-cols-2">
            <ProfileSettingsCard user={user} />
            <PasswordSettingsCard />
            <SessionsSettingsCard />
            <DeleteAccountDialog />
          </div>
          <div className="rounded-2xl border border-[var(--border)] p-4 bg-slate-50/70 dark:bg-slate-900/30 space-y-3">
            <p className="text-sm font-semibold">Numero da empresa</p>
            <input value={companyPhone} onChange={(e) => setCompanyPhone(e.target.value)} className="w-full rounded-xl border border-[var(--border)] bg-white dark:bg-slate-950 px-3 py-2 text-sm" />
            <button onClick={handleSaveCompanyPhone} className="rounded-xl bg-indigo-600 text-white px-3 py-2 text-xs font-bold inline-flex items-center gap-2"><Save className="h-3 w-3" />Salvar numero</button>
            {profileFeedback.message && <p className={`text-xs ${profileFeedback.state === "error" ? "text-red-600" : "text-emerald-600"}`}>{profileFeedback.message}</p>}
          </div>
        </SettingsSectionCard>

        <SettingsSectionCard title="Preferencias" description="Ajustes pessoais do admin web.">
          <div className="grid gap-4 md:grid-cols-3">
            <ThemeSettingsCard value={preferences.theme} onChange={(v) => setPreferences((s) => ({ ...s, theme: v as SettingsPreferences["theme"] }))} />
            <RegionalSettingsCard locale={preferences.locale} onChange={(v) => setPreferences((s) => ({ ...s, locale: v as SettingsPreferences["locale"] }))} />
            <NotificationSettingsCard enabled={preferences.billingNotifications} onToggle={() => setPreferences((s) => ({ ...s, billingNotifications: !s.billingNotifications }))} />
          </div>
          <div className="flex items-center gap-3">
            <button onClick={handleSavePreferences} className="rounded-xl bg-indigo-600 text-white px-3 py-2 text-xs font-bold inline-flex items-center gap-2"><Save className="h-3 w-3" />Salvar preferencias</button>
            {preferencesFeedback.message && <p className={`text-xs ${preferencesFeedback.state === "error" ? "text-red-600" : "text-emerald-600"}`}>{preferencesFeedback.message}</p>}
          </div>
        </SettingsSectionCard>

        <SettingsSectionCard title="Integracoes, sistema e suporte" description="Operacao do ambiente e canais de ajuda.">
          <GoogleApiSettingsCard
            value={googleApiKey}
            onChange={setGoogleApiKey}
            onSave={handleSaveGoogleApiKey}
            feedback={googleApiFeedback}
            saving={savingGoogleApi}
          />
          <div className="grid gap-4 md:grid-cols-3">
            <IntegrationsSettingsCard />
            <SystemSettingsCard />
            <SupportSettingsCard whatsappUrl={whatsappUrl} />
          </div>
        </SettingsSectionCard>
      </div>
    </ResponsiveContainer>
  );
}
