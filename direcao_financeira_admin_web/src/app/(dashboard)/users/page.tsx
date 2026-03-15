'use client';

import { useState, useEffect, useCallback } from 'react';
import { 
  Search, 
  MoreHorizontal, 
  Download,
  Mail,
  Shield,
  CheckCircle2,
  XCircle,
  Loader2,
  AlertCircle,
  X,
  Edit2,
  Trash2,
  User as UserIcon,
  Lock,
  Unlock,
  ChevronLeft,
  ChevronRight
} from 'lucide-react';
import { fetchApi } from '@/lib/api/client';

interface Role {
  id: string;
  name: string;
}

interface Plan {
  id: string;
  name: string;
}

interface User {
  id: string;
  name: string;
  email: string;
  isActive: boolean;
  planStatus: string;
  createdAt: string;
  role: Role;
  plan: Plan | null;
}

interface Meta {
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [meta, setMeta] = useState<Meta | null>(null);
  const [plans, setPlans] = useState<Plan[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  // States para Filtros e Paginação (Controlados pelo Back)
  const [searchTerm, setSearchTerm] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [limit] = useState(10);

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    isActive: true,
    planId: '',
    role: 'USER' as 'ADMIN' | 'USER'
  });

  const loadData = useCallback(async () => {
    setIsLoading(true);
    try {
      // Construindo a URL com filtros e paginação para o BACKEND
      const query = new URLSearchParams({
        page: String(currentPage),
        limit: String(limit),
        ...(searchTerm ? { name: searchTerm } : {})
      }).toString();

      const [usersResponse, plansData] = await Promise.all([
        fetchApi('/user'), // Backend atual usa /user
        fetchApi('/admin/plans').catch(() => []) // Silencia erro se plans não existir
      ]);

      // Adapta o retorno simples do backend para o formato com metadados do frontend
      const usersData = Array.isArray(usersResponse) ? usersResponse : usersResponse.data || [];
      const mappedUsers = usersData.map((u: any) => ({
        ...u,
        role: typeof u.role === 'string' ? { id: u.role, name: u.role } : u.role,
        plan: u.plan || { id: 'none', name: 'Sem Plano' }
      }));

      setUsers(mappedUsers);
      setMeta(usersResponse.meta || {
        total: mappedUsers.length,
        page: 1,
        limit: 10,
        totalPages: 1
      });
      setPlans(plansData);
    } catch (err: any) {
      setError(err.message || 'Erro ao carregar dados');
    } finally {
      setIsLoading(false);
    }
  }, [currentPage, searchTerm, limit]);

  // Debounce para a busca
  useEffect(() => {
    const handler = setTimeout(() => {
      setCurrentPage(1); 
      loadData();
    }, 400);

    return () => clearTimeout(handler);
  }, [searchTerm, loadData]);

  const handleOpenModal = (user: User) => {
    setEditingUser(user);
    setFormData({
      name: user.name,
      email: user.email,
      isActive: user.isActive,
      planId: user.plan?.id || '',
      role: user.role.name as any
    });
    setIsModalOpen(true);
  };

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
          isActive: formData.isActive,
          planId: formData.planId ? Number(formData.planId) : null,
          role: formData.role
        })
      });
      setIsModalOpen(false);
      loadData();
    } catch (err: any) {
      alert(err.message || 'Erro ao atualizar usuário');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Deseja excluir este usuário?')) return;
    try {
      await fetchApi(`/user/${id}`, { method: 'DELETE' });
      loadData();
    } catch (err: any) {
      alert(err.message || 'Erro ao excluir usuário');
    }
  };

  return (
    <div className="p-10 space-y-8 animate-fade-in-up">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Gestão de Usuários</h1>
          <p className="text-sm text-slate-500 dark:text-slate-400">Total de {meta?.total || 0} usuários cadastrados.</p>
        </div>
        <div className="flex items-center gap-3">
          <button className="flex items-center gap-2 px-4 py-2 text-sm font-semibold text-slate-600 dark:text-slate-300 bg-white dark:bg-slate-800 border border-[var(--border)] rounded-xl hover:bg-slate-50 transition-all">
            <Download className="w-4 h-4" /> Exportar
          </button>
        </div>
      </div>

      {/* Filtros e Busca (AGORA NO BACKEND) */}
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

      {/* Tabela com Loading */}
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
                <th className="px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">Usuário</th>
                <th className="px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">Cargo</th>
                <th className="px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">Plano</th>
                <th className="px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest text-right">Ações</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
              {users.map((user) => (
                <tr key={user.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors group">
                  <td className="px-8 py-5">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-indigo-100 dark:bg-indigo-900/30 flex items-center justify-center text-xs font-bold text-indigo-600 dark:text-indigo-400">
                        {user.name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()}
                      </div>
                      <div>
                        <p className="text-sm font-bold">{user.name}</p>
                        <p className="text-xs text-slate-400 dark:text-slate-500">{user.email}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-8 py-5">
                    <div className="flex items-center gap-1.5 text-xs font-semibold">
                      <Shield className={`w-3.5 h-3.5 ${user.role.name === 'ADMIN' ? 'text-amber-500' : 'text-blue-500'}`} />
                      <span className={user.role.name === 'ADMIN' ? 'text-amber-600' : 'text-slate-600 dark:text-slate-400'}>
                        {user.role.name}
                      </span>
                    </div>
                  </td>
                  <td className="px-8 py-5">
                    <span className={`px-3 py-1 text-[10px] font-bold rounded-full uppercase ${
                      user.plan?.name.toLowerCase().includes('premium') 
                      ? 'bg-amber-50 dark:bg-amber-900/20 text-amber-600 dark:text-amber-400' 
                      : 'bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400'
                    }`}>
                      {user.plan?.name || 'Sem Plano'}
                    </span>
                  </td>
                  <td className="px-8 py-5 text-right">
                    <div className="flex justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button onClick={() => handleOpenModal(user)} className="p-2 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 dark:hover:bg-indigo-950/50 rounded-lg transition-all">
                        <Edit2 className="w-4 h-4" />
                      </button>
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

        {/* CONTROLES DE PAGINAÇÃO (BACKEND) */}
        {meta && meta.totalPages > 1 && (
          <div className="p-6 border-t border-[var(--border)] flex items-center justify-between bg-slate-50/30 dark:bg-slate-900/30">
            <p className="text-xs text-slate-500 font-medium">
              Mostrando página <span className="text-slate-900 dark:text-white font-bold">{meta.page}</span> de {meta.totalPages}
            </p>
            <div className="flex gap-2">
              <button 
                disabled={meta.page <= 1 || isLoading}
                onClick={() => setCurrentPage(prev => prev - 1)}
                className="p-2 rounded-lg border border-[var(--border)] hover:bg-white dark:hover:bg-slate-800 disabled:opacity-30 disabled:cursor-not-allowed transition-all"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>
              <button 
                disabled={meta.page >= meta.totalPages || isLoading}
                onClick={() => setCurrentPage(prev => prev + 1)}
                className="p-2 rounded-lg border border-[var(--border)] hover:bg-white dark:hover:bg-slate-800 disabled:opacity-30 disabled:cursor-not-allowed transition-all"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>

      {/* MODAL DE EDIÇÃO (MANTIDO O DESIGN PREMIUM) */}
      {isModalOpen && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-6">
          <div className="absolute inset-0 bg-slate-950/60 backdrop-blur-md" onClick={() => !isSubmitting && setIsModalOpen(false)} />
          <div className="relative w-full max-w-xl bg-[var(--card)] rounded-[2.5rem] border border-[var(--border)] shadow-2xl overflow-hidden animate-in zoom-in-95 duration-300">
            {/* Form de edição mantido igual, mas usando loadData() ao salvar */}
            <div className="px-8 py-6 border-b border-[var(--border)] flex justify-between items-center bg-slate-50/50 dark:bg-slate-900/50">
              <div className="flex items-center gap-3">
                <div className="p-2.5 bg-indigo-600 rounded-xl text-white">
                  <UserIcon className="w-5 h-5" />
                </div>
                <h3 className="text-xl font-bold tracking-tight">Editar Usuário</h3>
              </div>
              <button onClick={() => setIsModalOpen(false)} className="p-2 text-slate-400 hover:text-slate-600 rounded-xl transition-all">
                <X className="w-6 h-6" />
              </button>
            </div>
            <form onSubmit={handleSubmit} className="p-8 space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Nome Completo</label>
                  <input required type="text" className="w-full px-4 py-3 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all font-medium" value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} />
                </div>
                <div className="space-y-2">
                  <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">E-mail</label>
                  <input required type="email" className="w-full px-4 py-3 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all font-medium" value={formData.email} onChange={e => setFormData({...formData, email: e.target.value})} />
                </div>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Cargo (Role)</label>
                  <select className="w-full px-4 py-3 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none appearance-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all font-medium" value={formData.role} onChange={e => setFormData({...formData, role: e.target.value as any})}>
                    <option value="USER">Motorista (Comum)</option>
                    <option value="ADMIN">Administrador</option>
                  </select>
                </div>
                <div className="space-y-2">
                  <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Plano Vinculado</label>
                  <select className="w-full px-4 py-3 bg-slate-50 dark:bg-slate-950 border border-[var(--border)] rounded-2xl outline-none appearance-none focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 transition-all font-medium" value={formData.planId} onChange={e => setFormData({...formData, planId: e.target.value})}>
                    <option value="">Sem Plano</option>
                    {plans.map(plan => (<option key={plan.id} value={plan.id}>{plan.name}</option>))}
                  </select>
                </div>
              </div>
              <div className="space-y-2">
                <label className="text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Status de Acesso</label>
                <div className="flex gap-4">
                  <button type="button" onClick={() => setFormData({...formData, isActive: true})} className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-2xl border transition-all ${formData.isActive ? 'bg-emerald-50 dark:bg-emerald-900/20 border-emerald-500 text-emerald-600' : 'bg-transparent border-[var(--border)] text-slate-400'}`}>
                    <Unlock className="w-4 h-4" /> Ativo
                  </button>
                  <button type="button" onClick={() => setFormData({...formData, isActive: false})} className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-2xl border transition-all ${!formData.isActive ? 'bg-red-50 dark:bg-red-900/20 border-red-500 text-red-600' : 'bg-transparent border-[var(--border)] text-slate-400'}`}>
                    <Lock className="w-4 h-4" /> Bloqueado
                  </button>
                </div>
              </div>
              <div className="flex gap-4 pt-4">
                <button type="button" onClick={() => setIsModalOpen(false)} className="flex-1 py-4 text-sm font-bold text-slate-500 hover:text-slate-700 transition-colors">Cancelar</button>
                <button disabled={isSubmitting} type="submit" className="flex-[2] py-4 text-sm font-bold text-white bg-indigo-600 rounded-2xl hover:bg-indigo-700 shadow-xl shadow-indigo-500/30 transition-all flex items-center justify-center gap-2">
                  {isSubmitting ? <Loader2 className="w-5 h-5 animate-spin" /> : 'Salvar Alterações'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
