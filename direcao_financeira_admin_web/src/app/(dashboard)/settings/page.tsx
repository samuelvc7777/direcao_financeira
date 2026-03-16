'use client';

import { useMemo, useState } from 'react';
import {
  Settings,
  ShieldCheck,
  Bell,
  Palette,
  Database,
  Globe,
  CheckCircle2,
  Sparkles,
  Save,
  Clock3,
  LockKeyhole,
} from 'lucide-react';

export default function SettingsPage() {
  const [preferences, setPreferences] = useState({
    billingAlerts: true,
    renewalWarnings: true,
    weeklyDigest: false,
    compactTables: false,
    autoRefreshDashboard: true,
    maintenanceMode: false,
  });

  const summaryItems = useMemo(
    () => [
      {
        label: 'Ambiente do painel',
        value: 'Produção',
        tone: 'bg-emerald-50 text-emerald-600 border-emerald-200 dark:bg-emerald-900/20 dark:text-emerald-400 dark:border-emerald-900/30',
      },
      {
        label: 'Região padrão',
        value: 'Brasil',
        tone: 'bg-indigo-50 text-indigo-600 border-indigo-200 dark:bg-indigo-900/20 dark:text-indigo-400 dark:border-indigo-900/30',
      },
      {
        label: 'Fuso operacional',
        value: 'America/Sao_Paulo',
        tone: 'bg-amber-50 text-amber-600 border-amber-200 dark:bg-amber-900/20 dark:text-amber-400 dark:border-amber-900/30',
      },
    ],
    [],
  );

  const settingCards = [
    {
      title: 'Alertas de faturamento',
      description: 'Notifica o time quando o MRR oscila ou quando renovações críticas se aproximam.',
      icon: Bell,
      key: 'billingAlerts',
    },
    {
      title: 'Avisos de renovação',
      description: 'Destaca usuários com assinatura perto do vencimento no fluxo operacional.',
      icon: Clock3,
      key: 'renewalWarnings',
    },
    {
      title: 'Resumo semanal',
      description: 'Prepara o painel para uma rotina de fechamento e revisão semanal.',
      icon: Sparkles,
      key: 'weeklyDigest',
    },
    {
      title: 'Tabelas compactas',
      description: 'Reduz espaçamentos para times que operam com mais densidade de informação.',
      icon: Palette,
      key: 'compactTables',
    },
    {
      title: 'Auto refresh do dashboard',
      description: 'Mantém indicadores e cards principais sempre atualizados durante a operação.',
      icon: Globe,
      key: 'autoRefreshDashboard',
    },
    {
      title: 'Modo manutenção',
      description: 'Sinalização visual para momentos de revisão e ajustes internos do admin.',
      icon: LockKeyhole,
      key: 'maintenanceMode',
    },
  ] as const;

  return (
    <div className="p-6 sm:p-8 lg:p-10 space-y-8 animate-fade-in-up">
      <section className="rounded-[2rem] border border-[var(--border)] bg-gradient-to-br from-slate-50/90 via-white/80 to-cyan-50/60 dark:from-slate-900/90 dark:via-slate-900/80 dark:to-cyan-950/20 px-6 sm:px-8 py-7 shadow-sm">
        <div className="flex flex-col xl:flex-row xl:items-end xl:justify-between gap-6">
          <div className="space-y-4 max-w-3xl">
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/80 dark:bg-slate-950/50 border border-[var(--border)] text-xs font-bold uppercase tracking-[0.2em] text-cyan-600 dark:text-cyan-400">
              <Settings className="w-3.5 h-3.5" />
              Configurações do painel
            </div>
            <div>
              <h1 className="text-3xl sm:text-4xl font-black tracking-tight text-slate-900 dark:text-white">
                Controle fino da operação administrativa
              </h1>
              <p className="mt-3 text-sm sm:text-base text-slate-500 dark:text-slate-400 leading-relaxed">
                Organize preferências visuais, alertas críticos e parâmetros operacionais do admin em um espaço claro, bonito e pronto para crescer com o produto.
              </p>
            </div>
          </div>

          <div className="rounded-[1.5rem] border border-[var(--border)] bg-white/75 dark:bg-slate-950/45 px-5 py-4 min-w-[250px]">
            <p className="text-[11px] font-bold uppercase tracking-widest text-slate-400">Status geral</p>
            <div className="mt-3 flex items-center gap-2 text-emerald-600 dark:text-emerald-400">
              <CheckCircle2 className="w-5 h-5" />
              <span className="text-sm font-bold">Painel operando normalmente</span>
            </div>
          </div>
        </div>
      </section>

      <section className="grid grid-cols-1 md:grid-cols-3 gap-5">
        {summaryItems.map((item) => (
          <div key={item.label} className="p-5 bg-[var(--card)] rounded-3xl border border-[var(--border)] shadow-sm">
            <p className="text-[11px] font-bold uppercase tracking-widest text-slate-400">{item.label}</p>
            <span className={`mt-4 inline-flex px-3 py-1.5 rounded-full text-sm font-bold border ${item.tone}`}>
              {item.value}
            </span>
          </div>
        ))}
      </section>

      <section className="grid grid-cols-1 xl:grid-cols-[minmax(0,1.2fr)_360px] gap-6">
        <div className="bg-[var(--card)] rounded-[2rem] border border-[var(--border)] shadow-sm p-6 sm:p-8 space-y-6">
          <div className="flex items-center gap-3">
            <div className="p-2.5 bg-slate-100 dark:bg-slate-900 rounded-xl text-slate-600 dark:text-slate-300">
              <Bell className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-xl font-bold tracking-tight">Preferências do painel</h2>
              <p className="text-sm text-slate-500 dark:text-slate-400">
                Ajustes de operação e experiência visual para o time administrativo.
              </p>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {settingCards.map((card) => {
              const Icon = card.icon;
              const active = preferences[card.key];

              return (
                <div key={card.key} className="rounded-[1.5rem] border border-[var(--border)] bg-slate-50/70 dark:bg-slate-900/30 p-5 space-y-5">
                  <div className="flex items-start gap-3">
                    <div className={`p-2.5 rounded-xl ${active ? 'bg-cyan-50 text-cyan-600 dark:bg-cyan-900/20 dark:text-cyan-400' : 'bg-slate-200/80 text-slate-500 dark:bg-slate-800 dark:text-slate-400'}`}>
                      <Icon className="w-5 h-5" />
                    </div>
                    <div className="min-w-0">
                      <h3 className="text-base font-bold">{card.title}</h3>
                      <p className="text-sm text-slate-500 dark:text-slate-400 leading-relaxed">
                        {card.description}
                      </p>
                    </div>
                  </div>

                  <button
                    type="button"
                    onClick={() =>
                      setPreferences((current) => ({
                        ...current,
                        [card.key]: !current[card.key],
                      }))
                    }
                    className={`w-full flex items-center justify-between rounded-2xl border px-4 py-3.5 transition-all ${
                      active
                        ? 'bg-cyan-50 dark:bg-cyan-900/20 border-cyan-200 dark:border-cyan-900/30 text-cyan-700 dark:text-cyan-300'
                        : 'bg-white dark:bg-slate-950 border-[var(--border)] text-slate-500 dark:text-slate-400'
                    }`}
                  >
                    <span className="text-sm font-bold">{active ? 'Ativado' : 'Desativado'}</span>
                    <span
                      className={`w-11 h-6 rounded-full transition-all flex items-center ${
                        active ? 'bg-cyan-500 justify-end' : 'bg-slate-300 dark:bg-slate-700 justify-start'
                      }`}
                    >
                      <span className="w-5 h-5 rounded-full bg-white shadow-sm mx-0.5" />
                    </span>
                  </button>
                </div>
              );
            })}
          </div>
        </div>

        <div className="space-y-6">
          <div className="bg-[var(--card)] rounded-[2rem] border border-[var(--border)] shadow-sm p-6 space-y-5">
            <div className="flex items-center gap-3">
              <div className="p-2.5 bg-emerald-50 dark:bg-emerald-900/20 rounded-xl text-emerald-600 dark:text-emerald-400">
                <ShieldCheck className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-lg font-bold">Segurança operacional</h2>
                <p className="text-sm text-slate-500 dark:text-slate-400">Itens essenciais para manter o admin confiável.</p>
              </div>
            </div>

            <div className="space-y-3">
              {[
                'Autenticação validada antes de montar o painel',
                'Fluxos críticos separados por contexto administrativo',
                'Ações sensíveis com feedback visual e recarga de dados',
              ].map((item) => (
                <div key={item} className="flex items-start gap-3 p-4 rounded-2xl border border-[var(--border)] bg-slate-50/70 dark:bg-slate-900/30">
                  <CheckCircle2 className="w-5 h-5 text-emerald-500 shrink-0 mt-0.5" />
                  <p className="text-sm font-medium text-slate-600 dark:text-slate-300">{item}</p>
                </div>
              ))}
            </div>
          </div>

          <div className="bg-[var(--card)] rounded-[2rem] border border-[var(--border)] shadow-sm p-6 space-y-5">
            <div className="flex items-center gap-3">
              <div className="p-2.5 bg-indigo-50 dark:bg-indigo-900/20 rounded-xl text-indigo-600 dark:text-indigo-400">
                <Database className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-lg font-bold">Perfil técnico</h2>
                <p className="text-sm text-slate-500 dark:text-slate-400">Resumo de parâmetros úteis do ambiente atual.</p>
              </div>
            </div>

            <div className="space-y-3">
              {[
                { label: 'Stack principal', value: 'Next.js App Router + React + TypeScript' },
                { label: 'Tema visual', value: 'Painel premium com suporte a dark mode' },
                { label: 'Origem de dados', value: 'API administrativa + contrato novo de assinaturas' },
              ].map((item) => (
                <div key={item.label} className="rounded-2xl border border-[var(--border)] bg-slate-50/70 dark:bg-slate-900/30 px-4 py-3.5">
                  <p className="text-[11px] font-bold uppercase tracking-widest text-slate-400">{item.label}</p>
                  <p className="text-sm font-semibold mt-1 text-slate-900 dark:text-white">{item.value}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      <section className="rounded-[2rem] border border-[var(--border)] bg-[var(--card)] shadow-sm p-6 sm:p-8">
        <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-5">
          <div className="space-y-2">
            <h2 className="text-xl font-bold tracking-tight">Salvar preferências locais do painel</h2>
            <p className="text-sm text-slate-500 dark:text-slate-400">
              Esta tela organiza o espaço de configuração e pode evoluir depois para persistência em backend quando você quiser conectar esse fluxo.
            </p>
          </div>
          <button
            type="button"
            className="inline-flex items-center justify-center gap-2 px-6 py-3.5 text-sm font-bold text-white bg-cyan-600 rounded-2xl hover:bg-cyan-700 shadow-xl shadow-cyan-500/20 transition-all active:scale-[0.98]"
          >
            <Save className="w-4 h-4" />
            Aplicar preferências
          </button>
        </div>
      </section>
    </div>
  );
}
