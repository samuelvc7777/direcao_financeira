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
  Menu,
  PlaySquare,
  Search,
  Settings,
  TrendingUp,
  Users,
  X,
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
  const [isMobileSidebarOpen, setIsMobileSidebarOpen] = useState(false);

  const toggleSidebar = useCallback(() => {
    setIsSidebarCollapsed((current) => !current);
  }, []);

  const closeMobileSidebar = useCallback(() => {
    setIsMobileSidebarOpen(false);
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

  useEffect(() => {
    closeMobileSidebar();
  }, [closeMobileSidebar, pathname]);

  useEffect(() => {
    if (!isMobileSidebarOpen) {
      return;
    }

    const handleEscape = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        closeMobileSidebar();
      }
    };

    document.addEventListener("keydown", handleEscape);
    return () => document.removeEventListener("keydown", handleEscape);
  }, [closeMobileSidebar, isMobileSidebarOpen]);

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
    { label: "Videos", icon: PlaySquare, href: "/help-videos" },
    { label: "Faturamento", icon: TrendingUp, href: "/billing" },
    { label: "Configuracoes", icon: Settings, href: "/settings" },
  ];
  const allNavigationItems = [...navItems, ...reportItems];

  const sidebarWidthClass = isSidebarCollapsed ? "w-24" : "w-72";
  const sidebarPaddingClass = isSidebarCollapsed ? "px-4" : "px-6";
  const headerPaddingClass = isSidebarCollapsed ? "px-4 sm:px-6 md:px-8" : "px-4 sm:px-6 lg:px-10";
  const navAlignmentClass = isSidebarCollapsed ? "justify-center px-3" : "justify-start px-4";
  const brandAlignmentClass = isSidebarCollapsed ? "justify-center" : "";
  const showExpandedSidebarContent = !isSidebarCollapsed;

  return (
    <div className="flex h-screen bg-[var(--background)] font-sans text-[var(--foreground)] transition-colors duration-300">
      <div
        className={`fixed inset-0 z-50 lg:hidden ${
          isMobileSidebarOpen ? "pointer-events-auto" : "pointer-events-none"
        }`}
        aria-hidden={!isMobileSidebarOpen}
      >
          <button
            type="button"
            aria-label="Fechar menu"
            className={`absolute inset-0 bg-slate-950/45 backdrop-blur-sm transition-opacity duration-200 ${
              isMobileSidebarOpen ? "opacity-100" : "opacity-0"
            }`}
            onClick={closeMobileSidebar}
          />
          <aside
            className={`relative z-10 flex h-full w-[min(86vw,20rem)] flex-col border-r border-[var(--border)] bg-[var(--sidebar)] shadow-2xl transition-transform duration-200 ease-out ${
              isMobileSidebarOpen ? "translate-x-0" : "-translate-x-full"
            }`}
          >
            <div className="flex items-center justify-between gap-3 border-b border-[var(--border)] p-5">
              <div className="flex min-w-0 items-center gap-3">
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-indigo-600 text-xl font-bold text-white shadow-lg shadow-indigo-100 dark:shadow-none">
                  D
                </div>
                <div className="min-w-0">
                  <h1 className="text-lg font-bold leading-none">Direcao</h1>
                  <p className="truncate text-xs font-medium tracking-tight text-slate-400 dark:text-slate-500">Financeira Admin</p>
                </div>
              </div>
              <button
                type="button"
                onClick={closeMobileSidebar}
                className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-slate-100 text-slate-600 transition-colors hover:text-indigo-600 dark:bg-slate-800 dark:text-slate-400"
                aria-label="Fechar menu"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <nav className="flex-1 space-y-2 overflow-y-auto px-4 py-6">
              <p className="px-4 text-[10px] font-bold uppercase tracking-widest text-slate-400 dark:text-slate-500">Principal</p>
              {navItems.map((item) => {
                const isActive = pathname === item.href;
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    title={item.label}
                    onClick={closeMobileSidebar}
                    className={`flex items-center gap-3 rounded-xl px-4 py-3 text-sm font-medium transition-all ${
                      isActive
                        ? "bg-indigo-50 font-semibold text-indigo-600 dark:bg-indigo-950/30"
                        : "text-slate-500 hover:bg-slate-50 hover:text-indigo-600 dark:text-slate-400 dark:hover:bg-slate-800 dark:hover:text-indigo-400"
                    }`}
                  >
                    <item.icon className="h-5 w-5 shrink-0" />
                    <span className="truncate">{item.label}</span>
                  </Link>
                );
              })}

              <p className="px-4 pt-6 text-[10px] font-bold uppercase tracking-widest text-slate-400 dark:text-slate-500">Relatorios</p>
              {reportItems.map((item) => {
                const isActive = pathname === item.href;
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    title={item.label}
                    onClick={closeMobileSidebar}
                    className={`flex items-center gap-3 rounded-xl px-4 py-3 text-sm font-medium transition-all ${
                      isActive
                        ? "bg-indigo-50 font-semibold text-indigo-600 dark:bg-indigo-950/30"
                        : "text-slate-500 hover:bg-slate-50 hover:text-indigo-600 dark:text-slate-400 dark:hover:bg-slate-800 dark:hover:text-indigo-400"
                    }`}
                  >
                    <item.icon className="h-5 w-5 shrink-0" />
                    <span className="truncate">{item.label}</span>
                  </Link>
                );
              })}
            </nav>

            <div className="px-4 pb-6">
              <div className="rounded-2xl border border-[var(--border)] bg-slate-100 p-4 transition-colors duration-300 dark:bg-slate-800">
                <p className="mb-1 text-xs font-medium text-slate-500 dark:text-slate-400">Logado como</p>
                <p className="truncate text-sm font-bold text-slate-900 dark:text-white">{user.name}</p>
                <p className="mb-3 text-[10px] font-medium uppercase tracking-wider text-slate-400 dark:text-slate-500">{user.role}</p>
                <button
                  onClick={handleLogout}
                  title="Sair da conta"
                  className="flex w-full items-center justify-center gap-2 rounded-lg border border-[var(--border)] bg-white py-2 text-xs font-bold text-slate-700 transition-all hover:border-red-200 hover:bg-red-50 hover:text-red-600 dark:bg-slate-700 dark:text-slate-200 dark:hover:border-red-900/30 dark:hover:bg-red-900/20"
                >
                  <LogOut className="h-3.5 w-3.5 shrink-0" />
                  Sair da conta
                </button>
              </div>
            </div>
          </aside>
        </div>

      <aside className={`${sidebarWidthClass} hidden bg-[var(--sidebar)] border-r border-[var(--border)] lg:flex flex-col transition-[width] duration-300 shrink-0`}>
        <div className={`p-6 border-b border-[var(--border)] flex items-center gap-3 transition-all duration-300 ${brandAlignmentClass}`}>
          <div className="w-10 h-10 shrink-0 bg-indigo-600 rounded-xl flex items-center justify-center text-white font-bold text-xl shadow-lg shadow-indigo-100 dark:shadow-none">
            D
          </div>
          {showExpandedSidebarContent && (
            <div className="min-w-0">
              <h1 className="text-lg font-bold leading-none">Direcao</h1>
              <p className="text-xs text-slate-400 dark:text-slate-500 font-medium tracking-tight">Financeira Admin</p>
            </div>
          )}
        </div>

        <nav className={`flex-1 ${sidebarPaddingClass} py-6 space-y-2 overflow-y-auto transition-all duration-300`}>
          {showExpandedSidebarContent && (
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
                {showExpandedSidebarContent && <span className="truncate">{item.label}</span>}
              </Link>
            );
          })}

          {showExpandedSidebarContent && (
            <p className="px-4 text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest mt-8 mb-4">Relatorios</p>
          )}
          {reportItems.map((item) => {
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
                {showExpandedSidebarContent && <span className="truncate">{item.label}</span>}
              </Link>
            );
          })}
        </nav>

        <div className={`${sidebarPaddingClass} pb-6 mt-auto transition-all duration-300`}>
          <div className="p-4 bg-slate-100 dark:bg-slate-800 rounded-2xl border border-[var(--border)] transition-colors duration-300">
            {showExpandedSidebarContent ? (
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
              {showExpandedSidebarContent && <span>Sair da conta</span>}
            </button>
          </div>
        </div>
      </aside>

      <main className="flex-1 flex flex-col overflow-hidden">
        <header className={`min-h-20 bg-[var(--sidebar)] border-b border-[var(--border)] ${headerPaddingClass} flex items-center justify-between gap-3 transition-all duration-300 shrink-0`}>
          <div className="flex items-center gap-3 sm:gap-4 min-w-0">
            <button
              type="button"
              onClick={() => setIsMobileSidebarOpen(true)}
              className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-slate-100 text-slate-600 transition-colors hover:text-indigo-600 dark:bg-slate-800 dark:text-slate-400 lg:hidden"
              aria-label="Abrir menu lateral"
              title="Abrir menu lateral"
            >
              <Menu className="h-5 w-5" />
            </button>
            <button
              type="button"
              onClick={toggleSidebar}
              className="hidden h-10 w-10 shrink-0 rounded-xl bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400 hover:text-indigo-600 transition-colors lg:flex items-center justify-center"
              aria-label={isSidebarCollapsed ? "Expandir menu lateral" : "Recolher menu lateral"}
              title={isSidebarCollapsed ? "Expandir menu lateral" : "Recolher menu lateral"}
            >
              {isSidebarCollapsed ? <ChevronRight className="h-5 w-5" /> : <ChevronLeft className="h-5 w-5" />}
            </button>

            <div className="min-w-0">
              <h2 className="text-xl font-bold truncate">
                {allNavigationItems.find((item) => item.href === pathname)?.label || "Painel Administrativo"}
              </h2>
              <p className="text-xs text-slate-400 dark:text-slate-500 font-medium truncate">Ola {user.name.split(" ")[0]}, bem-vindo de volta.</p>
            </div>
          </div>

          <div className="flex items-center gap-2 sm:gap-4">
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

            <div className="hidden sm:block h-8 w-[1px] bg-slate-200 dark:bg-slate-800 mx-2" />

            <div className="hidden sm:flex items-center gap-3 pl-2">
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
