# Responsive Quality Contract

## Purpose
Definir o contrato de qualidade responsiva que toda tela ativa deve cumprir antes de ser considerada pronta.

## Scope
- Aplica-se a todas as rotas ativas do `direcao_financeira_admin_web`.
- Aplica-se aos estados de dados, vazio, erro e loading.
- Aplica-se aos perfis de viewport obrigatorios definidos para a feature.

## Viewport Matrix
- Mobile: 360px a 767px de largura.
- Tablet: 768px a 1023px de largura.
- Notebook: 1024px a 1279px de largura.
- Desktop: 1280px ou mais.

## Required Checks

### CQ-001 Integridade Visual
- Nenhum elemento essencial pode ficar cortado, sobreposto ou fora de alcance.
- Nao pode haver rolagem horizontal obrigatoria em fluxos criticos.

### CQ-002 Acesso a Acoes Primarias
- A principal acao de cada tela deve estar visivel ou facilmente alcancavel sem bloqueio estrutural.

### CQ-003 Legibilidade Operacional
- Informacoes essenciais devem permanecer legiveis sem zoom manual.
- Hierarquia visual deve manter prioridade de conteudo e acao.

### CQ-004 Consistencia entre Modulos
- Componentes equivalentes devem manter comportamento responsivo coerente entre modulos.

### CQ-005 Estabilidade em Redimensionamento
- Mudanca de viewport durante uso nao pode quebrar navegacao, formulario ou continuidade basica da interacao.

### CQ-006 Consistencia de Estrutura
- Telas do dashboard devem usar sidebar fixa em desktop e drawer lateral acionado por botao em viewports mobile.
- Paginas de conteudo devem respeitar largura maxima, padding fluido e tabelas com overflow horizontal controlado.

## Approval Rule
Uma tela e aprovada somente quando todos os checks obrigatorios passam em todos os perfis de viewport definidos.

## Failure Classification
- Bloqueante: impede uso funcional ou acesso a acao primaria.
- Alta: degrada fortemente legibilidade/operacao, mas permite contorno.
- Media: inconsistencia visual sem bloqueio direto de fluxo.
