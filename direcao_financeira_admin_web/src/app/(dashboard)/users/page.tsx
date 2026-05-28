'use client';

import { useState, useEffect, useCallback } from 'react';
import Link from 'next/link';
import {
  Search,
  Download,
  Shield,
  Loader2,
  AlertCircle,
  Edit2,
  Trash2,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react';
import { fetchApi } from '@/lib/api/client';
import { ResponsiveContainer } from '@/components/layout/responsive-container';
import { mapUserToListItem, type User, type UserListItem } from '@/lib/subscriptions';

interface Meta {
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export default function UsersPage() {
  const [users, setUsers] = useState<UserListItem[]>([]);
  const [meta, setMeta] = useState<Meta | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [limit] = useState(10);

  const getErrorMessage = (error: unknown, fallback: string) =>
    error instanceof Error ? error.message : fallback;

  const loadData = useCallback(async () => {
    setIsLoading(true);
    setError(null);

    try {
      const usersResponse = await fetchApi('/user');
      const usersData = Array.isArray(usersResponse) ? usersResponse : usersResponse.data || [];
      const normalizedUsers = usersData as User[];
      const normalizedTerm = searchTerm.trim().toLowerCase();
      const filteredUsers = normalizedUsers.filter((user) => {
        if (!normalizedTerm) {
          return true;
        }

        return (
          user.name.toLowerCase().includes(normalizedTerm) ||
          user.email.toLowerCase().includes(normalizedTerm)
        );
      });

      const startIndex = (currentPage - 1) * limit;
      const paginatedUsers = filteredUsers.slice(startIndex, startIndex + limit);

      setUsers(paginatedUsers.map(mapUserToListItem));
      setMeta({
        total: filteredUsers.length,
        page: currentPage,
        limit,
        totalPages: Math.max(1, Math.ceil(filteredUsers.length / limit)),
      });
    } catch (err: unknown) {
      setError(getErrorMessage(err, 'Erro ao carregar dados'));
    } finally {
      setIsLoading(false);
    }
  }, [currentPage, limit, searchTerm]);

  useEffect(() => {
    const handler = setTimeout(() => {
      setCurrentPage(1);
    }, 400);

    return () => clearTimeout(handler);
  }, [searchTerm]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const handleDelete = async (id: number) => {
    if (!confirm('Deseja excluir este usuário?')) return;

    try {
      await fetchApi(`/user/${id}`, { method: 'DELETE' });
      await loadData();
    } catch (err: unknown) {
      alert(getErrorMessage(err, 'Erro ao excluir usuário'));
    }
  };

  return (
    <ResponsiveContainer>
    <div className="space-y-8 animate-fade-in-up">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Gestão de Usuários</h1>
          <p className="text-sm text-slate-500 dark:text-slate-400">
            Total de {meta?.total || 0} usuários cadastrados.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button className="flex items-center gap-2 px-4 py-2 text-sm font-semibold text-slate-600 dark:text-slate-300 bg-white dark:bg-slate-800 border border-[var(--border)] rounded-xl hover:bg-slate-50 transition-all">
            <Download className="w-4 h-4" /> Exportar
          </button>
        </div>
      </div>

      {error && (
        <div className="flex items-center gap-3 p-4 bg-red-50 dark:bg-red-900/10 border border-red-100 dark:border-red-900/20 rounded-2xl text-red-600 dark:text-red-400">
          <AlertCircle className="w-5 h-5 shrink-0" />
          <p className="text-sm font-medium">{error}</p>
        </div>
      )}

      <div className="flex flex-col md:flex-row gap-4">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Pesquisar por Nome ou E-mail..."
            className="w-full pl-10 pr-4 py-2.5 bg-white dark:bg-slate-900 border border-[var(--border)] rounded-xl outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>

      <div className="bg-[var(--card)] rounded-3xl border border-[var(--border)] shadow-sm overflow-hidden relative min-h-[400px]">
        {isLoading && (
          <div className="absolute inset-0 bg-white/50 dark:bg-slate-950/50 backdrop-blur-[2px] z-10 flex items-center justify-center">
            <Loader2 className="w-10 h-10 text-indigo-600 animate-spin" />
          </div>
        )}

        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="bg-slate-50/50 dark:bg-slate-800/30 border-b border-[var(--border)]">
                <th className="px-4 sm:px-6 lg:px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">Usuário</th>
                <th className="px-4 sm:px-6 lg:px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">Cargo</th>
                <th className="px-4 sm:px-6 lg:px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">Plano</th>
                <th className="px-4 sm:px-6 lg:px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest text-right">Ações</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
              {users.map((user) => (
                <tr key={user.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors group">
                  <td className="px-4 sm:px-6 lg:px-8 py-5">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-indigo-100 dark:bg-indigo-900/30 flex items-center justify-center text-xs font-bold text-indigo-600 dark:text-indigo-400">
                        {user.name.split(' ').map((name) => name[0]).join('').slice(0, 2).toUpperCase()}
                      </div>
                      <div>
                        <p className="text-sm font-bold">{user.name}</p>
                        <p className="text-xs text-slate-400 dark:text-slate-500">{user.email}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-4 sm:px-6 lg:px-8 py-5">
                    <div className="flex items-center gap-1.5 text-xs font-semibold">
                      <Shield className={`w-3.5 h-3.5 ${user.roleLabel.name === 'ADMIN' ? 'text-amber-500' : 'text-blue-500'}`} />
                      <span className={user.roleLabel.name === 'ADMIN' ? 'text-amber-600' : 'text-slate-600 dark:text-slate-400'}>
                        {user.roleLabel.name}
                      </span>
                    </div>
                  </td>
                  <td className="px-4 sm:px-6 lg:px-8 py-5">
                    <div className="space-y-2">
                      <span className={`inline-flex px-3 py-1 text-[10px] font-bold rounded-full uppercase ${
                        user.activePlan
                          ? 'bg-indigo-50 dark:bg-indigo-900/20 text-indigo-600 dark:text-indigo-400'
                          : 'bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400'
                      }`}>
                        {user.activePlan?.name || 'Sem Plano'}
                      </span>
                      <div className="flex items-center gap-1.5">
                        <div className={`w-1.5 h-1.5 rounded-full ${user.isActive ? 'bg-emerald-500' : 'bg-red-500'}`}></div>
                        <span className="text-xs font-medium text-slate-500 dark:text-slate-400">
                          {user.isActive ? 'Acesso ativo' : 'Acesso bloqueado'}
                          {user.subscriptionStatus ? ` • ${user.subscriptionStatus}` : ''}
                        </span>
                      </div>
                    </div>
                  </td>
                  <td className="px-4 sm:px-6 lg:px-8 py-5 text-right">
                    <div className="flex justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <Link href={`/users/${user.id}`} className="p-2 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 dark:hover:bg-indigo-950/50 rounded-lg transition-all">
                        <Edit2 className="w-4 h-4" />
                      </Link>
                      <button onClick={() => handleDelete(user.id)} className="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-900/50 rounded-lg transition-all">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {meta && meta.totalPages > 1 && (
          <div className="p-6 border-t border-[var(--border)] flex items-center justify-between bg-slate-50/30 dark:bg-slate-900/30">
            <p className="text-xs text-slate-500 font-medium">
              Mostrando página <span className="text-slate-900 dark:text-white font-bold">{meta.page}</span> de {meta.totalPages}
            </p>
            <div className="flex gap-2">
              <button
                disabled={meta.page <= 1 || isLoading}
                onClick={() => setCurrentPage((prev) => prev - 1)}
                className="p-2 rounded-lg border border-[var(--border)] hover:bg-white dark:hover:bg-slate-800 disabled:opacity-30 disabled:cursor-not-allowed transition-all"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>
              <button
                disabled={meta.page >= meta.totalPages || isLoading}
                onClick={() => setCurrentPage((prev) => prev + 1)}
                className="p-2 rounded-lg border border-[var(--border)] hover:bg-white dark:hover:bg-slate-800 disabled:opacity-30 disabled:cursor-not-allowed transition-all"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
    </ResponsiveContainer>
  );
}

