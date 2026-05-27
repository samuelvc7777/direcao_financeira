'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import {
  ArrowLeft,
  Shield,
  Loader2,
  AlertCircle,
  User as UserIcon,
  Lock,
  Unlock,
  RefreshCcw,
  Ban,
  CheckCircle2,
  Gem,
} from 'lucide-react';
import { fetchApi } from '@/lib/api/client';
import { mapUserToListItem, type Plan, type User, type UserListItem } from '@/lib/subscriptions';

interface SubscriptionFeedback {
  type: 'success' | 'error';
  message: string;
}

export default function UserEditPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const userId = Number(params.id);
  const [plans, setPlans] = useState<Plan[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSubscriptionSubmitting, setIsSubscriptionSubmitting] = useState(false);
  const [editingUser, setEditingUser] = useState<UserListItem | null>(null);
  const [selectedPlanId, setSelectedPlanId] = useState('');
  const [subscriptionFeedback, setSubscriptionFeedback] = useState<SubscriptionFeedback | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    isActive: true,
    role: 'USER' as 'ADMIN' | 'USER',
  });

  const getErrorMessage = (errorValue: unknown, fallback: string) =>
    errorValue instanceof Error ? errorValue.message : fallback;

  const hydratePage = useCallback(async () => {
    if (!userId || Number.isNaN(userId)) {
      setError('Usuário inválido.');
      setIsLoading(false);
      return;
    }

    setIsLoading(true);
    setError(null);

    try {
      const [userResponse, plansResponse] = await Promise.all([
        fetchApi(`/user/${userId}`),
        fetchApi('/admin/plans').catch(() => []),
      ]);

      const userData = (Array.isArray(userResponse) ? userResponse[0] : userResponse) as User;
      const mappedUser = mapUserToListItem(userData);

      setEditingUser(mappedUser);
      setPlans(plansResponse as Plan[]);
      setSelectedPlanId(mappedUser.activePlan ? String(mappedUser.activePlan.id) : '');
      setFormData({
        name: mappedUser.name,
        email: mappedUser.email,
        phone: mappedUser.phone ?? '',
        isActive: mappedUser.isActive,
        role: mappedUser.roleLabel.name as 'ADMIN' | 'USER',
      });
    } catch (err: unknown) {
      setError(getErrorMessage(err, 'Erro ao carregar usuário'));
    } finally {
      setIsLoading(false);
    }
  }, [userId]);

  useEffect(() => {
    hydratePage();
  }, [hydratePage]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingUser) return;

    setIsSubmitting(true);
    try {
      await fetchApi(`/user/${editingUser.id}`, {
        method: 'PATCH',
        body: JSON.stringify({
          name: formData.name,
          email: formData.email,
          phone: formData.phone.trim() || null,
          isActive: formData.isActive,
          role: formData.role,
        }),
      });

      await hydratePage();
      setSubscriptionFeedback({
        type: 'success',
        message: 'Dados do usuário atualizados com sucesso.',
      });
    } catch (err: unknown) {
      setSubscriptionFeedback({
        type: 'error',
        message: getErrorMessage(err, 'Erro ao atualizar usuário'),
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleSubscriptionAction = async (action: 'change-plan' | 'cancel' | 'renew') => {
    if (!editingUser) return;

    if (action === 'change-plan' && !selectedPlanId) {
      setSubscriptionFeedback({
        type: 'error',
        message: 'Selecione um plano para trocar a assinatura.',
      });
      return;
    }

    setIsSubscriptionSubmitting(true);
    setSubscriptionFeedback(null);

    try {
      const endpointMap = {
        'change-plan': `/admin/users/${editingUser.id}/subscription/change-plan`,
        cancel: `/admin/users/${editingUser.id}/subscription/cancel`,
        renew: `/admin/users/${editingUser.id}/subscription/renew`,
      } as const;

      const bodyMap = {
        'change-plan': { planId: Number(selectedPlanId) },
        cancel: undefined,
        renew: { autoRenew: true },
      } as const;

      await fetchApi(endpointMap[action], {
        method: 'POST',
        ...(bodyMap[action] ? { body: JSON.stringify(bodyMap[action]) } : {}),
      });

      await hydratePage();

      setSubscriptionFeedback({
        type: 'success',
        message: {
          'change-plan': 'Plano alterado com sucesso.',
          cancel: 'Assinatura cancelada com sucesso.',
          renew: 'Assinatura renovada com sucesso.',
        }[action],
      });
    } catch (err: unknown) {
      setSubscriptionFeedback({
        type: 'error',
        message: getErrorMessage(err, 'Erro ao processar a assinatura'),
      });
    } finally {
      setIsSubscriptionSubmitting(false);
    }
  };

  if (isLoading) {
    return (
      <div className="p-10 flex h-[70vh] items-center justify-center">
        <Loader2 className="w-10 h-10 text-indigo-600 animate-spin" />
      </div>
    );
  }

  if (error || !editingUser) {
    return (
      <div className="p-10 space-y-6">
        <Link href="/users" className="inline-flex items-center gap-2 text-sm font-semibold text-slate-500 hover:text-indigo-600 transition-colors">
          <ArrowLeft className="w-4 h-4" />
          Voltar para usuários
        </Link>
        <div className="flex items-center gap-3 p-4 bg-red-50 dark:bg-red-900/10 border border-red-100 dark:border-red-900/20 rounded-2xl text-red-600 dark:text-red-400">
          <AlertCircle className="w-5 h-5 shrink-0" />
          <p className="text-sm font-medium">{error || 'Usuário não encontrado.'}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 sm:p-8 lg:p-10 space-y-8 animate-fade-in-up">
      <div className="flex flex-col gap-4">
        <Link href="/users" className="inline-flex items-center gap-2 text-sm font-semibold text-slate-500 hover:text-indigo-600 transition-colors">
          <ArrowLeft className="w-4 h-4" />
          Voltar para usuários
        </Link>

        <div className="rounded-[2rem] border border-[var(--border)] bg-gradient-to-r from-slate-50/90 via-white/80 to-indigo-50/70 dark:from-slate-900/90 dark:via-slate-900/80 dark:to-indigo-950/40 px-6 sm:px-8 py-6 shadow-sm">
          <div className="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-6">
            <div className="flex items-start gap-4 min-w-0">
              <div className="w-14 h-14 rounded-2xl bg-indigo-600 text-white flex items-center justify-center text-sm font-black shadow-xl shadow-indigo-500/25 shrink-0">
                {editingUser.name.split(' ').map((name) => name[0]).join('').slice(0, 2).toUpperCase()}
              </div>
              <div className="min-w-0 space-y-3">
                <div>
                  <p className="text-[11px] font-bold uppercase tracking-[0.24em] text-indigo-500">Gestão de usuário</p>
                  <h1 className="text-3xl font-bold tracking-tight text-slate-900 dark:text-white">Editar {editingUser.name}</h1>
                  <p className="text-sm text-slate-500 dark:text-slate-400">{editingUser.email}</p>
                </div>
                <div className="flex flex-wrap gap-2">
                  <span className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/80 dark:bg-slate-950/60 border border-[var(--border)] text-xs font-bold text-slate-600 dark:text-slate-300">
                    <Shield className="w-3.5 h-3.5" />
                    {editingUser.roleLabel.name}
                  </span>
                  <span className={`inline-flex items-center gap-2 px-3 py-1.5 rounded-full border text-xs font-bold ${
                    editingUser.isActive
                      ? 'bg-emerald-50 dark:bg-emerald-900/20 border-emerald-200 dark:border-emerald-900/30 text-emerald-600 dark:text-emerald-400'
                      : 'bg-red-50 dark:bg-red-900/20 border-red-200 dark:border-red-900/30 text-red-600 dark:text-red-400'
                  }`}>
                    <div className={`w-2 h-2 rounded-full ${editingUser.isActive ? 'bg-emerald-500' : 'bg-red-500'}`}></div>
                    {editingUser.isActive ? 'Acesso ativo' : 'Bloqueado'}
                  </span>
                  <span className={`inline-flex items-center gap-2 px-3 py-1.5 rounded-full border text-xs font-bold ${
                    editingUser.activePlan
                      ? 'bg-indigo-50 dark:bg-indigo-900/20 border-indigo-200 dark:border-indigo-900/30 text-indigo-600 dark:text-indigo-400'
                      : 'bg-slate-100 dark:bg-slate-800 border-slate-200 dark:border-slate-700 text-slate-500 dark:text-slate-400'
                  }`}>
                    <Gem className="w-3.5 h-3.5" />
                    {editingUser.activePlan?.name || 'Sem plano'}
                  </span>
                </div>
              </div>
            </div>

            <div className="rounded-2xl border border-[var(--border)] bg-white/75 dark:bg-slate-950/40 px-4 py-3 min-w-[220px]">
              <p className="text-[11px] font-bold uppercase tracking-widest text-slate-400">Status da assinatura</p>
              <p className="text-sm font-semibold mt-1 text-slate-900 dark:text-white">{editingUser.subscriptionStatus || 'Sem assinatura ativa'}</p>
            </div>
          </div>
        </div>
      </div>

      {subscriptionFeedback && (
        <div className={`flex items-center gap-3 p-4 rounded-2xl border ${
          subscriptionFeedback.type === 'success'
            ? 'bg-emerald-50 dark:bg-emerald-900/10 border-emerald-100 dark:border-emerald-900/20 text-emerald-600 dark:text-emerald-400'
            : 'bg-red-50 dark:bg-red-900/10 border-red-100 dark:border-red-900/20 text-red-600 dark:text-red-400'
        }`}>
          {subscriptionFeedback.type === 'success' ? <CheckCircle2 className="w-5 h-5 shrink-0" /> : <AlertCircle className="w-5 h-5 shrink-0" />}
          <p className="text-sm font-medium">{subscriptionFeedback.message}</p>
        </div>
      )}

      <div className="grid grid-cols-1 xl:grid-cols-[minmax(0,1fr)_360px] gap-6">
        <form onSubmit={handleSubmit} className="rounded-[2rem] border border-[var(--border)] bg-[var(--card)] p-6 sm:p-8 space-y-8 shadow-sm">
          <div className="flex items-center gap-3">
            <div className="p-2.5 bg-slate-100 dark:bg-slate-900 rounded-xl text-slate-600 dark:text-slate-300">
              <UserIcon className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-lg font-bold">Dados principais</h2>
              <p className="text-sm text-slate-500 dark:text-slate-400">Informações cadastrais e permissões do usuário.</p>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Nome Completo</label>
              <input required type="text" className="w-full px-4 py-3.5 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all font-medium" value={formData.name} onChange={(e) => setFormData({ ...formData, name: e.target.value })} />
            </div>
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">E-mail</label>
              <input required type="email" className="w-full px-4 py-3.5 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all font-medium" value={formData.email} onChange={(e) => setFormData({ ...formData, email: e.target.value })} />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Telefone Celular</label>
              <input
                type="tel"
                inputMode="tel"
                placeholder="(00) 00000-0000"
                className="w-full px-4 py-3.5 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all font-medium"
                value={formData.phone}
                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
              />
            </div>
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Cargo (Role)</label>
              <select className="w-full px-4 py-3.5 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none appearance-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all font-medium" value={formData.role} onChange={(e) => setFormData({ ...formData, role: e.target.value as 'ADMIN' | 'USER' })}>
                <option value="USER">Motorista (Comum)</option>
                <option value="ADMIN">Administrador</option>
              </select>
            </div>
            <div className="rounded-2xl border border-[var(--border)] bg-slate-50 dark:bg-slate-950 px-4 py-3.5">
              <p className="text-[11px] font-bold uppercase tracking-widest text-slate-400">Plano atual</p>
              <p className="text-sm font-semibold mt-1 text-slate-900 dark:text-white">{editingUser.activePlan?.name || 'Sem plano ativo'}</p>
            </div>
          </div>

          <div className="space-y-3">
            <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Status de Acesso</label>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <button type="button" onClick={() => setFormData({ ...formData, isActive: true })} className={`flex items-center justify-center gap-2 py-3.5 rounded-2xl border transition-all font-semibold ${formData.isActive ? 'bg-emerald-50 dark:bg-emerald-900/20 border-emerald-500 text-emerald-600 shadow-sm' : 'bg-transparent border-[var(--border)] text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-900/40'}`}>
                <Unlock className="w-4 h-4" /> Ativo
              </button>
              <button type="button" onClick={() => setFormData({ ...formData, isActive: false })} className={`flex items-center justify-center gap-2 py-3.5 rounded-2xl border transition-all font-semibold ${!formData.isActive ? 'bg-red-50 dark:bg-red-900/20 border-red-500 text-red-600 shadow-sm' : 'bg-transparent border-[var(--border)] text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-900/40'}`}>
                <Lock className="w-4 h-4" /> Bloqueado
              </button>
            </div>
          </div>

          <div className="flex flex-col-reverse sm:flex-row gap-3 sm:items-center sm:justify-end pt-2">
            <button type="button" onClick={() => router.push('/users')} className="px-6 py-3.5 text-sm font-bold text-slate-500 hover:text-slate-700 dark:hover:text-slate-300 transition-colors">
              Cancelar
            </button>
            <button disabled={isSubmitting} type="submit" className="min-w-[220px] px-6 py-3.5 text-sm font-bold text-white bg-indigo-600 rounded-2xl hover:bg-indigo-700 shadow-xl shadow-indigo-500/30 transition-all flex items-center justify-center gap-2 disabled:opacity-60">
              {isSubmitting ? <Loader2 className="w-5 h-5 animate-spin" /> : 'Salvar Alterações'}
            </button>
          </div>
        </form>

        <aside className="rounded-[2rem] border border-[var(--border)] bg-gradient-to-br from-slate-50/90 via-white/70 to-indigo-50/60 dark:from-slate-900/60 dark:via-slate-900/30 dark:to-indigo-950/20 p-6 sm:p-7 space-y-6 shadow-sm self-start">
          <div className="flex items-center gap-3">
            <div className="p-2.5 bg-indigo-600 rounded-xl text-white shadow-lg shadow-indigo-500/20">
              <Gem className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-lg font-bold">Gerenciar assinatura</h2>
              <p className="text-sm text-slate-500 dark:text-slate-400">Atualize o plano e execute ações administrativas com segurança.</p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div className="rounded-2xl border border-[var(--border)] bg-white/75 dark:bg-slate-950/55 px-4 py-3">
              <p className="text-[11px] font-bold uppercase tracking-widest text-slate-400">Plano atual</p>
              <p className="text-sm font-semibold mt-1 text-slate-900 dark:text-white">{editingUser.activePlan?.name || 'Sem plano'}</p>
            </div>
            <div className="rounded-2xl border border-[var(--border)] bg-white/75 dark:bg-slate-950/55 px-4 py-3">
              <p className="text-[11px] font-bold uppercase tracking-widest text-slate-400">Status</p>
              <p className="text-sm font-semibold mt-1 text-slate-900 dark:text-white">{editingUser.subscriptionStatus || 'Sem assinatura'}</p>
            </div>
          </div>

          <div className="space-y-3">
            <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Trocar plano</label>
            <select className="w-full px-4 py-3.5 bg-white dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none appearance-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all font-medium" value={selectedPlanId} onChange={(e) => setSelectedPlanId(e.target.value)}>
              <option value="">Selecione um plano</option>
              {plans.map((plan) => (
                <option key={plan.id} value={plan.id}>
                  {plan.name}
                </option>
              ))}
            </select>
            <button type="button" disabled={isSubscriptionSubmitting} onClick={() => handleSubscriptionAction('change-plan')} className="w-full px-5 py-3.5 text-sm font-bold text-white bg-indigo-600 rounded-2xl hover:bg-indigo-700 shadow-xl shadow-indigo-500/20 transition-all flex items-center justify-center gap-2 disabled:opacity-60">
              {isSubscriptionSubmitting ? <Loader2 className="w-4 h-4 animate-spin" /> : <RefreshCcw className="w-4 h-4" />}
              Trocar plano
            </button>
          </div>

          <div className="grid grid-cols-1 gap-3">
            <button type="button" disabled={isSubscriptionSubmitting} onClick={() => handleSubscriptionAction('renew')} className="w-full px-5 py-3.5 text-sm font-bold text-emerald-600 bg-white dark:bg-slate-950 border border-emerald-200 dark:border-emerald-900/30 rounded-2xl hover:bg-emerald-50 dark:hover:bg-emerald-900/10 transition-all flex items-center justify-center gap-2 disabled:opacity-60">
              {isSubscriptionSubmitting ? <Loader2 className="w-4 h-4 animate-spin" /> : <RefreshCcw className="w-4 h-4" />}
              Renovar assinatura
            </button>
            <button type="button" disabled={isSubscriptionSubmitting} onClick={() => handleSubscriptionAction('cancel')} className="w-full px-5 py-3.5 text-sm font-bold text-red-600 bg-white dark:bg-slate-950 border border-red-200 dark:border-red-900/30 rounded-2xl hover:bg-red-50 dark:hover:bg-red-900/10 transition-all flex items-center justify-center gap-2 disabled:opacity-60">
              {isSubscriptionSubmitting ? <Loader2 className="w-4 h-4 animate-spin" /> : <Ban className="w-4 h-4" />}
              Cancelar assinatura
            </button>
          </div>
        </aside>
      </div>
    </div>
  );
}
