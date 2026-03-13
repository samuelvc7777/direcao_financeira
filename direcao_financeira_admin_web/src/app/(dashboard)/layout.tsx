"use client"

import { useEffect, useState } from "react"
import { ModeToggle } from "@/components/mode-toggle"
import { useRouter, usePathname } from "next/navigation"
import Link from "next/link"
import { 
  Users, 
  Gem, 
  LayoutDashboard, 
  TrendingUp, 
  Settings, 
  Search, 
  Bell, 
  LogOut
} from "lucide-react"

import { fetchApi } from "@/lib/api/client"

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const router = useRouter();
  const pathname = usePathname();
  const [user, setUser] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadUser() {
      const token = localStorage.getItem('token');
      if (!token) {
        router.push('/login');
        return;
      }

      try {
        // Tenta buscar do banco primeiro para ter o nome mais atualizado
        const userData = await fetchApi('/me');
        setUser(userData);
        localStorage.setItem('user', JSON.stringify(userData));
      } catch (err) {
        console.error("Erro ao sincronizar perfil:", err);
        // Fallback: se a API falhar (ex: falta de middleware), tenta usar o que está no localStorage
        const storedUser = localStorage.getItem('user');
        if (storedUser) {
          setUser(JSON.parse(storedUser));
        } else {
          router.push('/login');
        }
      } finally {
        setLoading(false);
      }
    }

    loadUser();
  }, [router]);

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    router.push('/login');
  };

  if (loading || !user) {
    return (
      <div className="h-screen w-screen flex items-center justify-center bg-[var(--background)]">
        <div className="flex flex-col items-center gap-4">
          <div className="w-12 h-12 border-4 border-indigo-600 border-t-transparent rounded-full animate-spin"></div>
          <p className="text-sm font-medium text-slate-500">Verificando autenticação...</p>
        </div>
      </div>
    );
  }

  const navItems = [
    { label: "Dashboard", icon: LayoutDashboard, href: "/" },
    { label: "Usuários", icon: Users, href: "/users" },
    { label: "Planos & Assinaturas", icon: Gem, href: "/plans" },
  ];

  const reportItems = [
    { label: "Faturamento", icon: TrendingUp, href: "/billing" },
    { label: "Configurações", icon: Settings, href: "/settings" },
  ];

  return (
    <div className="flex h-screen bg-[var(--background)] font-sans text-[var(--foreground)] transition-colors duration-300">
      {/* Sidebar */}
      <aside className="w-72 bg-[var(--sidebar)] border-r border-[var(--border)] flex flex-col transition-colors duration-300 shrink-0">
        <div className="p-8 border-b border-[var(--border)] flex items-center gap-3">
          <div className="w-10 h-10 bg-indigo-600 rounded-xl flex items-center justify-center text-white font-bold text-xl shadow-lg shadow-indigo-100 dark:shadow-none">
            D
          </div>
          <div>
            <h1 className="text-lg font-bold leading-none">Direção</h1>
            <p className="text-xs text-slate-400 dark:text-slate-500 font-medium tracking-tight">Financeira Admin</p>
          </div>
        </div>

        <nav className="flex-1 p-6 space-y-2 overflow-y-auto">
          <p className="px-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest mb-4">Principal</p>
          {navItems.map((item) => {
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`flex items-center gap-3 px-4 py-3 text-sm font-medium transition-all rounded-xl group ${
                  isActive 
                  ? "text-indigo-600 bg-indigo-50 dark:bg-indigo-950/30 font-semibold" 
                  : "text-slate-500 dark:text-slate-400 hover:text-indigo-600 dark:hover:text-indigo-400 hover:bg-slate-50 dark:hover:bg-slate-800"
                }`}
              >
                <item.icon className={`h-5 w-5 ${isActive ? "opacity-100" : "opacity-70 group-hover:opacity-100 transition-opacity"}`} />
                {item.label}
              </Link>
            )
          })}
          
          <p className="px-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest mt-8 mb-4">Relatórios</p>
          {reportItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="flex items-center gap-3 px-4 py-3 text-sm font-medium text-slate-500 dark:text-slate-400 hover:text-indigo-600 dark:hover:text-indigo-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-all rounded-xl group"
            >
              <item.icon className="h-5 w-5 opacity-70 group-hover:opacity-100 transition-opacity" />
              {item.label}
            </Link>
          ))}
        </nav>

        <div className="p-6 mt-auto">
          <div className="p-4 bg-slate-100 dark:bg-slate-800 rounded-2xl border border-[var(--border)] transition-colors duration-300">
            <p className="text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">Logado como</p>
            <p className="text-sm font-bold truncate text-slate-900 dark:text-white">{user.name}</p>
            <p className="text-[10px] text-slate-400 dark:text-slate-500 font-medium mb-3 uppercase tracking-wider">{user.role}</p>
            <button 
              onClick={handleLogout}
              className="w-full py-2 bg-white dark:bg-slate-700 hover:bg-red-50 dark:hover:bg-red-900/20 border border-[var(--border)] hover:border-red-200 dark:hover:border-red-900/30 transition-all rounded-lg text-xs font-bold text-slate-700 dark:text-slate-200 hover:text-red-600 flex items-center justify-center gap-2"
            >
              <LogOut className="w-3.5 h-3.5" />
              Sair da conta
            </button>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <header className="h-20 bg-[var(--sidebar)] border-b border-[var(--border)] px-10 flex items-center justify-between transition-colors duration-300 shrink-0">
          <div>
            <h2 className="text-xl font-bold">
              {navItems.find(i => i.href === pathname)?.label || "Painel Administrativo"}
            </h2>
            <p className="text-xs text-slate-400 dark:text-slate-500 font-medium">Olá {user.name.split(' ')[0]}, bem-vindo de volta.</p>
          </div>
          
          <div className="flex items-center gap-4">
            <div className="relative hidden md:block">
              <input 
                type="text" 
                placeholder="Pesquisar..." 
                className="pl-10 pr-4 py-2 bg-slate-100 dark:bg-slate-800 border-none rounded-xl text-sm w-64 focus:ring-2 focus:ring-indigo-500 transition-all outline-none dark:text-slate-100"
              />
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
            </div>
            
            <button className="p-2 rounded-xl bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400 hover:text-indigo-600 transition-colors relative">
              <Bell className="h-5 w-5" />
              <span className="absolute top-2 right-2.5 w-2 h-2 bg-red-500 rounded-full border-2 border-white dark:border-slate-900"></span>
            </button>

            <ModeToggle />

            <div className="h-8 w-[1px] bg-slate-200 dark:bg-slate-800 mx-2"></div>
            
            <div className="flex items-center gap-3 pl-2">
              <div className="w-10 h-10 rounded-full bg-indigo-600 flex items-center justify-center font-bold text-white text-sm shadow-md">
                {user.name.split(' ').map((n: string) => n[0]).join('').slice(0, 2).toUpperCase()}
              </div>
            </div>
          </div>
        </header>

        <div className="flex-1 overflow-auto bg-[var(--background)]">
          {children}
        </div>
      </main>
    </div>
  );
}
