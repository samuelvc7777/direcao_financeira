import { fetchApi } from "@/lib/api/client";
import { errorFeedback, successFeedback } from "./settings-feedback";
import type { ActionFeedback } from "./types";

const PREFERENCES_KEY = "admin-settings-preferences";

export interface SettingsUser {
  id: string;
  name: string;
  email: string;
  role: string;
  companyPhone?: string | null;
}

export interface CompanySettings {
  id: number;
  supportPhone?: string | null;
  googleApiKey?: string | null;
}

export interface SettingsPreferences {
  theme: "system" | "light" | "dark";
  locale: "pt-BR" | "en-US";
  billingNotifications: boolean;
}

export async function loadCurrentUser(): Promise<SettingsUser> {
  return (await fetchApi("/auth/me")) as SettingsUser;
}

export async function saveCompanyPhone(userId: string, companyPhone: string): Promise<ActionFeedback> {
  try {
    await fetchApi(`/user/${userId}`, {
      method: "PATCH",
      body: JSON.stringify({ companyPhone: companyPhone.trim() || null }),
    });
    return successFeedback("Numero da empresa atualizado com sucesso.");
  } catch (error) {
    return errorFeedback(error instanceof Error ? error.message : "Erro ao salvar numero da empresa.");
  }
}

export async function loadCompanySettings(): Promise<CompanySettings> {
  return (await fetchApi("/admin/company-settings")) as CompanySettings;
}

export async function saveGoogleApiKey(googleApiKey: string): Promise<ActionFeedback> {
  const trimmed = googleApiKey.trim();
  if (!trimmed) {
    return errorFeedback("Informe uma API Google valida.");
  }

  try {
    await fetchApi("/admin/company-settings", {
      method: "PATCH",
      body: JSON.stringify({ googleApiKey: trimmed }),
    });
    return successFeedback("API Google salva com sucesso.");
  } catch (error) {
    return errorFeedback(error instanceof Error ? error.message : "Erro ao salvar API Google.");
  }
}

export function loadPreferences(): SettingsPreferences {
  if (typeof window === "undefined") {
    return { theme: "system", locale: "pt-BR", billingNotifications: true };
  }

  try {
    const raw = localStorage.getItem(PREFERENCES_KEY);
    if (!raw) return { theme: "system", locale: "pt-BR", billingNotifications: true };
    const parsed = JSON.parse(raw) as SettingsPreferences;
    return {
      theme: parsed.theme ?? "system",
      locale: parsed.locale ?? "pt-BR",
      billingNotifications: Boolean(parsed.billingNotifications),
    };
  } catch {
    return { theme: "system", locale: "pt-BR", billingNotifications: true };
  }
}

export function savePreferences(preferences: SettingsPreferences): ActionFeedback {
  try {
    if (typeof window !== "undefined") {
      localStorage.setItem(PREFERENCES_KEY, JSON.stringify(preferences));
    }
    return successFeedback("Preferencias salvas com sucesso.");
  } catch {
    return errorFeedback("Nao foi possivel salvar preferencias no dispositivo.");
  }
}
