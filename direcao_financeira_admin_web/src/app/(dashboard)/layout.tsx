"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  Bell,
  ChevronLeft,
  ChevronRight,
  Gem,
  LayoutDashboard,
  LogOut,
  Search,
  Settings,
  TrendingUp,
  Users,
} from "lucide-react";

import { ModeToggle } from "@/components/mode-toggle";
import { fetchApi, hasValidSession, signOut } from "@/lib/api/client";

interface AuthUser {
  name: string;
  role: string;
}

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(false);

  const toggleSidebar = useCallback(() => {
    setIsSidebarCollapsed((current) => !current);
  }, []);

  const handleLogout = useCallback(async () => {
    await signOut().catch(() => undefined);
    router.push("/login");
  }, [router]);

  useEffect(() => {
    const storedValue = localStorage.getItem("admin-sidebar-collapsed");
    if (storedValue) {
      setIsSidebarCollapsed(storedValue === "true");
    }
  }, []);

  useEffect(() => {
    let mounted = true;

    async function loadUser() {
      try {
        const hasSession = await hasValidSession();
        if (!hasSession) {
          router.push("/login");
          return;
        }

        const userData = (await fetchApi("/auth/me")) as AuthUser;
        if (userData.role === "USER") {
          await handleLogout();
          return;
        }

        if (mounted) {
          setUser(userData);
          localStorage.setItem("user", JSON.stringify(userData));
        }
      } catch (error) {
        console.error("Erro ao sincronizar perfil:", error);
        localStorage.removeItem("token");
        localStorage.removeItem("user");
        router.push("/login");
      } finally {
        if (mounted) {
          setLoading(false);
        }
      }
    }

    void loadUser();

    return () => {
      mounted = false;
    };
  }, [handleLogout, router]);

  useEffect(() => {
    localStorage.setItem("admin-sidebar-collapsed", String(isSidebarCollapsed));
  }, [isSidebarCollapsed]);

  if (loading || !user) {
    return (
      <div className="h-screen w-screen flex items-center justify-center bg-[var(--background)]">
        <div className="flex flex-col items-center gap-4">
          <div className="w-12 h-12 border-4 border-indigo-600 border-t-transparent rounded-full animate-spin" />
          <p className="text-sm font-medium text-slate-500">Verificando autenticacao...</p>
        </div>
      </div>
    );
  }

  const navItems = [
    { label: "Dashboard", icon: LayoutDashboard, href: "/" },
    { label: "Usuarios", icon: Users, href: "/users" },
    { label: "Planos e Assinaturas", icon: Gem, href: "/plans" },
  ];

  const reportItems = [
    { label: "Faturamento", icon: TrendingUp, href: "/billing" },
    { label: "Configuracoes", icon: Settings, href: "/settings" },
  ];

  const sidebarWidthClass = isSidebarCollapsed ? "w-24" : "w-72";
  const sidebarPaddingClass = isSidebarCollapsed ? "px-4" : "px-6";
  const headerPaddingClass = isSidebarCollapsed ? "px-6 md:px-8" : "px-10";
  const navAlignmentClass = isSidebarCollapsed ? "justify-center px-3" : "justify-start px-4";
  const brandAlignmentClass = isSidebarCollapsed ? "justify-center" : "";

  return (
    <div className="flex h-screen bg-[var(--background)] font-sans text-[var(--foreground)] transition-colors duration-300">
      <aside className={`${sidebarWidthClass} bg-[var(--sidebar)] border-r border-[var(--border)] flex flex-col transition-[width] duration-300 shrink-0`}>
        <div className={`p-6 border-b border-[var(--border)] flex items-center gap-3 transition-all duration-300 ${brandAlignmentClass}`}>
          <div className="w-10 h-10 bg-indigo-600 rounded-xl flex items-center justify-center text-white font-bold text-xl shadow-lg shadow-indigo-100 dark:shadow-none">
            D
          </div>
          {!isSidebarCollapsed && (
            <div>
              <h1 className="text-lg font-bold leading-none">Direcao</h1>
              <p className="text-xs text-slate-400 dark:text-slate-500 font-medium tracking-tight">Financeira Admin</p>
            </div>
          )}
        </div>

        <nav className={`flex-1 ${sidebarPaddingClass} py-6 space-y-2 overflow-y-auto transition-all duration-300`}>
          {!isSidebarCollapsed && (
            <p className="px-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest mb-4">Principal</p>
          )}
          {navItems.map((item) => {
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                title={item.label}
                className={`flex items-center gap-3 py-3 text-sm font-medium transition-all rounded-xl group ${navAlignmentClass} ${
                  isActive
                    ? "text-indigo-600 bg-indigo-50 dark:bg-indigo-950/30 font-semibold"
                    : "text-slate-500 dark:text-slate-400 hover:text-indigo-600 dark:hover:text-indigo-400 hover:bg-slate-50 dark:hover:bg-slate-800"
                }`}
              >
                <item.icon className={`h-5 w-5 shrink-0 ${isActive ? "opacity-100" : "opacity-70 group-hover:opacity-100 transition-opacity"}`} />
                {!isSidebarCollapsed && <span className="truncate">{item.label}</span>}
              </Link>
            );
          })}

          {!isSidebarCollapsed && (
            <p className="px-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest mt-8 mb-4">Relatorios</p>
          )}
          {reportItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              title={item.label}
              className={`flex items-center gap-3 py-3 text-sm font-medium text-slate-500 dark:text-slate-400 hover:text-indigo-600 dark:hover:text-indigo-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-all rounded-xl group ${navAlignmentClass}`}
            >
              <item.icon className="h-5 w-5 shrink-0 opacity-70 group-hover:opacity-100 transition-opacity" />
              {!isSidebarCollapsed && <span className="truncate">{item.label}</span>}
            </Link>
          ))}
        </nav>

        <div className={`${sidebarPaddingClass} pb-6 mt-auto transition-all duration-300`}>
          <div className="p-4 bg-slate-100 dark:bg-slate-800 rounded-2xl border border-[var(--border)] transition-colors duration-300">
            {!isSidebarCollapsed ? (
              <>
                <p className="text-xs font-medium text-slate-500 dark:text-slate-400 mb-1">Logado como</p>
                <p className="text-sm font-bold truncate text-slate-900 dark:text-white">{user.name}</p>
                <p className="text-[10px] text-slate-400 dark:text-slate-500 font-medium mb-3 uppercase tracking-wider">{user.role}</p>
              </>
            ) : (
              <div className="flex justify-center mb-3">
                <div
                  className="w-10 h-10 rounded-full bg-indigo-600 flex items-center justify-center font-bold text-white text-sm shadow-md"
                  title={user.name}
                >
                  {user.name
                    .split(" ")
                    .map((name: string) => name[0])
                    .join("")
                    .slice(0, 2)
                    .toUpperCase()}
                </div>
              </div>
            )}
            <button
              onClick={handleLogout}
              title="Sair da conta"
              className="w-full py-2 bg-white dark:bg-slate-700 hover:bg-red-50 dark:hover:bg-red-900/20 border border-[var(--border)] hover:border-red-200 dark:hover:border-red-900/30 transition-all rounded-lg text-xs font-bold text-slate-700 dark:text-slate-200 hover:text-red-600 flex items-center justify-center gap-2"
            >
              <LogOut className="w-3.5 h-3.5 shrink-0" />
              {!isSidebarCollapsed && "Sair da conta"}
            </button>
          </div>
        </div>
      </aside>

      <main className="flex-1 flex flex-col overflow-hidden">
        <header className={`h-20 bg-[var(--sidebar)] border-b border-[var(--border)] ${headerPaddingClass} flex items-center justify-between transition-all duration-300 shrink-0`}>
          <div className="flex items-center gap-4 min-w-0">
            <button
              type="button"
              onClick={toggleSidebar}
              className="h-10 w-10 shrink-0 rounded-xl bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400 hover:text-indigo-600 transition-colors flex items-center justify-center"
              aria-label={isSidebarCollapsed ? "Expandir menu lateral" : "Recolher menu lateral"}
              title={isSidebarCollapsed ? "Expandir menu lateral" : "Recolher menu lateral"}
            >
              {isSidebarCollapsed ? <ChevronRight className="h-5 w-5" /> : <ChevronLeft className="h-5 w-5" />}
            </button>

            <div className="min-w-0">
              <h2 className="text-xl font-bold truncate">
                {navItems.find((item) => item.href === pathname)?.label || "Painel Administrativo"}
              </h2>
              <p className="text-xs text-slate-400 dark:text-slate-500 font-medium truncate">Ola {user.name.split(" ")[0]}, bem-vindo de volta.</p>
            </div>
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
              <span className="absolute top-2 right-2.5 w-2 h-2 bg-red-500 rounded-full border-2 border-white dark:border-slate-900" />
            </button>

            <ModeToggle />

            <div className="h-8 w-[1px] bg-slate-200 dark:bg-slate-800 mx-2" />

            <div className="flex items-center gap-3 pl-2">
              <div className="w-10 h-10 rounded-full bg-indigo-600 flex items-center justify-center font-bold text-white text-sm shadow-md">
                {user.name
                  .split(" ")
                  .map((name: string) => name[0])
                  .join("")
                  .slice(0, 2)
                  .toUpperCase()}
              </div>
            </div>
          </div>
        </header>

        <div className="flex-1 overflow-auto bg-[var(--background)]">{children}</div>
      </main>
    </div>
  );
}
