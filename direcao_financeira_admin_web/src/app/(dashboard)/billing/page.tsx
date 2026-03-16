'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import {
  TrendingUp,
  Wallet,
  CalendarClock,
  Gem,
  Loader2,
  AlertCircle,
  ArrowUpRight,
  ChevronRight,
  Activity,
} from 'lucide-react';
import { fetchApi } from '@/lib/api/client';
import {
  formatCurrencyFromCents,
  mapUserToListItem,
  type User,
  type UserListItem,
} from '@/lib/subscriptions';

interface DashboardData {
  metrics: {
    totalUsers: number;
    activeUsers: number;
    newUsers24h: number;
    estimatedRevenue: number;
  };
  plans: Array<{
    name: string;
    count: number;
    revenue: number;
  }>;
  recentActivity: Array<{
    id: string;
    action: string;
    details: string;
    userName: string;
    createdAt: string;
  }>;
}

function daysUntil(dateString: string) {
  const today = new Date();
  const target = new Date(dateString);
  const diff = target.getTime() - today.getTime();

  return Math.ceil(diff / (1000 * 60 * 60 * 24));
}

export default function BillingPage() {
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [dashboard, setDashboard] = useState<DashboardData | null>(null);
  const [users, setUsers] = useState<UserListItem[]>([]);

  useEffect(() => {
    async function loadBilling() {
      setIsLoading(true);
      setError(null);

      try {
        const [dashboardResponse, usersResponse] = await Promise.all([
          fetchApi('/admin/dashboard').catch(() => ({
            metrics: { totalUsers: 0, activeUsers: 0, newUsers24h: 0, estimatedRevenue: 0 },
            plans: [],
            recentActivity: [],
          })),
          fetchApi('/user'),
        ]);

        const usersData = Array.isArray(usersResponse) ? usersResponse : usersResponse.data || [];

        setDashboard(dashboardResponse as DashboardData);
        setUsers((usersData as User[]).map(mapUserToListItem));
      } catch (err: unknown) {
        setError(err instanceof Error ? err.message : 'Erro ao carregar faturamento');
      } finally {
        setIsLoading(false);
      }
    }

    loadBilling();
  }, []);

  const billingData = useMemo(() => {
    const activeSubscribers = users.filter(
      (user) => user.isActive && user.activeSubscription?.status === 'ACTIVE' && user.activePlan,
    );

    const mrrCents = activeSubscribers.reduce(
      (total, user) => total + (user.activePlan?.priceCents || 0),
      0,
    );

    const renewalsNext7Days = activeSubscribers
      .filter((user) => user.activeSubscription?.endDate)
      .map((user) => ({
        ...user,
        daysLeft: daysUntil(user.activeSubscription!.endDate),
      }))
      .filter((user) => user.daysLeft >= 0 && user.daysLeft <= 7)
      .sort((a, b) => a.daysLeft - b.daysLeft);

    const revenueByPlan = activeSubscribers.reduce<Record<string, { name: string; users: number; revenueCents: number }>>((acc, user) => {
      if (!user.activePlan) {
        return acc;
      }

      const key = user.activePlan.code;
      const current = acc[key] || {
        name: user.activePlan.name,
        users: 0,
        revenueCents: 0,
      };

      current.users += 1;
      current.revenueCents += user.activePlan.priceCents;
      acc[key] = current;

      return acc;
    }, {});

    const planRows = Object.values(revenueByPlan).sort((a, b) => b.revenueCents - a.revenueCents);
    const highestRevenue = planRows[0]?.revenueCents || 1;
    const annualizedRevenueCents = mrrCents * 12;

    return {
      activeSubscribers,
      mrrCents,
      annualizedRevenueCents,
      renewalsNext7Days,
      planRows,
      highestRevenue,
    };
  }, [users]);

  if (isLoading) {
    return (
      <div className="flex h-[70vh] items-center justify-center">
        <Loader2 className="w-10 h-10 text-indigo-600 animate-spin" />
      </div>
    );
  }

  if (error || !dashboard) {
    return (
      <div className="p-10">
        <div className="flex items-center gap-3 p-4 bg-red-50 dark:bg-red-900/10 border border-red-100 dark:border-red-900/20 rounded-2xl text-red-600 dark:text-red-400">
          <AlertCircle className="w-5 h-5 shrink-0" />
          <p className="text-sm font-medium">{error || 'Erro ao carregar faturamento.'}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 sm:p-8 lg:p-10 space-y-8 animate-fade-in-up">
      <section className="rounded-[2rem] border border-[var(--border)] bg-gradient-to-br from-slate-50/90 via-white/80 to-emerald-50/60 dark:from-slate-900/90 dark:via-slate-900/80 dark:to-emerald-950/20 px-6 sm:px-8 py-7 shadow-sm">
        <div className="flex flex-col xl:flex-row xl:items-end xl:justify-between gap-6">
          <div className="space-y-4 max-w-3xl">
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/80 dark:bg-slate-950/50 border border-[var(--border)] text-xs font-bold uppercase tracking-[0.2em] text-emerald-600 dark:text-emerald-400">
              <Activity className="w-3.5 h-3.5" />
              Receita e assinaturas
            </div>
            <div>
              <h1 className="text-3xl sm:text-4xl font-black tracking-tight text-slate-900 dark:text-white">
                Faturamento com visão clara do que está entrando agora
              </h1>
              <p className="mt-3 text-sm sm:text-base text-slate-500 dark:text-slate-400 leading-relaxed">
                Acompanhe MRR estimado, distribuição por plano, renovações próximas e a atividade mais recente do seu motor de assinaturas.
              </p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3 min-w-fit">
            <div className="rounded-2xl border border-[var(--border)] bg-white/75 dark:bg-slate-950/45 px-4 py-3">
              <p className="text-[11px] font-bold uppercase tracking-widest text-slate-400">MRR atual</p>
              <p className="text-lg font-bold mt-1">{formatCurrencyFromCents(billingData.mrrCents)}</p>
            </div>
            <div className="rounded-2xl border border-[var(--border)] bg-white/75 dark:bg-slate-950/45 px-4 py-3">
              <p className="text-[11px] font-bold uppercase tracking-widest text-slate-400">Assinantes</p>
              <p className="text-lg font-bold mt-1">{billingData.activeSubscribers.length}</p>
            </div>
          </div>
        </div>
      </section>

      <section className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-5">
        <div className="p-6 bg-[var(--card)] rounded-3xl border border-[var(--border)] shadow-sm">
          <div className="w-12 h-12 rounded-2xl bg-emerald-50 dark:bg-emerald-900/20 text-emerald-600 dark:text-emerald-400 flex items-center justify-center mb-4">
            <Wallet className="w-6 h-6" />
          </div>
          <p className="text-sm font-medium text-slate-400 dark:text-slate-500">Receita Mensal Estimada</p>
          <h3 className="text-2xl font-bold mt-1">{formatCurrencyFromCents(billingData.mrrCents)}</h3>
          <p className="text-xs font-semibold text-emerald-500 mt-2">Baseada em assinaturas ativas</p>
        </div>

        <div className="p-6 bg-[var(--card)] rounded-3xl border border-[var(--border)] shadow-sm">
          <div className="w-12 h-12 rounded-2xl bg-indigo-50 dark:bg-indigo-900/20 text-indigo-600 dark:text-indigo-400 flex items-center justify-center mb-4">
            <TrendingUp className="w-6 h-6" />
          </div>
          <p className="text-sm font-medium text-slate-400 dark:text-slate-500">Receita Anualizada</p>
          <h3 className="text-2xl font-bold mt-1">{formatCurrencyFromCents(billingData.annualizedRevenueCents)}</h3>
          <p className="text-xs font-semibold text-slate-500 mt-2">Projeção de 12 meses no ritmo atual</p>
        </div>

        <div className="p-6 bg-[var(--card)] rounded-3xl border border-[var(--border)] shadow-sm">
          <div className="w-12 h-12 rounded-2xl bg-amber-50 dark:bg-amber-900/20 text-amber-600 dark:text-amber-400 flex items-center justify-center mb-4">
            <Gem className="w-6 h-6" />
          </div>
          <p className="text-sm font-medium text-slate-400 dark:text-slate-500">Assinaturas Ativas</p>
          <h3 className="text-2xl font-bold mt-1">{billingData.activeSubscribers.length}</h3>
          <p className="text-xs font-semibold text-slate-500 mt-2">
            {dashboard.metrics.totalUsers > 0
              ? `${((billingData.activeSubscribers.length / dashboard.metrics.totalUsers) * 100).toFixed(0)}% da base`
              : 'Sem base suficiente'}
          </p>
        </div>

        <div className="p-6 bg-[var(--card)] rounded-3xl border border-[var(--border)] shadow-sm">
          <div className="w-12 h-12 rounded-2xl bg-rose-50 dark:bg-rose-900/20 text-rose-600 dark:text-rose-400 flex items-center justify-center mb-4">
            <CalendarClock className="w-6 h-6" />
          </div>
          <p className="text-sm font-medium text-slate-400 dark:text-slate-500">Renovações em 7 dias</p>
          <h3 className="text-2xl font-bold mt-1">{billingData.renewalsNext7Days.length}</h3>
          <p className="text-xs font-semibold text-slate-500 mt-2">Monitoramento de vencimentos próximos</p>
        </div>
      </section>

      <section className="grid grid-cols-1 xl:grid-cols-[minmax(0,1.15fr)_380px] gap-6">
        <div className="bg-[var(--card)] rounded-[2rem] border border-[var(--border)] shadow-sm p-6 sm:p-8 space-y-6">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
            <div>
              <h2 className="text-xl font-bold tracking-tight">Receita por plano</h2>
              <p className="text-sm text-slate-500 dark:text-slate-400">Distribuição atual de usuários e contribuição estimada de cada tier.</p>
            </div>
            <Link href="/plans" className="inline-flex items-center gap-2 text-sm font-bold text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 transition-colors">
              Gerenciar planos
              <ChevronRight className="w-4 h-4" />
            </Link>
          </div>

          <div className="space-y-4">
            {billingData.planRows.length > 0 ? billingData.planRows.map((plan) => (
              <div key={plan.name} className="rounded-[1.5rem] border border-[var(--border)] bg-slate-50/70 dark:bg-slate-900/30 p-4 sm:p-5">
                <div className="flex items-center justify-between gap-4">
                  <div>
                    <p className="text-base font-bold">{plan.name}</p>
                    <p className="text-sm text-slate-500 dark:text-slate-400">{plan.users} assinantes ativos</p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-bold text-slate-900 dark:text-white">{formatCurrencyFromCents(plan.revenueCents)}</p>
                    <p className="text-xs text-slate-400">
                      {billingData.mrrCents > 0 ? `${((plan.revenueCents / billingData.mrrCents) * 100).toFixed(0)}% do MRR` : '0% do MRR'}
                    </p>
                  </div>
                </div>
                <div className="mt-4 h-3 rounded-full bg-slate-200/70 dark:bg-slate-800 overflow-hidden">
                  <div
                    className="h-full rounded-full bg-gradient-to-r from-indigo-500 via-indigo-400 to-emerald-400"
                    style={{ width: `${Math.max(12, (plan.revenueCents / billingData.highestRevenue) * 100)}%` }}
                  />
                </div>
              </div>
            )) : (
              <div className="rounded-[1.5rem] border border-dashed border-[var(--border)] p-8 text-center text-slate-500 dark:text-slate-400">
                Nenhuma assinatura ativa encontrada para compor a receita por plano.
              </div>
            )}
          </div>
        </div>

        <div className="space-y-6">
          <div className="bg-[var(--card)] rounded-[2rem] border border-[var(--border)] shadow-sm p-6 space-y-5">
            <div className="flex items-center justify-between gap-3">
              <div>
                <h2 className="text-lg font-bold">Próximos vencimentos</h2>
                <p className="text-sm text-slate-500 dark:text-slate-400">Usuários com renovação prevista nos próximos dias.</p>
              </div>
              <CalendarClock className="w-5 h-5 text-slate-400" />
            </div>

            <div className="space-y-3">
              {billingData.renewalsNext7Days.length > 0 ? billingData.renewalsNext7Days.slice(0, 5).map((user) => (
                <Link
                  key={user.id}
                  href={`/users/${user.id}`}
                  className="flex items-center justify-between gap-4 p-4 rounded-2xl border border-[var(--border)] bg-slate-50/70 dark:bg-slate-900/30 hover:border-indigo-200 dark:hover:border-indigo-900/30 transition-all"
                >
                  <div className="min-w-0">
                    <p className="text-sm font-bold truncate">{user.name}</p>
                    <p className="text-xs text-slate-500 dark:text-slate-400 truncate">
                      {user.activePlan?.name || 'Sem plano'} • vence em {user.daysLeft} dia(s)
                    </p>
                  </div>
                  <ArrowUpRight className="w-4 h-4 text-slate-400 shrink-0" />
                </Link>
              )) : (
                <div className="rounded-2xl border border-dashed border-[var(--border)] p-6 text-sm text-center text-slate-500 dark:text-slate-400">
                  Nenhuma renovação crítica nos próximos 7 dias.
                </div>
              )}
            </div>
          </div>

          <div className="bg-[var(--card)] rounded-[2rem] border border-[var(--border)] shadow-sm p-6 space-y-5">
            <div className="flex items-center justify-between gap-3">
              <div>
                <h2 className="text-lg font-bold">Atividade recente</h2>
                <p className="text-sm text-slate-500 dark:text-slate-400">Eventos do painel que impactam operação e receita.</p>
              </div>
              <Activity className="w-5 h-5 text-slate-400" />
            </div>

            <div className="space-y-3">
              {dashboard.recentActivity.length > 0 ? dashboard.recentActivity.slice(0, 5).map((activity) => (
                <div key={activity.id} className="p-4 rounded-2xl border border-[var(--border)] bg-slate-50/70 dark:bg-slate-900/30">
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <p className="text-sm font-bold">{activity.action}</p>
                      <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
                        {activity.userName} • {activity.details}
                      </p>
                    </div>
                    <span className="text-[11px] font-bold uppercase tracking-widest text-slate-400">
                      {new Date(activity.createdAt).toLocaleDateString('pt-BR', {
                        day: '2-digit',
                        month: 'short',
                      })}
                    </span>
                  </div>
                </div>
              )) : (
                <div className="rounded-2xl border border-dashed border-[var(--border)] p-6 text-sm text-center text-slate-500 dark:text-slate-400">
                  Ainda não há atividade recente para exibir.
                </div>
              )}
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
