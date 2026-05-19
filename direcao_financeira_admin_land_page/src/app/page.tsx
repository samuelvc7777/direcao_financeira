"use client";

import { useEffect, useState } from "react";
import { useTheme } from "next-themes";
import { motion, AnimatePresence } from "framer-motion";
import { 
  TrendingUp, Target, ShieldCheck, Smartphone,
  CheckCircle2, ArrowRight, Star,
  Wallet, BarChart3, Lock, Users, Zap, Apple, 
  CalendarDays, CalendarRange, CalendarCheck, Menu, X,
  Sun, Moon
} from "lucide-react";

// Google Play Icon SVG Component
const GooglePlayIcon = ({ size = 24, className = "" }: { size?: number, className?: string }) => (
  <svg 
    width={size} 
    height={size} 
    viewBox="0 0 24 24" 
    fill="none" 
    className={className}
    xmlns="http://www.w3.org/2000/svg"
  >
    <path d="M3.60938 1.97656C3.38281 2.20312 3.25391 2.53516 3.25391 2.96484V21.0352C3.25391 2.46484 3.38281 2.79688 3.60938 3.02344L3.67969 3.09375L13.8438 12.1055L13.8438 11.8945L3.67969 2.90625L3.60938 1.97656Z" fill="#3B82F6"/>
    <path d="M17.2031 15.0898L13.8438 12.1055V11.8945L17.2031 8.91016L17.2734 8.95312L21.2539 11.2148C22.3867 11.8594 22.3867 12.9141 21.2539 13.5586L17.2734 15.0469L17.2031 15.0898Z" fill="#FBBF24"/>
    <path d="M17.2734 15.0469L13.8438 12.1055L3.60938 21.0352C3.96094 21.4062 4.54297 21.4531 5.21484 21.0703L17.2734 15.0469Z" fill="#EF4444"/>
    <path d="M17.2734 8.95312L5.21484 2.92969C4.54297 2.54688 3.96094 2.59375 3.60938 2.96484L13.8438 11.8945L17.2734 8.95312Z" fill="#10B981"/>
  </svg>
);

export default function Home() {
  const { theme, setTheme } = useTheme();
  const [isScrolled, setIsScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [billingCycle, setBillingCycle] = useState<"mensal" | "trimestral" | "anual">("anual");

  useEffect(() => {
    const handleScroll = () => setIsScrolled(window.scrollY > 20);
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const plans = [
    {
      id: "mensal",
      name: "Mensal",
      icon: <CalendarDays size={24} />,
      price: "29,90",
      period: "/mês",
      description: "Ideal para começar sua organização hoje.",
      features: ["Controle de gastos ilimitado", "Categorização por IA", "Suporte via E-mail"],
      popular: false
    },
    {
      id: "anual",
      name: "Anual",
      icon: <CalendarCheck size={24} />,
      price: "19,90",
      period: "/mês",
      total: "R$ 238,80/ano",
      description: "A escolha inteligente para resultados duradouros.",
      features: ["Tudo do mensal", "Relatórios Avançados", "Suporte VIP", "Economize 33%"],
      popular: true
    },
    {
      id: "trimestral",
      name: "Trimestral",
      icon: <CalendarRange size={24} />,
      price: "24,90",
      period: "/mês",
      total: "R$ 74,70/tri",
      description: "Equilíbrio perfeito entre flexibilidade e economia.",
      features: ["Tudo do mensal", "Metas Inteligentes", "Exportação de Dados"],
      popular: false
    }
  ];

  const testimonials = [
    {
      name: "Nano Banana",
      role: "Influenciador de Finanças",
      image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&h=200&auto=format&fit=crop",
      content: "O Direção Financeira é o único app que realmente entende o brasileiro. Em 2 meses, organizei toda a minha vida e hoje sobra dinheiro pra investir pesado.",
      rating: 5
    },
    {
      name: "Ricardo Mendes",
      role: "Empreendedor Digital",
      image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&h=200&auto=format&fit=crop",
      content: "A conciliação bancária automática é surreal. Eu perdia horas com planilhas, agora o Direção faz tudo em segundos com uma precisão absurda.",
      rating: 5
    },
    {
      name: "Camila Santos",
      role: "Investidora",
      image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&h=200&auto=format&fit=crop",
      content: "As metas inteligentes me ajudaram a comprar meu primeiro carro à vista. O app te dá o 'norte' que falta no dia a dia. Recomendo pra todo mundo.",
      rating: 5
    }
  ];

  const heroAvatars = [
    "https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=100&h=100&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=100&h=100&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1580489944761-15a19d654956?q=80&w=100&h=100&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=100&h=100&auto=format&fit=crop"
  ];

  return (
    <div className="min-h-screen bg-white dark:bg-[#0A0C10] font-sans text-slate-900 dark:text-slate-200 selection:bg-blue-500/30 transition-colors duration-500">
      {/* Premium Header Ultra-Modern */}
      <header className={`fixed w-full z-[100] transition-all duration-500 ease-in-out ${
        isScrolled 
          ? "top-4 px-6 md:px-12" 
          : "top-0 px-0"
      }`}>
        <div className={`container mx-auto transition-all duration-500 ${
          isScrolled 
            ? "bg-white/70 dark:bg-black/40 backdrop-blur-2xl border border-slate-200 dark:border-white/10 rounded-3xl py-3 px-8 shadow-[0_20px_50px_rgba(0,0,0,0.1)] dark:shadow-[0_20px_50px_rgba(0,0,0,0.5)]" 
            : "bg-transparent py-8 px-6"
        }`}>
          <div className="flex items-center justify-between">
            <motion.div 
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              className="flex items-center gap-3 cursor-pointer group"
            >
              <div className="relative w-11 h-11">
                <div className="absolute inset-0 bg-blue-600 rounded-2xl rotate-6 group-hover:rotate-12 transition-transform duration-300 opacity-20 blur-sm"></div>
                <div className="relative w-full h-full bg-gradient-to-br from-blue-500 to-indigo-600 rounded-2xl flex items-center justify-center shadow-lg shadow-blue-500/20 z-10">
                  <TrendingUp className="text-white" size={24} />
                </div>
              </div>
              <div className="flex flex-col">
                <span className="text-xl font-black tracking-tighter text-slate-900 dark:text-white leading-none">
                  DIREÇÃO
                </span>
                <span className="text-xs font-bold text-blue-500 tracking-[0.2em] leading-none mt-1">
                  FINANCEIRA
                </span>
              </div>
            </motion.div>
            
            {/* Desktop Nav */}
            <nav className="hidden lg:flex items-center gap-10">
              {["Funcionalidades", "Depoimentos", "Preços"].map((item) => (
                <a 
                  key={item} 
                  href={`#${item.toLowerCase()}`} 
                  className="relative text-sm font-bold text-slate-500 dark:text-slate-400 hover:text-blue-600 dark:hover:text-white transition-colors py-2 group"
                >
                  {item}
                  <span className="absolute bottom-0 left-0 w-0 h-0.5 bg-blue-500 transition-all duration-300 group-hover:w-full"></span>
                </a>
              ))}
            </nav>

            <div className="flex items-center gap-4">
              {/* Theme Toggle */}
              <button 
                onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
                className="w-11 h-11 flex items-center justify-center rounded-2xl bg-slate-100 dark:bg-white/5 border border-slate-200 dark:border-white/10 text-slate-600 dark:text-white hover:bg-slate-200 dark:hover:bg-white/10 transition-all"
              >
                {theme === "dark" ? <Sun size={20} /> : <Moon size={20} />}
              </button>

              <motion.a 
                href="#baixar"
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="hidden md:flex bg-blue-600 hover:bg-blue-500 text-white px-7 py-3 rounded-2xl text-sm font-black shadow-xl shadow-blue-600/30 transition-all items-center gap-2 group"
              >
                BAIXAR APP <ArrowRight size={16} className="group-hover:translate-x-1 transition-transform" />
              </motion.a>
              
              {/* Mobile Toggle */}
              <button 
                onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                className="lg:hidden w-11 h-11 flex items-center justify-center rounded-2xl bg-slate-100 dark:bg-white/5 border border-slate-200 dark:border-white/10 text-slate-600 dark:text-white"
              >
                {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
              </button>
            </div>
          </div>
        </div>

        {/* Mobile Menu Overlay */}
        <AnimatePresence>
          {mobileMenuOpen && (
            <motion.div
              initial={{ opacity: 0, y: -20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="absolute top-24 left-6 right-6 p-8 bg-white/95 dark:bg-black/95 backdrop-blur-3xl rounded-[2.5rem] border border-slate-200 dark:border-white/10 lg:hidden shadow-2xl z-50"
            >
              <nav className="flex flex-col gap-6 items-center">
                {["Funcionalidades", "Depoimentos", "Preços"].map((item) => (
                  <a 
                    key={item} 
                    href={`#${item.toLowerCase()}`} 
                    onClick={() => setMobileMenuOpen(false)}
                    className="text-xl font-bold text-slate-900 dark:text-white"
                  >
                    {item}
                  </a>
                ))}
                <a 
                  href="#baixar"
                  className="w-full bg-blue-600 text-white py-5 rounded-3xl text-center font-black text-lg"
                >
                  BAIXAR AGORA
                </a>
              </nav>
            </motion.div>
          )}
        </AnimatePresence>
      </header>

      {/* Hero Master Section */}
      <section className="relative pt-40 pb-20 lg:pt-60 lg:pb-40 px-6 overflow-hidden">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-blue-600/20 rounded-full blur-[120px] animate-pulse"></div>
        <div className="absolute bottom-[10%] right-[-5%] w-[30%] h-[30%] bg-indigo-600/20 rounded-full blur-[100px]"></div>
        
        <div className="container mx-auto relative z-10 text-center lg:text-left flex flex-col lg:flex-row items-center gap-16">
          <div className="lg:w-1/2">
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8 }}
            >
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-500/10 border border-blue-500/20 text-blue-600 dark:text-blue-400 text-xs font-bold uppercase tracking-widest mb-6">
                <Zap size={14} fill="currentColor" /> Inteligência Financeira de Elite
              </div>
              <h1 className="text-6xl md:text-8xl font-black tracking-tighter text-slate-900 dark:text-white leading-[0.9] mb-8">
                Tome as rédeas <br />
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 via-indigo-500 to-cyan-500 dark:from-blue-400 dark:via-indigo-400 dark:to-cyan-400">
                  da sua liberdade.
                </span>
              </h1>
              <p className="text-lg md:text-xl text-slate-600 dark:text-slate-400 mb-10 max-w-xl font-medium leading-relaxed">
                O Direção Financeira automatiza sua rotina, elimina desperdícios e projeta sua riqueza. O app que se paga sozinho logo na primeira semana.
              </p>
              
              <div id="baixar" className="flex flex-col sm:flex-row gap-4 items-center">
                <motion.button 
                  whileHover={{ scale: 1.05, boxShadow: "0 0 30px rgba(0, 0, 0, 0.1)" }}
                  className="w-full sm:w-auto bg-slate-900 dark:bg-white text-white dark:text-black px-8 py-4 rounded-3xl font-black flex items-center justify-center gap-3 group transition-all"
                >
                  <Apple size={28} className="fill-current" />
                  <div className="text-left">
                    <p className="text-[10px] uppercase leading-none opacity-60 font-bold">Baixar na</p>
                    <p className="text-xl leading-none font-black">App Store</p>
                  </div>
                </motion.button>
                <motion.button 
                  whileHover={{ scale: 1.05, boxShadow: "0 0 30px rgba(16, 185, 129, 0.2)" }}
                  className="w-full sm:w-auto bg-white dark:bg-slate-900 border border-slate-200 dark:border-white/10 text-slate-900 dark:text-white px-8 py-4 rounded-3xl font-black flex items-center justify-center gap-3 group transition-all shadow-sm"
                >
                  <GooglePlayIcon size={28} />
                  <div className="text-left">
                    <p className="text-[10px] uppercase leading-none opacity-60 font-bold">Disponível no</p>
                    <p className="text-xl leading-none font-black">Google Play</p>
                  </div>
                </motion.button>
              </div>

              <div className="mt-12 flex items-center gap-6 pt-12 border-t border-slate-200 dark:border-white/5">
                <div className="flex -space-x-4">
                  {heroAvatars.map((url, i) => (
                    <div key={i} className="w-12 h-12 rounded-full border-4 border-white dark:border-[#0A0C10] overflow-hidden bg-slate-200 dark:bg-slate-800">
                      <img src={url} alt="user" className="w-full h-full object-cover" />
                    </div>
                  ))}
                </div>
                <div className="text-sm">
                  <div className="flex text-amber-500 dark:text-amber-400 mb-1">
                    {[1,2,3,4,5].map(i => <Star key={i} size={16} fill="currentColor" />)}
                  </div>
                  <p className="text-slate-600 dark:text-slate-400 font-bold tracking-tight">Classificação 4.9/5 por +15.000 usuários</p>
                </div>
              </div>
            </motion.div>
          </div>

          {/* Interactive Mockup Component */}
          <motion.div 
            initial={{ opacity: 0, scale: 0.8, rotateY: -10 }}
            animate={{ opacity: 1, scale: 1, rotateY: 0 }}
            transition={{ duration: 1, delay: 0.2 }}
            className="lg:w-1/2 relative"
          >
            <div className="relative w-full max-w-[450px] mx-auto group">
              <div className="absolute inset-0 bg-blue-600/20 dark:bg-blue-600/30 blur-[120px] rounded-full group-hover:bg-blue-600/30 dark:group-hover:bg-blue-600/40 transition-all duration-700"></div>
              <div className="relative bg-slate-100 dark:bg-slate-900 border border-slate-200 dark:border-white/10 rounded-[3rem] p-4 shadow-[0_50px_100px_rgba(0,0,0,0.1)] dark:shadow-[0_50px_100px_rgba(0,0,0,0.5)]">
                <div className="bg-white dark:bg-[#0A0C10] rounded-[2.5rem] overflow-hidden aspect-[9/19] relative shadow-inner">
                   <div className="p-8">
                     <div className="flex justify-between mb-10">
                       <div className="w-10 h-10 rounded-2xl bg-slate-100 dark:bg-white/5 border border-slate-200 dark:border-white/5 flex items-center justify-center">
                         <div className="w-5 h-1 bg-blue-600 dark:bg-blue-500 rounded-full"></div>
                       </div>
                       <div className="w-10 h-10 rounded-full overflow-hidden border-2 border-blue-600/50 dark:border-blue-500/50">
                         <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150&h=150&auto=format&fit=crop" alt="avatar" className="w-full h-full object-cover" />
                       </div>
                     </div>
                     <p className="text-slate-400 dark:text-slate-500 text-xs mb-2 uppercase tracking-[0.2em] font-black">Previsão Mensal</p>
                     <h2 className="text-4xl font-black text-slate-900 dark:text-white mb-10 tracking-tighter">R$ 1.254,80</h2>
                     <div className="space-y-6">
                       {[
                         { label: "Investimentos", val: "65%", color: "bg-blue-600 dark:bg-blue-500" },
                         { label: "Reserva", val: "40%", color: "bg-emerald-600 dark:bg-emerald-500" },
                         { label: "Custos Fixos", val: "20%", color: "bg-rose-600 dark:bg-rose-500" },
                       ].map((item, i) => (
                         <div key={i} className="bg-slate-50 dark:bg-white/5 p-5 rounded-3xl border border-slate-200 dark:border-white/5">
                           <div className="flex justify-between mb-3">
                             <span className="text-sm font-black uppercase text-slate-500 dark:text-slate-300 tracking-tight">{item.label}</span>
                             <span className="text-sm text-blue-600 dark:text-blue-400 font-mono font-bold">{item.val}</span>
                           </div>
                           <div className="w-full h-2 bg-slate-200 dark:bg-white/5 rounded-full overflow-hidden">
                             <motion.div 
                              initial={{ width: 0 }}
                              animate={{ width: item.val }}
                              transition={{ duration: 1.5, delay: 1, ease: "circOut" }}
                              className={`h-full ${item.color} shadow-[0_0_10px_rgba(59,130,246,0.3)] dark:shadow-[0_0_10px_rgba(59,130,246,0.5)]`}
                             />
                           </div>
                         </div>
                       ))}
                     </div>
                   </div>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Testimonials - Real Photos Focus */}
      <section id="depoimentos" className="py-24 lg:py-40 relative">
        <div className="container mx-auto px-6">
          <div className="text-center max-w-3xl mx-auto mb-20">
            <h2 className="text-4xl md:text-6xl font-black text-slate-900 dark:text-white mb-6 tracking-tighter">Quem usa, não volta atrás</h2>
            <p className="text-slate-600 dark:text-slate-400 text-lg font-medium">Histórias reais de pessoas que transformaram o caos em patrimônio.</p>
          </div>
          
          <div className="grid lg:grid-cols-3 gap-8 max-w-7xl mx-auto">
            {testimonials.map((t, i) => (
              <motion.div 
                key={i}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.1 }}
                className="relative p-10 rounded-[3rem] bg-slate-50 dark:bg-gradient-to-b dark:from-white/5 dark:to-transparent border border-slate-200 dark:border-white/10 hover:border-blue-500/30 transition-all group overflow-hidden shadow-sm dark:shadow-none"
              >
                <div className="absolute top-0 right-0 p-8 opacity-5">
                  <Users size={80} />
                </div>
                <div className="flex items-center gap-4 mb-8">
                  <div className="w-16 h-16 rounded-2xl overflow-hidden border-2 border-blue-500/50 p-1 bg-white dark:bg-slate-900 shadow-xl shadow-blue-500/10">
                    <img src={t.image} alt={t.name} className="w-full h-full object-cover rounded-xl" />
                  </div>
                  <div>
                    <h4 className="text-xl font-black text-slate-900 dark:text-white leading-none">{t.name}</h4>
                    <p className="text-blue-600 dark:text-blue-500 text-sm font-bold mt-1 tracking-tight">{t.role}</p>
                  </div>
                </div>
                <div className="flex text-amber-500 dark:text-amber-400 mb-6 gap-1">
                  {[...Array(t.rating)].map((_, i) => <Star key={i} size={18} fill="currentColor" />)}
                </div>
                <p className="text-slate-700 dark:text-slate-300 text-lg leading-relaxed font-medium italic">
                  &quot;{t.content}&quot;
                </p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section id="funcionalidades" className="py-24 lg:py-40 bg-slate-50/[0.5] dark:bg-white/[0.02] relative border-y border-slate-200 dark:border-white/5">
        <div className="container mx-auto px-6">
          <div className="text-center max-w-3xl mx-auto mb-20">
            <h2 className="text-4xl md:text-5xl font-black text-slate-900 dark:text-white mb-6 tracking-tight">Recursos que transformam</h2>
            <p className="text-slate-600 dark:text-slate-400 text-lg font-medium">Tecnologia de ponta para quem leva o patrimônio a sério.</p>
          </div>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[
              { icon: <Wallet />, title: "Sincronização Bancária", desc: "Conexão segura com os maiores bancos do Brasil para leitura automática de extratos." },
              { icon: <Target />, title: "Metas de Curto/Longo Prazo", desc: "Planeje sua aposentadoria ou aquela viagem especial com acompanhamento visual." },
              { icon: <BarChart3 />, title: "IA de Economia", desc: "Nossa inteligência identifica padrões de gastos inúteis e sugere cortes inteligentes." },
              { icon: <ShieldCheck />, title: "Segurança de Elite", desc: "Dados protegidos por criptografia de ponta a ponta e autenticação biométrica." },
              { icon: <Smartphone />, title: "Widget Inteligente", desc: "Acompanhe seu saldo e gastos sem precisar abrir o aplicativo." },
              { icon: <Lock />, title: "Modo Furtivo", desc: "Esconda valores sensíveis com um toque ao usar o app em locais públicos." },
            ].map((f, i) => (
              <motion.div 
                key={i}
                whileHover={{ y: -5, backgroundColor: "rgba(255,255,255,0.05)" }}
                className="p-10 rounded-[2.5rem] bg-white dark:bg-transparent border border-slate-200 dark:border-white/10 transition-all group shadow-sm dark:shadow-none"
              >
                <div className="w-16 h-16 bg-blue-600/10 text-blue-600 dark:text-blue-500 rounded-3xl flex items-center justify-center mb-8 group-hover:bg-blue-600 group-hover:text-white group-hover:shadow-lg group-hover:shadow-blue-600/20 transition-all duration-300">
                  {f.icon}
                </div>
                <h3 className="text-2xl font-black text-slate-900 dark:text-white mb-4 tracking-tighter">{f.title}</h3>
                <p className="text-slate-600 dark:text-slate-400 leading-relaxed font-medium">{f.desc}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Pricing Section */}
      <section id="preços" className="py-24 lg:py-40">
        <div className="container mx-auto px-6">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <h2 className="text-4xl md:text-6xl font-black text-slate-900 dark:text-white mb-6 tracking-tighter">Escolha seu plano</h2>
            <p className="text-slate-600 dark:text-slate-400 text-xl mb-12 font-medium">Assine dentro do app e comece a poupar agora mesmo.</p>
            
            {/* Billing Switcher */}
            <div className="flex bg-slate-100 dark:bg-slate-900 p-2 rounded-3xl border border-slate-200 dark:border-white/10 w-fit mx-auto shadow-sm dark:shadow-2xl">
               {(["mensal", "trimestral", "anual"] as const).map((type) => (
                 <button
                  key={type}
                  onClick={() => setBillingCycle(type)}
                  className={`px-8 py-3 rounded-2xl text-sm font-black transition-all duration-300 ${
                    billingCycle === type ? "bg-blue-600 text-white shadow-[0_10px_20px_rgba(37,99,235,0.3)]" : "text-slate-500 hover:text-blue-600 dark:hover:text-white"
                  }`}
                 >
                   {type.toUpperCase()}
                 </button>
               ))}
            </div>
          </div>

          <div className="grid lg:grid-cols-3 gap-8 max-w-6xl mx-auto">
            {plans.map((plan) => (
              <motion.div
                key={plan.id}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                className={`relative p-10 rounded-[3.5rem] border transition-all duration-700 flex flex-col group ${
                  plan.id === billingCycle 
                    ? "bg-white dark:bg-slate-900 border-blue-600 dark:border-blue-500 shadow-[0_30px_60px_rgba(37,99,235,0.1)] dark:shadow-[0_30px_60px_rgba(37,99,235,0.15)] scale-105 z-10" 
                    : "bg-transparent border-slate-200 dark:border-white/5 opacity-40 grayscale scale-95 hover:opacity-100 hover:grayscale-0 hover:scale-100"
                }`}
              >
                {plan.popular && (
                  <div className="absolute top-0 right-10 transform -translate-y-1/2 bg-gradient-to-r from-blue-600 to-indigo-600 text-white px-6 py-2 rounded-full text-[10px] font-black uppercase tracking-widest shadow-xl">
                    🔥 O MAIS VANTAJOSO
                  </div>
                )}
                
                <div className={`w-14 h-14 rounded-2xl flex items-center justify-center mb-8 shadow-lg ${
                  plan.id === billingCycle ? "bg-blue-600 text-white shadow-blue-500/20" : "bg-slate-100 dark:bg-white/5 text-slate-400"
                }`}>
                  {plan.icon}
                </div>
                
                <h3 className="text-3xl font-black text-slate-900 dark:text-white mb-2 tracking-tighter">{plan.name}</h3>
                <p className="text-slate-500 text-sm mb-10 font-bold leading-relaxed">{plan.description}</p>
                
                <div className="mb-10">
                  <div className="flex items-baseline gap-2">
                    <span className="text-slate-400 dark:text-slate-500 text-2xl font-black">R$</span>
                    <span className="text-7xl font-black text-slate-900 dark:text-white tracking-tighter">{plan.price}</span>
                    <span className="text-slate-400 dark:text-slate-500 font-bold text-lg">{plan.period}</span>
                  </div>
                  {plan.total && <p className="text-blue-600 dark:text-blue-500 font-black text-sm mt-3 uppercase tracking-tighter">{plan.total}</p>}
                </div>

                <ul className="space-y-5 mb-12 flex-grow">
                  {plan.features.map((feature, i) => (
                    <li key={i} className="flex items-center gap-4 text-sm text-slate-600 dark:text-slate-300 font-bold">
                      <div className={`w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 ${plan.id === billingCycle ? "bg-blue-600/10 text-blue-600" : "bg-slate-100 dark:bg-white/5 text-slate-400 dark:text-slate-600"}`}>
                        <CheckCircle2 size={14} />
                      </div>
                      {feature}
                    </li>
                  ))}
                </ul>

                <button className={`w-full py-6 rounded-[2rem] text-xl font-black transition-all duration-300 ${
                  plan.id === billingCycle 
                  ? "bg-blue-600 hover:bg-blue-500 text-white shadow-[0_15px_30px_rgba(37,99,235,0.3)]" 
                  : "bg-slate-100 dark:bg-white/5 hover:bg-slate-200 dark:hover:bg-white/10 text-slate-900 dark:text-white border border-slate-200 dark:border-white/10"
                }`}>
                  ASSINAR AGORA
                </button>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Final Call to Action */}
      <section className="py-24 bg-gradient-to-t from-blue-600/10 dark:from-blue-600/20 to-transparent relative overflow-hidden border-t border-slate-200 dark:border-white/5">
        <div className="container mx-auto px-6 text-center">
          <motion.div
            initial={{ scale: 0.9, opacity: 0 }}
            whileInView={{ scale: 1, opacity: 1 }}
            viewport={{ once: true }}
            className="max-w-5xl mx-auto"
          >
            <h2 className="text-6xl md:text-8xl font-black text-slate-900 dark:text-white mb-10 tracking-tighter leading-none">
              DÊ UM RUMO AO <br /> SEU DINHEIRO.
            </h2>
            <div className="flex flex-wrap justify-center gap-8 mt-16">
              <motion.button whileHover={{ scale: 1.05, y: -5 }} className="bg-slate-900 dark:bg-white text-white dark:text-black px-12 py-6 rounded-[2.5rem] font-black text-2xl shadow-2xl flex items-center gap-4 group">
                <Apple size={32} /> APP STORE
              </motion.button>
              <motion.button whileHover={{ scale: 1.05, y: -5 }} className="bg-white dark:bg-slate-900 text-slate-900 dark:text-white border border-slate-200 dark:border-white/10 px-12 py-6 rounded-[2.5rem] font-black text-2xl shadow-2xl flex items-center gap-4 group">
                <GooglePlayIcon size={32} /> GOOGLE PLAY
              </motion.button>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Footer Final */}
      <footer className="bg-white dark:bg-black border-t border-slate-200 dark:border-white/5 py-20">
        <div className="container mx-auto px-6 text-center">
          <div className="flex flex-col items-center gap-8 mb-16">
            <div className="flex items-center gap-3 text-slate-900 dark:text-white font-black text-3xl">
              <div className="w-10 h-10 bg-blue-600 rounded-xl flex items-center justify-center">
                <TrendingUp size={24} className="text-white" />
              </div>
              DIREÇÃO
            </div>
            <p className="text-slate-500 text-lg max-w-2xl mx-auto font-medium leading-relaxed">
              Direção Financeira Labs. CNPJ: 00.000.000/0001-00 <br />
              A inteligência que seu patrimônio merece.
            </p>
          </div>
          <div className="flex flex-wrap justify-center gap-10 text-xs text-slate-400 dark:text-slate-600 font-black uppercase tracking-[0.3em]">
            <a href="/privacy" className="hover:text-blue-600 transition-colors">Privacidade</a>
            <a href="#" className="hover:text-slate-900 dark:hover:text-white transition-colors">Termos</a>
            <a href="#" className="hover:text-slate-900 dark:hover:text-white transition-colors">Ouvidoria</a>
            <a href="#" className="hover:text-slate-900 dark:hover:text-white transition-colors">Segurança</a>
          </div>
          <p className="mt-16 text-slate-300 dark:text-slate-800 text-[10px] font-black tracking-widest">DIREÇÃO FINANCEIRA &copy; {new Date().getFullYear()} - TODOS OS DIREITOS RESERVADOS</p>
        </div>
      </footer>
    </div>
  );
}
