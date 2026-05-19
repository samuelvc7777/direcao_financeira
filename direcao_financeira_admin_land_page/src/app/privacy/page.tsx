import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Política de Privacidade | Direção Financeira",
  description:
    "Política de Privacidade do app Direção Financeira, com informações sobre dados coletados, uso, compartilhamento e contato.",
};

const supportEmail = "samuelvictorcarvalho717@gmail.com";
const companyName = "Direção Financeira";

const sections = [
  {
    title: "1. Quem somos",
    paragraphs: [
      `Esta Política de Privacidade descreve como o aplicativo Direção Financeira trata informações de usuários e dispositivos. O controlador dos dados é ${companyName}.`,
      `Se você tiver dúvidas sobre esta política ou sobre o tratamento de dados, entre em contato pelo e-mail ${supportEmail}.`,
    ],
  },
  {
    title: "2. Dados que o app pode acessar",
    paragraphs: [
      "O aplicativo pode acessar, coletar ou processar informações necessárias para o funcionamento das funcionalidades disponíveis no app, incluindo dados de conta, conteúdo inserido pelo usuário, dados de uso, registros de operação e informações técnicas do dispositivo.",
      "Dependendo das permissões concedidas, o app também pode solicitar acesso à localização, câmera, microfone, notificações e rede para oferecer recursos específicos e manter o funcionamento normal do serviço.",
    ],
  },
  {
    title: "3. Como usamos as informações",
    paragraphs: [
      "Usamos os dados para autenticar usuários, operar as funcionalidades do app, salvar preferências, exibir conteúdo, processar solicitações, melhorar a experiência, prestar suporte e cumprir obrigações legais ou regulatórias.",
      "Também podemos usar informações agregadas e não identificáveis para entender falhas, desempenho e estabilidade do aplicativo.",
    ],
  },
  {
    title: "4. Compartilhamento de dados",
    paragraphs: [
      "Não vendemos informações pessoais. Podemos compartilhar dados apenas com fornecedores e provedores de serviço que atuam em nome do aplicativo, com autoridades quando houver obrigação legal, ou com terceiros quando isso for necessário para fornecer funções solicitadas pelo usuário.",
      "Quando serviços de terceiros forem usados, eles deverão tratar os dados de acordo com suas próprias políticas e com os contratos aplicáveis.",
    ],
  },
  {
    title: "5. Armazenamento e segurança",
    paragraphs: [
      "Adotamos medidas técnicas e organizacionais razoáveis para proteger os dados contra acesso não autorizado, alteração, perda ou divulgação indevida.",
      "Ainda assim, nenhum sistema é totalmente seguro. O usuário deve adotar boas práticas de segurança no próprio dispositivo e na conta utilizada no app.",
    ],
  },
  {
    title: "6. Retenção e exclusão",
    paragraphs: [
      "Mantemos os dados pelo tempo necessário para cumprir as finalidades descritas nesta política, atender exigências legais, resolver disputas e executar os contratos aplicáveis.",
      "Quando aplicável, o usuário pode solicitar a exclusão da conta ou de determinados dados entrando em contato pelo e-mail de suporte informado nesta página.",
    ],
  },
  {
    title: "7. Permissões do dispositivo",
    paragraphs: [
      "Algumas funções do aplicativo dependem de permissões concedidas pelo usuário no Android. Essas permissões são usadas somente quando necessárias para a funcionalidade correspondente e podem ser revogadas nas configurações do sistema, embora isso possa limitar recursos do app.",
    ],
  },
  {
    title: "8. Alterações nesta política",
    paragraphs: [
      "Esta política pode ser atualizada para refletir mudanças no aplicativo, na legislação ou em práticas operacionais. A versão mais recente ficará disponível nesta mesma página.",
    ],
  },
];

export default function PrivacyPolicyPage() {
  return (
    <main className="min-h-screen bg-white text-slate-900">
      <div className="mx-auto flex min-h-screen w-full max-w-4xl flex-col px-6 py-10 sm:px-8 lg:px-10">
        <div className="mb-8 flex items-center justify-between gap-4 border-b border-slate-200 pb-6">
          <div>
            <p className="text-sm font-semibold uppercase tracking-[0.24em] text-blue-600">
              Direção Financeira
            </p>
            <h1 className="mt-3 text-4xl font-black tracking-tight sm:text-5xl">
              Política de Privacidade
            </h1>
          </div>
          <Link
            href="/"
            className="hidden rounded-full border border-slate-200 px-4 py-2 text-sm font-semibold text-slate-600 transition-colors hover:border-slate-300 hover:text-slate-900 sm:inline-flex"
          >
            Voltar
          </Link>
        </div>

        <section className="space-y-6 text-[15px] leading-7 text-slate-700 sm:text-base">
          <p>
            Esta página explica, de forma objetiva, como o aplicativo Direção
            Financeira trata informações dos usuários, do dispositivo e dos
            serviços necessários para entregar as funcionalidades do app.
          </p>

          <div className="rounded-3xl border border-slate-200 bg-slate-50/80 p-6">
            <p className="text-sm font-semibold uppercase tracking-[0.22em] text-slate-500">
              Contato
            </p>
            <p className="mt-3 text-lg font-semibold text-slate-900">
              {supportEmail}
            </p>
            <p className="mt-2 text-slate-600">
              E-mail para dúvidas sobre privacidade, conta e exclusão de dados.
            </p>
          </div>

          {sections.map((section) => (
            <section key={section.title} className="space-y-3 pt-2">
              <h2 className="text-2xl font-bold tracking-tight text-slate-900">
                {section.title}
              </h2>
              {section.paragraphs.map((paragraph) => (
                <p key={paragraph}>{paragraph}</p>
              ))}
            </section>
          ))}

          <section className="pt-2">
            <h2 className="text-2xl font-bold tracking-tight text-slate-900">
              9. Solicitação de exclusão de conta
            </h2>
            <p className="mt-3">
              Se você quiser solicitar a exclusão da conta ou de dados
              vinculados ao aplicativo, envie uma mensagem para{" "}
              <a
                href={`mailto:${supportEmail}`}
                className="font-semibold text-blue-600 underline underline-offset-4"
              >
                {supportEmail}
              </a>
              .
            </p>
          </section>

          <div className="mt-10 rounded-3xl border border-slate-200 bg-white p-6 text-sm text-slate-500">
            <p>
              Última atualização: {new Date().getFullYear()} • {companyName}
            </p>
          </div>
        </section>
      </div>
    </main>
  );
}
