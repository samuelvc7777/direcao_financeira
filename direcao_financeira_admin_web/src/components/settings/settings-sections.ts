import { Bell, Globe, LockKeyhole, Palette, Sparkles } from "lucide-react";

export const settingsSections = [
  { id: "account", title: "Conta e seguranca" },
  { id: "preferences", title: "Preferencias" },
  { id: "operations", title: "Operacoes" },
] as const;

export const preferenceCards = [
  { key: "billingAlerts", title: "Alertas de faturamento", icon: Bell },
  { key: "weeklyDigest", title: "Resumo semanal", icon: Sparkles },
  { key: "compactTables", title: "Tabelas compactas", icon: Palette },
  { key: "autoRefreshDashboard", title: "Auto refresh", icon: Globe },
  { key: "maintenanceMode", title: "Modo manutencao", icon: LockKeyhole },
] as const;
