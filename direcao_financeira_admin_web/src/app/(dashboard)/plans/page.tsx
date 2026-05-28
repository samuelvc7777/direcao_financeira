'use client';

import { useState, useEffect, useCallback } from 'react';
import Link from 'next/link';
import {
  Plus,
  Edit2,
  Trash2,
  Users,
  Zap,
  Crown,
  Loader2,
  AlertCircle,
} from 'lucide-react';
import { fetchApi } from '@/lib/api/client';
import {
  formatCurrencyFromCents,
  type User,
  type Plan,
} from '@/lib/subscriptions';
import { ResponsiveContainer } from '@/components/layout/responsive-container';

export default function PlansPage() {
  const [plans, setPlans] = useState<Plan[]>([]);
  const [activeUsersByPlan, setActiveUsersByPlan] = useState<Record<number, number>>({});
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const getErrorMessage = (errorValue: unknown, fallback: string) =>
    errorValue instanceof Error ? errorValue.message : fallback;

  const loadPlans = useCallback(async () => {
    setIsLoading(true);
    setError(null);

    try {
      const [plansResponse, usersResponse] = await Promise.all([
        fetchApi('/admin/plans'),
        fetchApi('/user').catch(() => []),
      ]);

      const usersData = Array.isArray(usersResponse) ? usersResponse : usersResponse.data || [];
      const counts = (usersData as User[]).reduce<Record<number, number>>((acc, user) => {
        const activePlanId = user.activeSubscription?.plan?.id;

        if (activePlanId) {
          acc[activePlanId] = (acc[activePlanId] || 0) + 1;
        }

        return acc;
      }, {});

      setPlans(plansResponse as Plan[]);
      setActiveUsersByPlan(counts);
    } catch (err: unknown) {
      setError(getErrorMessage(err, 'Erro ao carregar planos'));
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    loadPlans();
  }, [loadPlans]);

  const handleDelete = async (id: number) => {
    if (!confirm('Tem certeza que deseja excluir este plano?')) return;

    try {
      await fetchApi(`/admin/plans/${id}`, { method: 'DELETE' });
      await loadPlans();
    } catch (err: unknown) {
      alert(getErrorMessage(err, 'Erro ao excluir plano'));
    }
  };

  if (isLoading) {
    return (
      <div className="flex h-[60vh] items-center justify-center">
        <div className="flex flex-col items-center gap-4">
          <Loader2 className="w-10 h-10 text-indigo-600 animate-spin" />
          <p className="text-sm font-medium text-slate-500 font-sans">Sincronizando planos...</p>
        </div>
      </div>
    );
  }

  return (
    <ResponsiveContainer>
    <div className="relative">
      <div className="space-y-8 animate-fade-in-up">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold tracking-tight">Planos & Assinaturas</h1>
            <p className="text-sm text-slate-500 dark:text-slate-400">Gerencie os modelos de monetização e benefícios dos usuários.</p>
          </div>
          <Link
            href="/plans/new"
            className="flex items-center gap-2 px-6 py-3 text-sm font-bold text-white bg-indigo-600 rounded-2xl hover:bg-indigo-700 shadow-xl shadow-indigo-500/20 transition-all active:scale-[0.98]"
          >
            <Plus className="w-5 h-5" /> Novo Plano
          </Link>
        </div>

        {error && (
          <div className="flex items-center gap-3 p-4 bg-red-50 dark:bg-red-900/10 border border-red-100 dark:border-red-900/20 rounded-2xl text-red-600 dark:text-red-400">
            <AlertCircle className="w-5 h-5 shrink-0" />
            <p className="text-sm font-medium">{error}</p>
          </div>
        )}

        <div className="responsive-grid-cards">
          {plans.map((plan) => (
            <div key={plan.id} className="bg-[var(--card)] rounded-[2.5rem] border border-[var(--border)] shadow-sm hover:shadow-2xl hover:-translate-y-1 transition-all duration-300 flex flex-col overflow-hidden group">
              <div className="p-8 space-y-6">
                <div className="flex justify-between items-start">
                  <div className="p-4 rounded-2xl bg-indigo-50 dark:bg-indigo-900/20 text-indigo-600 dark:text-indigo-400 group-hover:scale-110 transition-transform duration-300">
                    {plan.durationDays >= 365 ? <Crown className="w-6 h-6" /> : <Zap className="w-6 h-6" />}
                  </div>
                  <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                    <Link href={`/plans/${plan.id}`} className="p-2.5 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 dark:hover:bg-indigo-950/50 rounded-xl transition-all">
                      <Edit2 className="w-4 h-4" />
                    </Link>
                    <button onClick={() => handleDelete(plan.id)} className="p-2.5 text-slate-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-900/30 rounded-xl transition-all">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>

                <div>
                  <div className="flex items-center gap-2">
                    <h3 className="text-xl font-bold tracking-tight">{plan.name}</h3>
                    <span className="px-2.5 py-1 text-[10px] font-bold rounded-full uppercase bg-slate-100 dark:bg-slate-800 text-slate-500 dark:text-slate-400">
                      {plan.code}
                    </span>
                  </div>
                  <div className="flex items-baseline gap-1 mt-3">
                    <span className="text-4xl font-black tracking-tighter">
                      {formatCurrencyFromCents(plan.priceCents)}
                    </span>
                    <span className="text-sm font-bold text-slate-400">/{plan.durationDays} dias</span>
                  </div>
                  <p className="mt-4 text-sm text-slate-500 dark:text-slate-400 leading-relaxed min-h-[48px]">
                    {plan.description || 'Defina os benefícios deste plano para atrair novos motoristas.'}
                  </p>
                </div>
              </div>

              <div className="mt-auto p-6 bg-slate-50/50 dark:bg-slate-900/20 border-t border-[var(--border)] flex items-center justify-between">
                <div className="flex items-center gap-2 text-sm font-bold text-slate-600 dark:text-slate-400">
                  <div className="flex -space-x-2">
                    {[1, 2, 3].map((i) => (
                      <div key={i} className="w-6 h-6 rounded-full border-2 border-white dark:border-slate-800 bg-slate-200 dark:bg-slate-700 overflow-hidden text-[8px] flex items-center justify-center">
                        <Users className="w-3 h-3" />
                      </div>
                    ))}
                  </div>
                  <span className="ml-1">
                    {`${typeof plan._count?.users === 'number' ? plan._count.users : (activeUsersByPlan[plan.id] || 0)} usuários`}
                  </span>
                </div>
                <div className={`px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border ${
                  plan.isActive
                    ? 'bg-emerald-50 dark:bg-emerald-900/20 text-emerald-600 border-emerald-200 dark:border-emerald-800'
                    : 'bg-slate-100 dark:bg-slate-800 text-slate-400 border-slate-200 dark:border-slate-700'
                }`}>
                  {plan.isActive ? 'Ativo' : 'Pausado'}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
    </ResponsiveContainer>
  );
}
