'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import {
  ArrowLeft,
  Plus,
  Edit2,
  CreditCard,
  Type,
  DollarSign,
  AlignLeft,
  Check,
  Loader2,
  AlertCircle,
  Zap,
  Crown,
} from 'lucide-react';
import { fetchApi } from '@/lib/api/client';
import {
  convertCentsToReais,
  convertReaisToCents,
  formatCurrencyFromCents,
  type Plan,
} from '@/lib/subscriptions';

interface PlanFormProps {
  mode: 'create' | 'edit';
  planId?: number;
}

export function PlanForm({ mode, planId }: PlanFormProps) {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(mode === 'edit');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [plan, setPlan] = useState<Plan | null>(null);
  const [formData, setFormData] = useState({
    code: '',
    name: '',
    description: '',
    price: 0,
    durationDays: 30,
    color: '#6366f1',
    isActive: true,
  });

  const getErrorMessage = (errorValue: unknown, fallback: string) =>
    errorValue instanceof Error ? errorValue.message : fallback;

  const hydratePlan = useCallback(async () => {
    if (mode !== 'edit' || !planId) {
      return;
    }

    setIsLoading(true);
    setError(null);

    try {
      const plansResponse = await fetchApi('/admin/plans');
      const plansData = plansResponse as Plan[];
      const currentPlan = plansData.find((item) => item.id === planId) || null;

      if (!currentPlan) {
        throw new Error('Plano não encontrado.');
      }

      setPlan(currentPlan);
      setFormData({
        code: currentPlan.code.toLowerCase(),
        name: currentPlan.name,
        description: currentPlan.description || '',
        price: convertCentsToReais(currentPlan.priceCents),
        durationDays: currentPlan.durationDays,
        color: currentPlan.color,
        isActive: currentPlan.isActive,
      });
    } catch (err: unknown) {
      setError(getErrorMessage(err, 'Erro ao carregar plano'));
    } finally {
      setIsLoading(false);
    }
  }, [mode, planId]);

  useEffect(() => {
    hydratePlan();
  }, [hydratePlan]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setError(null);

    try {
      const normalizedCode = formData.code.trim().toLowerCase();
      const payload = {
        code: normalizedCode,
        name: formData.name,
        description: formData.description,
        priceCents: convertReaisToCents(formData.price),
        durationDays: Number(formData.durationDays),
        color: formData.color,
        isActive: formData.isActive,
      };

      if (mode === 'edit' && planId) {
        await fetchApi(`/admin/plans/${planId}`, {
          method: 'PATCH',
          body: JSON.stringify(payload),
        });
      } else {
        await fetchApi('/admin/plans', {
          method: 'POST',
          body: JSON.stringify(payload),
        });
      }

      router.push('/plans');
    } catch (err: unknown) {
      setError(getErrorMessage(err, 'Erro ao salvar plano'));
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isLoading) {
    return (
      <div className="p-10 flex h-[70vh] items-center justify-center">
        <Loader2 className="w-10 h-10 text-indigo-600 animate-spin" />
      </div>
    );
  }

  return (
    <div className="p-6 sm:p-8 lg:p-10 space-y-8 animate-fade-in-up">
      <div className="flex flex-col gap-4">
        <Link href="/plans" className="inline-flex items-center gap-2 text-sm font-semibold text-slate-500 hover:text-indigo-600 transition-colors">
          <ArrowLeft className="w-4 h-4" />
          Voltar para planos
        </Link>

        <div className="rounded-[2rem] border border-[var(--border)] bg-gradient-to-r from-slate-50/90 via-white/80 to-indigo-50/70 dark:from-slate-900/90 dark:via-slate-900/80 dark:to-indigo-950/40 px-6 sm:px-8 py-6 shadow-sm">
          <div className="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-6">
            <div className="flex items-start gap-4 min-w-0">
              <div
                className="w-14 h-14 rounded-2xl text-white flex items-center justify-center shadow-xl shadow-indigo-500/25 shrink-0"
                style={{ backgroundColor: formData.color || '#6366f1' }}
              >
                {mode === 'edit' ? <Edit2 className="w-6 h-6" /> : <Plus className="w-6 h-6" />}
              </div>
              <div className="min-w-0 space-y-3">
                <div>
                  <p className="text-[11px] font-bold uppercase tracking-[0.24em] text-indigo-500">Gestão de planos</p>
                  <h1 className="text-3xl font-bold tracking-tight text-slate-900 dark:text-white">
                    {mode === 'edit' ? `Editar ${plan?.name || 'plano'}` : 'Novo plano'}
                  </h1>
                  <p className="text-sm text-slate-500 dark:text-slate-400">
                    {mode === 'edit'
                      ? 'Atualize preço, código e disponibilidade sem sair da tela.'
                      : 'Cadastre um novo plano com preço em reais e envio em centavos.'}
                  </p>
                </div>
                <div className="flex flex-wrap gap-2">
                  <span className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/80 dark:bg-slate-950/60 border border-[var(--border)] text-xs font-bold text-slate-600 dark:text-slate-300">
                    <CreditCard className="w-3.5 h-3.5" />
                    {formData.code || 'Sem código'}
                  </span>
                  <span className={`inline-flex items-center gap-2 px-3 py-1.5 rounded-full border text-xs font-bold ${
                    formData.durationDays >= 365
                      ? 'bg-amber-50 dark:bg-amber-900/20 border-amber-200 dark:border-amber-900/30 text-amber-600 dark:text-amber-400'
                      : 'bg-indigo-50 dark:bg-indigo-900/20 border-indigo-200 dark:border-indigo-900/30 text-indigo-600 dark:text-indigo-400'
                  }`}>
                    {formData.durationDays >= 365 ? <Crown className="w-3.5 h-3.5" /> : <Zap className="w-3.5 h-3.5" />}
                    {formData.durationDays} dias
                  </span>
                  <span className={`inline-flex items-center gap-2 px-3 py-1.5 rounded-full border text-xs font-bold ${
                    formData.isActive
                      ? 'bg-emerald-50 dark:bg-emerald-900/20 border-emerald-200 dark:border-emerald-900/30 text-emerald-600 dark:text-emerald-400'
                      : 'bg-slate-100 dark:bg-slate-800 border-slate-200 dark:border-slate-700 text-slate-500 dark:text-slate-400'
                  }`}>
                    <div className={`w-2 h-2 rounded-full ${formData.isActive ? 'bg-emerald-500' : 'bg-slate-400'}`}></div>
                    {formData.isActive ? 'Ativo' : 'Pausado'}
                  </span>
                </div>
              </div>
            </div>

            <div className="rounded-2xl border border-[var(--border)] bg-white/75 dark:bg-slate-950/40 px-4 py-3 min-w-[220px]">
              <p className="text-[11px] font-bold uppercase tracking-widest text-slate-400">Prévia do preço</p>
              <p className="text-lg font-bold mt-1 text-slate-900 dark:text-white">
                {formatCurrencyFromCents(convertReaisToCents(formData.price))}
              </p>
            </div>
          </div>
        </div>
      </div>

      {error && (
        <div className="flex items-center gap-3 p-4 bg-red-50 dark:bg-red-900/10 border border-red-100 dark:border-red-900/20 rounded-2xl text-red-600 dark:text-red-400">
          <AlertCircle className="w-5 h-5 shrink-0" />
          <p className="text-sm font-medium">{error}</p>
        </div>
      )}

      <div className="grid grid-cols-1 xl:grid-cols-[minmax(0,1fr)_340px] gap-6">
        <form onSubmit={handleSubmit} className="rounded-[2rem] border border-[var(--border)] bg-[var(--card)] p-6 sm:p-8 space-y-8 shadow-sm">
          <div className="flex items-center gap-3">
            <div className="p-2.5 bg-slate-100 dark:bg-slate-900 rounded-xl text-slate-600 dark:text-slate-300">
              <Type className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-lg font-bold">Dados do plano</h2>
              <p className="text-sm text-slate-500 dark:text-slate-400">Defina identidade, preço, duração e descrição comercial.</p>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Código do Plano</label>
              <div className="relative group">
                <CreditCard className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 group-focus-within:text-indigo-500 transition-colors" />
                <input
                  required
                  type="text"
                  className="w-full pl-11 pr-4 py-3.5 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all font-medium"
                  placeholder="Ex: premium_monthly"
                  value={formData.code}
                  onChange={(e) => setFormData({ ...formData, code: e.target.value.toLowerCase() })}
                />
              </div>
            </div>
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Nome do Plano</label>
              <div className="relative group">
                <Type className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 group-focus-within:text-indigo-500 transition-colors" />
                <input
                  required
                  type="text"
                  className="w-full pl-11 pr-4 py-3.5 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all font-medium"
                  placeholder="Ex: Prata"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                />
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Preço (R$)</label>
              <div className="relative group">
                <DollarSign className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 group-focus-within:text-indigo-500 transition-colors" />
                <input
                  required
                  type="number"
                  step="0.01"
                  className="w-full pl-11 pr-4 py-3.5 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all font-medium"
                  placeholder="0.00"
                  value={formData.price}
                  onChange={(e) => setFormData({ ...formData, price: Number(e.target.value) })}
                />
              </div>
            </div>
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Duração (Dias)</label>
              <input
                required
                type="number"
                className="w-full px-4 py-3.5 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all font-medium"
                value={formData.durationDays}
                onChange={(e) => setFormData({ ...formData, durationDays: Number(e.target.value) })}
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Cor do Card</label>
              <input
                type="color"
                className="w-full h-[54px] p-2 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all cursor-pointer"
                value={formData.color}
                onChange={(e) => setFormData({ ...formData, color: e.target.value })}
              />
            </div>
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Status de Disponibilidade</label>
              <div className="grid grid-cols-2 gap-4">
                <button type="button" onClick={() => setFormData({ ...formData, isActive: true })} className={`py-3.5 rounded-2xl border transition-all font-semibold ${formData.isActive ? 'bg-emerald-50 border-emerald-500 text-emerald-600' : 'border-slate-200 text-slate-400'}`}>
                  Ativo
                </button>
                <button type="button" onClick={() => setFormData({ ...formData, isActive: false })} className={`py-3.5 rounded-2xl border transition-all font-semibold ${!formData.isActive ? 'bg-slate-100 border-slate-400 text-slate-600' : 'border-slate-200 text-slate-400'}`}>
                  Pausado
                </button>
              </div>
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Descrição do Plano</label>
            <div className="relative group">
              <AlignLeft className="absolute left-4 top-4 w-4 h-4 text-slate-400 group-focus-within:text-indigo-500 transition-colors" />
              <textarea
                rows={5}
                className="w-full pl-11 pr-4 py-3.5 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all resize-none font-medium"
                placeholder="Quais as vantagens deste plano?"
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              />
            </div>
          </div>

          <div className="flex flex-col-reverse sm:flex-row gap-3 sm:items-center sm:justify-end pt-2">
            <button type="button" onClick={() => router.push('/plans')} className="px-6 py-3.5 text-sm font-bold text-slate-500 hover:text-slate-700 dark:hover:text-slate-300 transition-colors">
              Cancelar
            </button>
            <button disabled={isSubmitting} type="submit" className="min-w-[220px] px-6 py-3.5 text-sm font-bold text-white bg-indigo-600 rounded-2xl hover:bg-indigo-700 shadow-xl shadow-indigo-500/30 transition-all flex items-center justify-center gap-2 disabled:opacity-60">
              {isSubmitting ? (
                <Loader2 className="w-5 h-5 animate-spin" />
              ) : (
                <>
                  {mode === 'edit' ? 'Salvar Alterações' : 'Publicar Plano'}
                  <Check className="w-5 h-5" />
                </>
              )}
            </button>
          </div>
        </form>

        <aside className="rounded-[2rem] border border-[var(--border)] bg-white/70 dark:bg-slate-900/35 p-6 sm:p-7 space-y-6 shadow-sm self-start">
          <div className="flex items-center gap-3">
            <div
              className="w-12 h-12 rounded-2xl text-white flex items-center justify-center shadow-lg shadow-indigo-500/20"
              style={{ backgroundColor: formData.color || '#6366f1' }}
            >
              {formData.durationDays >= 365 ? <Crown className="w-5 h-5" /> : <Zap className="w-5 h-5" />}
            </div>
            <div>
              <h2 className="text-lg font-bold">Prévia do card</h2>
              <p className="text-sm text-slate-500 dark:text-slate-400">Visual instantâneo antes de salvar.</p>
            </div>
          </div>

          <div className="rounded-[1.5rem] border border-[var(--border)] bg-[var(--card)] p-5 space-y-4 shadow-sm">
            <div className="flex items-start justify-between gap-3">
              <div>
                <div className="flex items-center gap-2">
                  <h3 className="text-xl font-bold">{formData.name || 'Nome do plano'}</h3>
                  <span className="px-2.5 py-1 text-[10px] font-bold rounded-full bg-slate-100 dark:bg-slate-800 text-slate-500 dark:text-slate-400">
                    {formData.code || 'COD'}
                  </span>
                </div>
                <p className="text-sm text-slate-500 dark:text-slate-400 mt-2">
                  {formData.description || 'A descrição do plano aparecerá aqui conforme você digita.'}
                </p>
              </div>
            </div>

            <div>
              <p className="text-3xl font-black tracking-tight text-slate-900 dark:text-white">
                {formatCurrencyFromCents(convertReaisToCents(formData.price))}
              </p>
              <p className="text-sm font-semibold text-slate-400 mt-1">/{formData.durationDays} dias</p>
            </div>

            <div className={`inline-flex px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border ${
              formData.isActive
                ? 'bg-emerald-50 dark:bg-emerald-900/20 text-emerald-600 border-emerald-200 dark:border-emerald-800'
                : 'bg-slate-100 dark:bg-slate-800 text-slate-400 border-slate-200 dark:border-slate-700'
            }`}>
              {formData.isActive ? 'Ativo' : 'Pausado'}
            </div>
          </div>
        </aside>
      </div>
    </div>
  );
}
