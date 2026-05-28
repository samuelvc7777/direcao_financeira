"use client";

import { useEffect, useState } from "react";
import {
  Users,
  Gem,
  TrendingUp,
  ChevronRight,
  MoreHorizontal,
  Loader2,
} from "lucide-react";
import Link from "next/link";
import { fetchApi } from "@/lib/api/client";
import { mapUserToListItem, type User, type UserListItem } from "@/lib/subscriptions";
import { ResponsiveContainer } from "@/components/layout/responsive-container";

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

export default function Home() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [recentUsers, setRecentUsers] = useState<UserListItem[]>([]);

  useEffect(() => {
    async function loadDashboard() {
      try {
        const [dashData, usersResponse] = await Promise.all([
          fetchApi("/admin/dashboard").catch(() => ({
            metrics: { totalUsers: 0, activeUsers: 0, newUsers24h: 0, estimatedRevenue: 0 },
            plans: [],
            recentActivity: [],
          })),
          fetchApi("/user"),
        ]);

        setData(dashData);

        const usersList = Array.isArray(usersResponse) ? usersResponse : usersResponse.data || [];
        setRecentUsers(usersList.slice(0, 5).map((user: User) => mapUserToListItem(user)));
      } catch (error) {
        console.error("Erro ao carregar dashboard:", error);
      } finally {
        setIsLoading(false);
      }
    }

    loadDashboard();
  }, []);

  if (isLoading || !data) {
    return (
      <div className="flex h-[60vh] items-center justify-center">
        <Loader2 className="w-10 h-10 text-indigo-600 animate-spin" />
      </div>
    );
  }

  return (
    <ResponsiveContainer>
    <div className="space-y-8 animate-fade-in-up">
      <div className="responsive-grid-cards">
        <div className="p-6 bg-[var(--card)] rounded-3xl border border-[var(--border)] shadow-sm hover:shadow-md transition-all group">
          <div className="w-12 h-12 bg-indigo-50 dark:bg-indigo-900/20 text-indigo-600 dark:text-indigo-400 rounded-2xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
            <Users className="h-6 w-6" />
          </div>
          <p className="text-sm font-medium text-slate-400 dark:text-slate-500">Total de Usuários</p>
          <div className="flex items-end gap-2 mt-1">
            <h3 className="text-2xl font-bold">{data.metrics.totalUsers.toLocaleString()}</h3>
            <span className="text-xs font-bold text-emerald-500 pb-1">+{data.metrics.newUsers24h} hoje</span>
          </div>
        </div>

        <div className="p-6 bg-[var(--card)] rounded-3xl border border-[var(--border)] shadow-sm hover:shadow-md transition-all group">
          <div className="w-12 h-12 bg-amber-50 dark:bg-amber-900/20 text-amber-600 dark:text-amber-400 rounded-2xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
            <Gem className="h-6 w-6" />
          </div>
          <p className="text-sm font-medium text-slate-400 dark:text-slate-500">Usuários Ativos</p>
          <div className="flex items-end gap-2 mt-1">
            <h3 className="text-2xl font-bold">{data.metrics.activeUsers.toLocaleString()}</h3>
            <span className="text-xs font-bold text-emerald-500 pb-1">
              {data.metrics.totalUsers > 0
                ? ((data.metrics.activeUsers / data.metrics.totalUsers) * 100).toFixed(0)
                : 0}
              % da base
            </span>
          </div>
        </div>

        <div className="p-6 bg-[var(--card)] rounded-3xl border border-[var(--border)] shadow-sm hover:shadow-md transition-all group">
          <div className="w-12 h-12 bg-emerald-50 dark:bg-emerald-900/20 text-emerald-600 dark:text-emerald-400 rounded-2xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
            <TrendingUp className="h-6 w-6" />
          </div>
          <p className="text-sm font-medium text-slate-400 dark:text-slate-500">Receita Estimada</p>
          <div className="flex items-end gap-2 mt-1">
            <h3 className="text-2xl font-bold">
              {data.metrics.estimatedRevenue.toLocaleString("pt-BR", {
                style: "currency",
                currency: "BRL",
              })}
            </h3>
            <span className="text-xs font-bold text-slate-400 dark:text-slate-500 pb-1">MRR Atual</span>
          </div>
        </div>
      </div>

      <div className="bg-[var(--card)] rounded-3xl border border-[var(--border)] shadow-sm overflow-hidden transition-colors duration-300">
        <div className="p-4 sm:p-6 lg:p-8 border-b border-[var(--border)] flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <h3 className="text-lg font-bold">Últimos Usuários Cadastrados</h3>
          <Link
            href="/users"
            className="text-sm font-bold text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300 flex items-center gap-1 group"
          >
            Ver todos os usuários{" "}
            <ChevronRight className="h-4 w-4 group-hover:translate-x-1 transition-transform" />
          </Link>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="bg-slate-50/50 dark:bg-slate-800/30">
                <th className="px-4 sm:px-6 lg:px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">
                  Usuário
                </th>
                <th className="px-4 sm:px-6 lg:px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">
                  Plano
                </th>
                <th className="px-4 sm:px-6 lg:px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest">
                  Status
                </th>
                <th className="px-4 sm:px-6 lg:px-8 py-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest text-right">
                  Ações
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
              {recentUsers.map((user) => (
                <tr key={user.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors">
                  <td className="px-4 sm:px-6 lg:px-8 py-5">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-indigo-100 dark:bg-indigo-900/30 flex items-center justify-center text-xs font-bold text-indigo-600 dark:text-indigo-400">
                        {user.name
                          .split(" ")
                          .map((name) => name[0])
                          .join("")
                          .slice(0, 2)
                          .toUpperCase()}
                      </div>
                      <div>
                        <p className="text-sm font-bold">{user.name}</p>
                        <p className="text-xs text-slate-400 dark:text-slate-500">{user.email}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-4 sm:px-6 lg:px-8 py-5">
                    <span
                      className={`px-3 py-1 text-[10px] font-bold rounded-full uppercase ${
                        user.activePlan
                          ? "bg-indigo-50 dark:bg-indigo-900/20 text-indigo-600 dark:text-indigo-400"
                          : "bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400"
                      }`}
                    >
                      {user.activePlan?.name || "Sem Plano"}
                    </span>
                  </td>
                  <td className="px-4 sm:px-6 lg:px-8 py-5">
                    <div className="flex items-center gap-1.5">
                      <div className={`w-1.5 h-1.5 rounded-full ${user.isActive ? "bg-emerald-500" : "bg-red-500"}`}></div>
                      <span className="text-xs font-medium text-slate-600 dark:text-slate-400">
                        {user.isActive ? "Ativo" : "Inativo"}
                        {user.subscriptionStatus ? ` • ${user.subscriptionStatus}` : ""}
                      </span>
                    </div>
                  </td>
                  <td className="px-4 sm:px-6 lg:px-8 py-5 text-right">
                    <Link
                      href={`/users/${user.id}`}
                      className="p-2 inline-block hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg text-slate-400 dark:text-slate-600 transition-colors"
                    >
                      <MoreHorizontal className="h-5 w-5" />
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
    </ResponsiveContainer>
  );
}
