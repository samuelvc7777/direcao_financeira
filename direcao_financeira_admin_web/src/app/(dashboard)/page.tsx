"use client"

import { 
  Users, 
  Gem, 
  TrendingUp, 
  ChevronRight,
  MoreHorizontal
} from "lucide-react"
import Link from "next/link";

export default function Home() {
  return (
    <div className="p-10 space-y-10 animate-fade-in-up">
      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div className="p-6 bg-[var(--card)] rounded-3xl border border-[var(--border)] shadow-sm hover:shadow-md transition-all group">
          <div className="w-12 h-12 bg-indigo-50 dark:bg-indigo-900/20 text-indigo-600 dark:text-indigo-400 rounded-2xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
            <Users className="h-6 w-6" />
          </div>
          <p className="text-sm font-medium text-slate-400 dark:text-slate-500">Total de Usuários</p>
          <div className="flex items-end gap-2 mt-1">
            <h3 className="text-2xl font-bold">1,284</h3>
            <span className="text-xs font-bold text-emerald-500 pb-1">+12% vs mês anterior</span>
          </div>
        </div>
        
        <div className="p-6 bg-[var(--card)] rounded-3xl border border-[var(--border)] shadow-sm hover:shadow-md transition-all group">
          <div className="w-12 h-12 bg-amber-50 dark:bg-amber-900/20 text-amber-600 dark:text-amber-400 rounded-2xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
            <Gem className="h-6 w-6" />
          </div>
          <p className="text-sm font-medium text-slate-400 dark:text-slate-500">Planos Ativos</p>
          <div className="flex items-end gap-2 mt-1">
            <h3 className="text-2xl font-bold">856</h3>
            <span className="text-xs font-bold text-emerald-500 pb-1">67% de conversão</span>
          </div>
        </div>

        <div className="p-6 bg-[var(--card)] rounded-3xl border border-[var(--border)] shadow-sm hover:shadow-md transition-all group">
          <div className="w-12 h-12 bg-emerald-50 dark:bg-emerald-900/20 text-emerald-600 dark:text-emerald-400 rounded-2xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
            <TrendingUp className="h-6 w-6" />
          </div>
          <p className="text-sm font-medium text-slate-400 dark:text-slate-500">Receita Estimada</p>
          <div className="flex items-end gap-2 mt-1">
            <h3 className="text-2xl font-bold">R$ 42.190</h3>
            <span className="text-xs font-bold text-slate-400 dark:text-slate-500 pb-1">Previsão Mensal</span>
          </div>
        </div>
      </div>

      {/* Table Section */}
      <div className="bg-[var(--card)] rounded-3xl border border-[var(--border)] shadow-sm overflow-hidden transition-colors duration-300">
        <div className="p-8 border-b border-[var(--border)] flex items-center justify-between">
          <h3 className="text-lg font-bold">Últimos Usuários Cadastrados</h3>
          <Link href="/users" className="text-sm font-bold text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300 flex items-center gap-1 group">
            Ver todos os usuários <ChevronRight className="h-4 w-4 group-hover:translate-x-1 transition-transform" />
          </Link>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="bg-slate-50/50 dark:bg-slate-800/30">
                <th className="px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">Usuário</th>
                <th className="px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">Plano</th>
                <th className="px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">Status</th>
                <th className="px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest text-right">Ações</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
              {[
                { name: "João Silva", email: "joao.silva@email.com", plan: "Premium Mensal", status: "Ativo", color: "bg-amber-50 dark:bg-amber-900/20 text-amber-600 dark:text-amber-400" },
                { name: "Maria Almeida", email: "maria.a@email.com", plan: "Grátis", status: "Ativo", color: "bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400" },
                { name: "Ricardo Costa", email: "ricardo.c@email.com", plan: "Premium Anual", status: "Pendente", color: "bg-indigo-50 dark:bg-indigo-900/20 text-indigo-600 dark:text-indigo-400", statusColor: "bg-amber-500" }
              ].map((user, i) => (
                <tr key={i} className="hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors">
                  <td className="px-8 py-5">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-indigo-100 dark:bg-indigo-900/30 flex items-center justify-center text-xs font-bold text-indigo-600 dark:text-indigo-400">
                        {user.name.split(' ').map(n => n[0]).join('')}
                      </div>
                      <div>
                        <p className="text-sm font-bold">{user.name}</p>
                        <p className="text-xs text-slate-400 dark:text-slate-500">{user.email}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-8 py-5">
                    <span className={`px-3 py-1 text-[10px] font-bold rounded-full uppercase ${user.color}`}>
                      {user.plan}
                    </span>
                  </td>
                  <td className="px-8 py-5">
                    <div className="flex items-center gap-1.5">
                      <div className={`w-1.5 h-1.5 rounded-full ${user.statusColor || 'bg-emerald-500'}`}></div>
                      <span className="text-xs font-medium text-slate-600 dark:text-slate-400">{user.status}</span>
                    </div>
                  </td>
                  <td className="px-8 py-5 text-right">
                    <button className="p-2 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg text-slate-400 dark:text-slate-600 transition-colors">
                      <MoreHorizontal className="h-5 w-5" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
