import { LoginForm } from "@/components/auth/login-form";

export default function LoginPage() {
  return (
    <main className="min-h-screen flex items-center justify-center relative overflow-hidden bg-[var(--background)]">
      {/* Elementos decorativos de fundo */}
      <div className="absolute top-0 left-0 w-full h-full overflow-hidden -z-10 pointer-events-none">
        <div className="absolute -top-[10%] -left-[10%] w-[40%] h-[40%] rounded-full bg-indigo-500/5 blur-[120px]" />
        <div className="absolute -bottom-[10%] -right-[10%] w-[40%] h-[40%] rounded-full bg-blue-500/5 blur-[120px]" />
      </div>

      <div className="container relative z-10 flex items-center justify-center px-4 py-6 sm:p-6">
        <LoginForm />
      </div>

      {/* Footer simples */}
      <div className="absolute bottom-6 left-0 w-full text-center text-xs text-gray-500">
        &copy; {new Date().getFullYear()} Direção Financeira. Todos os direitos reservados.
      </div>
    </main>
  );
}

