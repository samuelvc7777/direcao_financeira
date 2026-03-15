'use client';

import { useState, useEffect } from 'react';
import { 
  Plus, 
  Check, 
  Edit2, 
  Trash2, 
  Users, 
  Zap, 
  Crown, 
  CreditCard,
  Loader2,
  AlertCircle,
  X,
  Type,
  DollarSign,
  AlignLeft,
  Activity
} from 'lucide-react';
import { fetchApi } from '@/lib/api/client';

interface Plan {
  id: string;
  name: string;
  description: string | null;
  price: number;
  isActive: boolean;
  durationDays: number;
  color: string;
  createdAt: string;
  _count?: {
    users: number;
  };
}

export default function PlansPage() {
  const [plans, setPlans] = useState<Plan[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [editingPlan, setEditingPlan] = useState<Plan | null>(null);
  
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    price: 0,
    durationDays: 30,
    color: '#6366f1',
    isActive: true
  });

  const loadPlans = async () => {
    setIsLoading(true);
    try {
      const data = await fetchApi('/admin/plans');
      setPlans(data);
    } catch (err: any) {
      setError(err.message || 'Erro ao carregar planos');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadPlans();
  }, []);

  const handleOpenModal = (plan?: Plan) => {
    if (plan) {
      setEditingPlan(plan);
      setFormData({
        name: plan.name,
        description: plan.description || '',
        price: plan.price,
        durationDays: plan.durationDays,
        color: plan.color,
        isActive: plan.isActive
      });
    } else {
      setEditingPlan(null);
      setFormData({ name: '', description: '', price: 0, durationDays: 30, color: '#6366f1', isActive: true });
    }
    setIsModalOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      const payload = {
        ...formData,
        price: Number(formData.price),
        durationDays: Number(formData.durationDays)
      };

      if (editingPlan) {
        await fetchApi(`/admin/plans/${editingPlan.id}`, {
          method: 'PATCH',
          body: JSON.stringify(payload)
        });
      } else {
        await fetchApi('/admin/plans', {
          method: 'POST',
          body: JSON.stringify(payload)
        });
      }
      
      setIsModalOpen(false);
      loadPlans();
    } catch (err: any) {
      alert(err.message || 'Erro ao salvar plano');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Tem certeza que deseja excluir este plano?')) return;
    try {
      await fetchApi(`/admin/plans/${id}`, { method: 'DELETE' });
      loadPlans();
    } catch (err: any) {
      alert(err.message || 'Erro ao excluir plano');
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
    <div className="relative">
      <div className="p-10 space-y-8 animate-fade-in-up">
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold tracking-tight">Planos & Assinaturas</h1>
            <p className="text-sm text-slate-500 dark:text-slate-400">Gerencie os modelos de monetização e benefícios dos usuários.</p>
          </div>
          <button 
            onClick={() => handleOpenModal()}
            className="flex items-center gap-2 px-6 py-3 text-sm font-bold text-white bg-indigo-600 rounded-2xl hover:bg-indigo-700 shadow-xl shadow-indigo-500/20 transition-all active:scale-[0.98]"
          >
            <Plus className="w-5 h-5" /> Novo Plano
          </button>
        </div>

        {error && (
          <div className="flex items-center gap-3 p-4 bg-red-50 dark:bg-red-900/10 border border-red-100 dark:border-red-900/20 rounded-2xl text-red-600 dark:text-red-400">
            <AlertCircle className="w-5 h-5 shrink-0" />
            <p className="text-sm font-medium">{error}</p>
          </div>
        )}

        {/* Grid de Planos */}
        <div className="grid grid-cols-1 xl:grid-cols-3 gap-8">
          {plans.map((plan) => (
            <div key={plan.id} className="bg-[var(--card)] rounded-[2.5rem] border border-[var(--border)] shadow-sm hover:shadow-2xl hover:-translate-y-1 transition-all duration-300 flex flex-col overflow-hidden group">
              <div className="p-8 space-y-6">
                <div className="flex justify-between items-start">
                  <div className="p-4 rounded-2xl bg-indigo-50 dark:bg-indigo-900/20 text-indigo-600 dark:text-indigo-400 group-hover:scale-110 transition-transform duration-300">
                    {plan.name.toLowerCase().includes('anual') ? <Crown className="w-6 h-6" /> : <Zap className="w-6 h-6" />}
                  </div>
                  <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                    <button onClick={() => handleOpenModal(plan)} className="p-2.5 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 dark:hover:bg-indigo-950/50 rounded-xl transition-all">
                      <Edit2 className="w-4 h-4" />
                    </button>
                    <button onClick={() => handleDelete(plan.id)} className="p-2.5 text-slate-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-900/30 rounded-xl transition-all">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>

                <div>
                  <h3 className="text-xl font-bold tracking-tight">{plan.name}</h3>
                  <div className="flex items-baseline gap-1 mt-3">
                    <span className="text-4xl font-black tracking-tighter">
                      {plan.price.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })}
                    </span>
                    <span className="text-sm font-bold text-slate-400">
                      {plan.name.toLowerCase().includes('anual') ? '/ano' : '/mês'}
                    </span>
                  </div>
                  <p className="mt-4 text-sm text-slate-500 dark:text-slate-400 leading-relaxed min-h-[48px]">
                    {plan.description || 'Defina os benefícios deste plano para atrair novos motoristas.'}
                  </p>
                </div>
              </div>

              <div className="mt-auto p-6 bg-slate-50/50 dark:bg-slate-900/20 border-t border-[var(--border)] flex items-center justify-between">
                <div className="flex items-center gap-2 text-sm font-bold text-slate-600 dark:text-slate-400">
                  <div className="flex -space-x-2">
                    {[1,2,3].map(i => (
                      <div key={i} className="w-6 h-6 rounded-full border-2 border-white dark:border-slate-800 bg-slate-200 dark:bg-slate-700 overflow-hidden text-[8px] flex items-center justify-center">
                        <Users className="w-3 h-3" />
                      </div>
                    ))}
                  </div>
                  <span className="ml-1">{plan._count?.users || 0} usuários</span>
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

      {/* MODAL MELHORADO - Z-INDEX MÁXIMO E DESIGN PREMIUM */}
      {isModalOpen && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-6 sm:p-10">
          {/* Backdrop com desfoque pesado */}
          <div 
            className="absolute inset-0 bg-slate-950/60 backdrop-blur-md animate-in fade-in duration-300"
            onClick={() => !isSubmitting && setIsModalOpen(false)}
          />
          
          {/* Card do Modal */}
          <div className="relative w-full max-w-xl bg-[var(--card)] rounded-[2.5rem] border border-[var(--border)] shadow-[0_32px_64px_-16px_rgba(0,0,0,0.3)] overflow-hidden animate-in zoom-in-95 duration-300">
            <div className="px-8 py-6 border-b border-[var(--border)] flex justify-between items-center bg-slate-50/50 dark:bg-slate-900/50">
              <div className="flex items-center gap-3">
                <div className="p-2.5 bg-indigo-600 rounded-xl text-white">
                  {editingPlan ? <Edit2 className="w-5 h-5" /> : <Plus className="w-5 h-5" />}
                </div>
                <div>
                  <h3 className="text-xl font-bold tracking-tight">{editingPlan ? 'Editar Plano' : 'Novo Plano'}</h3>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Configurações de Produto</p>
                </div>
              </div>
              <button 
                onClick={() => setIsModalOpen(false)} 
                className="p-2 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-xl transition-all"
              >
                <X className="w-6 h-6" />
              </button>
            </div>
            
            <form onSubmit={handleSubmit} className="p-8 space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Nome */}
                <div className="space-y-2">
                  <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Nome do Plano</label>
                  <div className="relative group">
                    <Type className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 group-focus-within:text-indigo-500 transition-colors" />
                    <input 
                      required
                      type="text" 
                      className="w-full pl-11 pr-4 py-3 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all font-medium"
                      placeholder="Ex: Gold Anual"
                      value={formData.name}
                      onChange={e => setFormData({...formData, name: e.target.value})}
                    />
                  </div>
                </div>

                {/* Preço */}
                <div className="space-y-2">
                  <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Preço (R$)</label>
                  <div className="relative group">
                    <DollarSign className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 group-focus-within:text-indigo-500 transition-colors" />
                    <input 
                      required
                      type="number" 
                      step="0.01"
                      className="w-full pl-11 pr-4 py-3 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all font-medium"
                      placeholder="0.00"
                      value={formData.price}
                      onChange={e => setFormData({...formData, price: Number(e.target.value)})}
                    />
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Duração (Dias)</label>
                  <input 
                    required
                    type="number" 
                    className="w-full px-4 py-3 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all font-medium"
                    value={formData.durationDays}
                    onChange={e => setFormData({...formData, durationDays: Number(e.target.value)})}
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Cor do Card</label>
                  <input 
                    type="color" 
                    className="w-full h-[52px] p-2 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all cursor-pointer"
                    value={formData.color}
                    onChange={e => setFormData({...formData, color: e.target.value})}
                  />
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Status de Disponibilidade</label>
                <div className="flex gap-4">
                  <button type="button" onClick={() => setFormData({...formData, isActive: true})} className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-2xl border transition-all ${formData.isActive ? 'bg-emerald-50 border-emerald-500 text-emerald-600' : 'border-slate-200 text-slate-400'}`}>
                    Ativo
                  </button>
                  <button type="button" onClick={() => setFormData({...formData, isActive: false})} className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-2xl border transition-all ${!formData.isActive ? 'bg-slate-100 border-slate-400 text-slate-600' : 'border-slate-200 text-slate-400'}`}>
                    Pausado
                  </button>
                </div>
              </div>

              {/* Descrição */}
              <div className="space-y-2">
                <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Descrição do Plano</label>
                <div className="relative group">
                  <AlignLeft className="absolute left-4 top-4 w-4 h-4 text-slate-400 group-focus-within:text-indigo-500 transition-colors" />
                  <textarea 
                    rows={3}
                    className="w-full pl-11 pr-4 py-3 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all resize-none font-medium"
                    placeholder="Quais as vantagens deste plano?"
                    value={formData.description}
                    onChange={e => setFormData({...formData, description: e.target.value})}
                  />
                </div>
              </div>

              {/* Footer Buttons */}
              <div className="flex gap-4 pt-4">
                <button 
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="flex-1 py-4 text-sm font-bold text-slate-500 hover:text-slate-700 dark:hover:text-slate-300 transition-colors"
                >
                  Descartar
                </button>
                <button 
                  disabled={isSubmitting}
                  type="submit"
                  className="flex-[2] py-4 text-sm font-bold text-white bg-indigo-600 rounded-2xl hover:bg-indigo-700 shadow-xl shadow-indigo-500/30 transition-all flex items-center justify-center gap-2 group"
                >
                  {isSubmitting ? (
                    <Loader2 className="w-5 h-5 animate-spin" />
                  ) : (
                    <>
                      {editingPlan ? 'Salvar Alterações' : 'Publicar Plano'}
                      <Check className="w-5 h-5 group-hover:scale-110 transition-transform" />
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
