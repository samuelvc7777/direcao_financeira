'use client';

import { useState, useEffect } from 'react';
import { 
  Search, 
  MoreHorizontal, 
  UserPlus, 
  Filter,
  Download,
  Mail,
  Shield,
  CheckCircle2,
  XCircle
} from 'lucide-react';

export default function UsersPage() {
  const [searchTerm, setSearchTerm] = useState('');

  // Dados mockados para visualização inicial (conectaremos à API depois)
  const users = [
    { id: '1', name: "João Silva", email: "joao.silva@email.com", plan: "Premium Mensal", status: "Ativo", role: "Motorista", date: "12 Mar, 2026" },
    { id: '2', name: "Maria Almeida", email: "maria.a@email.com", plan: "Grátis", status: "Ativo", role: "Motorista", date: "11 Mar, 2026" },
    { id: '3', name: "Ricardo Costa", email: "ricardo.c@email.com", plan: "Premium Anual", status: "Pendente", role: "Motorista", date: "10 Mar, 2026" },
    { id: '4', name: "Ana Beatriz", email: "ana.b@email.com", plan: "Premium Mensal", status: "Inativo", role: "Motorista", date: "09 Mar, 2026" },
    { id: '5', name: "Samuel Vitor", email: "samuel@teste.com", plan: "N/A", status: "Ativo", role: "Admin", date: "01 Mar, 2026" },
  ];

  const filteredUsers = users.filter(user => 
    user.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
    user.email.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="p-10 space-y-8 animate-fade-in-up">
      {/* Header da Página */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Gestão de Usuários</h1>
          <p className="text-sm text-slate-500 dark:text-slate-400">Visualize e gerencie todos os usuários cadastrados na plataforma.</p>
        </div>
        <div className="flex items-center gap-3">
          <button className="flex items-center gap-2 px-4 py-2 text-sm font-semibold text-slate-600 dark:text-slate-300 bg-white dark:bg-slate-800 border border-[var(--border)] rounded-xl hover:bg-slate-50 dark:hover:bg-slate-700 transition-all">
            <Download className="w-4 h-4" /> Exportar
          </button>
          <button className="flex items-center gap-2 px-4 py-2 text-sm font-semibold text-white bg-indigo-600 rounded-xl hover:bg-indigo-700 shadow-lg shadow-indigo-500/20 transition-all active:scale-[0.98]">
            <UserPlus className="w-4 h-4" /> Novo Usuário
          </button>
        </div>
      </div>

      {/* Filtros e Busca */}
      <div className="flex flex-col md:flex-row gap-4">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <input 
            type="text" 
            placeholder="Buscar por nome ou e-mail..." 
            className="w-full pl-10 pr-4 py-2.5 bg-white dark:bg-slate-900 border border-[var(--border)] rounded-xl outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <button className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-slate-600 dark:text-slate-400 bg-white dark:bg-slate-900 border border-[var(--border)] rounded-xl hover:bg-slate-50 transition-all">
          <Filter className="w-4 h-4" /> Filtros
        </button>
      </div>

      {/* Tabela */}
      <div className="bg-[var(--card)] rounded-3xl border border-[var(--border)] shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="bg-slate-50/50 dark:bg-slate-800/30 border-b border-[var(--border)]">
                <th className="px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">Usuário</th>
                <th className="px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">Nível / Role</th>
                <th className="px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">Plano</th>
                <th className="px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">Status</th>
                <th className="px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">Cadastro</th>
                <th className="px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest text-right">Ações</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
              {filteredUsers.map((user) => (
                <tr key={user.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors group">
                  <td className="px-8 py-5">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-indigo-100 dark:bg-indigo-900/30 flex items-center justify-center text-xs font-bold text-indigo-600 dark:text-indigo-400">
                        {user.name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()}
                      </div>
                      <div>
                        <p className="text-sm font-bold">{user.name}</p>
                        <div className="flex items-center gap-1 text-xs text-slate-400 dark:text-slate-500">
                          <Mail className="w-3 h-3" /> {user.email}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-8 py-5">
                    <div className="flex items-center gap-1.5 text-xs font-semibold text-slate-600 dark:text-slate-400">
                      <Shield className={`w-3.5 h-3.5 ${user.role === 'Admin' ? 'text-amber-500' : 'text-blue-500'}`} />
                      {user.role}
                    </div>
                  </td>
                  <td className="px-8 py-5">
                    <span className={`px-3 py-1 text-[10px] font-bold rounded-full uppercase ${
                      user.plan.includes('Premium') 
                      ? 'bg-amber-50 dark:bg-amber-900/20 text-amber-600 dark:text-amber-400' 
                      : 'bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400'
                    }`}>
                      {user.plan}
                    </span>
                  </td>
                  <td className="px-8 py-5">
                    <div className="flex items-center gap-1.5">
                      {user.status === 'Ativo' ? (
                        <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500" />
                      ) : user.status === 'Pendente' ? (
                        <div className="w-1.5 h-1.5 rounded-full bg-amber-500" />
                      ) : (
                        <XCircle className="w-3.5 h-3.5 text-red-500" />
                      )}
                      <span className="text-xs font-medium text-slate-600 dark:text-slate-400">{user.status}</span>
                    </div>
                  </td>
                  <td className="px-8 py-5 text-xs text-slate-500 dark:text-slate-500 font-medium">{user.date}</td>
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
        {filteredUsers.length === 0 && (
          <div className="p-20 text-center">
            <p className="text-slate-500">Nenhum usuário encontrado para "{searchTerm}"</p>
          </div>
        )}
      </div>
    </div>
  );
}
