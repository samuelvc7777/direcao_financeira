'use client';

import { useState } from 'react';
import { 
  Plus, 
  Check, 
  X, 
  Edit2, 
  Trash2, 
  Users, 
  Zap, 
  Crown, 
  CreditCard 
} from 'lucide-react';

export default function PlansPage() {
  const [plans, setPlans] = useState([
    {
      id: '1',
      name: 'Grátis',
      price: 'R$ 0,00',
      period: 'sempre',
      description: 'Ideal para quem está começando agora.',
      features: ['Controle de ganhos básico', 'Até 50 corridas/mês', 'Relatório mensal simples'],
      usersCount: 428,
      status: 'Ativo',
      icon: Zap,
      color: 'blue'
    },
    {
      id: '2',
      name: 'Premium Mensal',
      price: 'R$ 29,90',
      period: 'por mês',
      description: 'Para motoristas que buscam o próximo nível.',
      features: ['Corridas ilimitadas', 'Gráficos avançados', 'Exportação de dados', 'Suporte prioritário'],
      usersCount: 856,
      status: 'Ativo',
      icon: Crown,
      color: 'amber'
    },
    {
      id: '3',
      name: 'Premium Anual',
      price: 'R$ 249,90',
      period: 'por ano',
      description: 'Economia máxima para o profissional.',
      features: ['Todas as funções Premium', 'Desconto de 30% anual', 'Acesso antecipado a novos recursos'],
      usersCount: 312,
      status: 'Ativo',
      icon: CreditCard,
      color: 'indigo'
    }
  ]);

  return (
    <div className="p-10 space-y-8 animate-fade-in-up">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Planos & Assinaturas</h1>
          <p className="text-sm text-slate-500 dark:text-slate-400">Gerencie os modelos de monetização e benefícios dos usuários.</p>
        </div>
        <button className="flex items-center gap-2 px-4 py-2 text-sm font-semibold text-white bg-indigo-600 rounded-xl hover:bg-indigo-700 shadow-lg shadow-indigo-500/20 transition-all active:scale-[0.98]">
          <Plus className="w-4 h-4" /> Criar Novo Plano
        </button>
      </div>

      {/* Grid de Planos */}
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-8">
        {plans.map((plan) => (
          <div key={plan.id} className="bg-[var(--card)] rounded-3xl border border-[var(--border)] shadow-sm hover:shadow-xl transition-all flex flex-col overflow-hidden group">
            <div className="p-8 space-y-6">
              <div className="flex justify-between items-start">
                <div className={`p-3 rounded-2xl bg-${plan.color}-50 dark:bg-${plan.color}-900/20 text-${plan.color}-600 dark:text-${plan.color}-400`}>
                  <plan.icon className="w-6 h-6" />
                </div>
                <div className="flex gap-2">
                  <button className="p-2 text-slate-400 hover:text-indigo-600 dark:hover:text-indigo-400 hover:bg-slate-50 dark:hover:bg-slate-800 rounded-lg transition-colors">
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button className="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-colors">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              <div>
                <h3 className="text-xl font-bold">{plan.name}</h3>
                <div className="flex items-baseline gap-1 mt-2">
                  <span className="text-3xl font-black">{plan.price}</span>
                  <span className="text-sm text-slate-500 dark:text-slate-500">{plan.period}</span>
                </div>
                <p className="mt-4 text-sm text-slate-500 dark:text-slate-400 leading-relaxed">
                  {plan.description}
                </p>
              </div>

              <div className="space-y-3 pt-4 border-t border-[var(--border)]">
                <p className="text-xs font-bold text-slate-400 uppercase tracking-widest">O que inclui:</p>
                {plan.features.map((feature, idx) => (
                  <div key={idx} className="flex items-center gap-2 text-sm text-slate-600 dark:text-slate-300">
                    <Check className="w-4 h-4 text-emerald-500 shrink-0" />
                    {feature}
                  </div>
                ))}
              </div>
            </div>

            <div className="mt-auto p-6 bg-slate-50/50 dark:bg-slate-800/30 border-t border-[var(--border)] flex items-center justify-between">
              <div className="flex items-center gap-2 text-sm font-medium text-slate-600 dark:text-slate-400">
                <Users className="w-4 h-4" />
                {plan.usersCount} usuários
              </div>
              <span className="text-xs font-bold text-emerald-500 uppercase">Ativo</span>
            </div>
          </div>
        ))}
      </div>
      
      {/* Informações Extras */}
      <div className="p-8 bg-indigo-50/50 dark:bg-indigo-950/10 border border-indigo-100 dark:border-indigo-900/20 rounded-3xl flex flex-col md:flex-row items-center gap-6">
        <div className="p-4 bg-indigo-600 rounded-2xl text-white">
          <Zap className="w-8 h-8" />
        </div>
        <div className="flex-1 text-center md:text-left">
          <h4 className="text-lg font-bold">Dica de Monetização</h4>
          <p className="text-sm text-slate-600 dark:text-slate-400">Usuários no plano Premium Anual possuem uma taxa de retenção 45% maior do que no mensal. Considere oferecer um mês grátis para novos upgrades.</p>
        </div>
        <button className="px-6 py-3 bg-white dark:bg-slate-800 border border-indigo-200 dark:border-indigo-900/30 text-indigo-600 dark:text-indigo-400 font-bold text-sm rounded-xl hover:shadow-md transition-all">
          Ver Estatísticas Detalhadas
        </button>
      </div>
    </div>
  );
}
