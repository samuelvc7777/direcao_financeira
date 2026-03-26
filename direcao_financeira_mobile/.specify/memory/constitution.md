<!--
Sync Impact Report
- Version change: template -> 1.0.0
- Modified principles: inicializacao da constituicao
- Added sections: Restricoes de Arquitetura, Fluxo de Trabalho
- Removed sections: nenhuma
- Templates requiring updates:
  - ✅ .specify/templates/plan-template.md
  - ✅ .specify/templates/spec-template.md
  - ✅ .specify/templates/tasks-template.md
- Follow-up TODOs: nenhum
-->

# Direcao Financeira Mobile Constitution

## Core Principles

### I. Verdade e Contexto Real
Toda decisao tecnica MUST partir do estado real do repositorio, do comportamento observado e
dos requisitos explicitados. Nao e permitido inventar regras, fluxos, dependencias ou
comportamentos nao verificados. Quando houver lacuna de contexto, ela MUST ser registrada com
clareza antes de qualquer mudanca estrutural.

### II. Especificacao Antes da Implementacao
Mudancas relevantes MUST nascer de uma especificacao em `.specify/specs/`, seguida de plano e
tarefas executaveis. Implementacao direta sem especificacao so e aceitavel em ajustes pequenos,
locais e de baixo risco. O escopo da entrega MUST permanecer alinhado ao que foi especificado.

### III. Arquitetura Flutter Legivel
A tela Flutter MUST manter separacao entre page/view e composicao visual. A view responde pela
estrutura macro, navegacao, estados globais e orquestracao basica; secoes, cards, listas, itens
e blocos visuais SHOULD ser extraidos para widgets menores quando isso melhorar legibilidade,
reuso ou manutencao. Widgets e controllers MUST ter responsabilidades claras e nomes coerentes.

### IV. Qualidade e Regressao Controlada
Toda alteracao MUST considerar impacto em contratos existentes, fluxo do usuario e testes
relacionados. Correcao local que introduz regressao sistemica e inaceitavel. Sempre que viavel,
devem ser atualizados ou adicionados testes automatizados nas areas tocadas, especialmente em
regras de negocio, formatacao, filtros, agregacoes e coordenacao de estado.

### V. Simplicidade com Evolucao Segura
A implementacao MUST preferir o menor desenho que resolva o problema atual com clareza. Abstracoes
prematuras, duplicacao acidental e acoplamento desnecessario SHOULD ser evitados. Quando uma
refatoracao for necessaria, ela deve melhorar a evolucao futura sem esconder comportamento nem
quebrar o fluxo funcional existente.

## Restricoes de Arquitetura

O projeto usa Flutter com GetX e organizacao por camadas. Mudancas em presentation, domain e data
devem respeitar fronteiras claras. Controllers nao devem absorver responsabilidades de datasource,
repositorio ou regra de negocio complexa quando isso puder ser isolado em servicos, use cases ou
entidades. Decisoes que afetem multiplos modulos devem explicitar impacto em bindings, estados e
fluxo de dependencia.

## Fluxo de Trabalho

O fluxo padrao do projeto e:

1. Atualizar ou validar a constituicao com `$speckit-constitution`, quando necessario.
2. Criar a especificacao da feature com `$speckit-specify`.
3. Gerar o plano tecnico com `$speckit-plan`.
4. Gerar tarefas executaveis com `$speckit-tasks`.
5. Implementar seguindo as tarefas com `$speckit-implement`.

Para tarefas pequenas e de baixo risco, pode haver execucao direta, mas o agente ainda MUST
preservar os principios desta constituicao e registrar claramente as suposicoes feitas.

## Governance

Esta constituicao prevalece sobre instrucoes informais de fluxo dentro do repositorio. Toda
mudanca relevante em principios, arquitetura ou forma de execucao deve atualizar este documento.
O versionamento segue semver:

- MAJOR para mudancas incompativeis de principios ou governanca
- MINOR para novos principios, novas restricoes ou ampliacao material de regras
- PATCH para clarificacoes editoriais sem mudanca substantiva

Toda revisao tecnica relevante SHOULD validar aderencia a esta constituicao, aos artefatos em
`.specify/` e ao estado real do codigo alterado.

**Version**: 1.0.0 | **Ratified**: 2026-03-26 | **Last Amended**: 2026-03-26
