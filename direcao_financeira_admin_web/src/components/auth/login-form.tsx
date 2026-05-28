'use client';

import React, { useState } from 'react';
import { Mail, Lock, Eye, EyeOff, Loader2, ArrowRight, AlertCircle } from 'lucide-react';
import { ModeToggle } from '../mode-toggle';
import { useRouter } from 'next/navigation';
import { fetchApi, hasValidSession } from '@/lib/api/client';

export function LoginForm() {
  const router = useRouter();
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const getErrorMessage = (error: unknown, fallback: string) =>
    error instanceof Error ? error.message : fallback;

  // Redireciona se já estiver logado
  React.useEffect(() => {
    let mounted = true;

    async function redirectIfAuthenticated() {
      try {
        const hasSession = await hasValidSession();
        if (mounted && hasSession) {
          router.push('/');
        }
      } catch {
        localStorage.removeItem('token');
      }
    }

    void redirectIfAuthenticated();

    return () => {
      mounted = false;
    };
  }, [router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);
    
    try {
      const data = await fetchApi('/auth/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
      });

      // Validação de segurança: bloquear motoristas comuns de entrarem no Admin
      if (data.user.role === 'USER') {
        throw new Error('Acesso negado: Este portal é restrito a administradores e atendentes.');
      }

      // Salva o token e dados do usuário
      localStorage.setItem('token', data.access_token);
      localStorage.setItem('user', JSON.stringify(data.user));
      
      router.push('/');
    } catch (err: unknown) {
      setError(getErrorMessage(err, 'Erro ao realizar login. Tente novamente.'));
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="w-full max-w-md sm:max-w-lg p-5 sm:p-8 bg-[var(--card)] border border-[var(--border)] rounded-2xl shadow-xl space-y-8 animate-fade-in-up">
      <div className="flex justify-between items-center">
        <div className="flex items-center gap-2">
          <div className="w-10 h-10 bg-indigo-600 rounded-lg flex items-center justify-center text-white font-bold text-xl shadow-lg shadow-indigo-500/20">
            D
          </div>
          <div>
            <h1 className="text-xl sm:text-2xl font-bold tracking-tight">Direção Financeira</h1>
            <p className="text-sm text-gray-500 dark:text-gray-400">Portal Administrativo</p>
          </div>
        </div>
        <ModeToggle />
      </div>

      <div className="space-y-2">
        <h2 className="text-xl font-semibold">Bem-vindo de volta</h2>
        <p className="text-sm text-gray-500 dark:text-gray-400">
          Entre com suas credenciais para gerenciar o sistema
        </p>
      </div>

      {error && (
        <div className="flex items-center gap-3 p-4 bg-red-50 dark:bg-red-900/20 border border-red-100 dark:border-red-900/30 rounded-xl text-red-600 dark:text-red-400 text-sm animate-in fade-in slide-in-from-top-2">
          <AlertCircle className="w-5 h-5 shrink-0" />
          <p>{error}</p>
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="space-y-2">
          <label className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70" htmlFor="email">
            E-mail
          </label>
          <div className="relative group">
            <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 transition-colors group-focus-within:text-indigo-500" />
            <input
              id="email"
              type="email"
              placeholder="admin@direcaofinanceira.com"
              required
              className="w-full pl-10 pr-4 py-2.5 bg-transparent border border-[var(--border)] rounded-lg outline-none transition-all focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/20 placeholder:text-gray-400"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>
        </div>

        <div className="space-y-2">
          <div className="flex justify-between items-center">
            <label className="text-sm font-medium leading-none" htmlFor="password">
              Senha
            </label>
            <a href="#" className="text-xs text-indigo-600 hover:text-indigo-500 font-medium transition-colors">
              Esqueceu a senha?
            </a>
          </div>
          <div className="relative group">
            <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 transition-colors group-focus-within:text-indigo-500" />
            <input
              id="password"
              type={showPassword ? 'text' : 'password'}
              placeholder="••••••••"
              required
              className="w-full pl-10 pr-12 py-2.5 bg-transparent border border-[var(--border)] rounded-lg outline-none transition-all focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/20 placeholder:text-gray-400"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors"
            >
              {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
            </button>
          </div>
        </div>

        <div className="flex items-center space-x-2">
          <input
            type="checkbox"
            id="remember"
            className="w-4 h-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500 cursor-pointer"
          />
          <label htmlFor="remember" className="text-sm text-gray-600 dark:text-gray-400 cursor-pointer">
            Lembrar-me por 30 dias
          </label>
        </div>

        <button
          type="submit"
          disabled={isLoading}
          className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-3 rounded-lg shadow-lg shadow-indigo-500/25 transition-all active:scale-[0.98] disabled:opacity-70 disabled:pointer-events-none flex items-center justify-center gap-2 group"
        >
          {isLoading ? (
            <>
              <Loader2 className="w-5 h-5 animate-spin" />
              Entrando...
            </>
          ) : (
            <>
              Acessar Painel
              <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
            </>
          )}
        </button>
      </form>

      <div className="pt-4 text-center border-t border-[var(--border)]">
        <p className="text-sm text-gray-500 dark:text-gray-400">
          Problemas com o acesso? <a href="#" className="text-indigo-600 hover:underline font-medium">Contate o suporte</a>
        </p>
      </div>
    </div>
  );
}

