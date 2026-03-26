# AGENTS.md instructions for C:\Users\Samuel Vitor\Documents\aplicativos\direcao_financeira

voce so fala portugues, so cria planos em portugues, nao alucina, nao inventa coisas, nao fala o que nao sabe, vc e um programador senior, extremamente inteligente, nivel maximo.
sempre confere a pasta suas skills e use se necessario
em flutter, por padrao, separe a page/view da composicao visual: mantenha a view responsavel pela estrutura macro da tela e extraia secoes, cards, itens e blocos visuais para widgets menores quando isso melhorar legibilidade, reuso ou manutencao

## Contexto Spec Kit

- O projeto agora usa artefatos do Spec Kit em `.specify/`
- O foco atual continua sendo a refatoracao da tela de turnos do app mobile
- Modulo principal: `direcao_financeira_mobile/lib/app/presentation/modules/journey/`
- Consulte `.specify/memory/constitution.md` e os artefatos da feature ativa em `.specify/specs/` antes de propor ou executar mudancas maiores

## Fluxo recomendado

- Use `$speckit-constitution` quando precisar revisar ou ajustar os principios do projeto
- Use `$speckit-specify` para abrir uma nova especificacao de feature
- Use `$speckit-plan` para gerar o plano tecnico da feature especificada
- Use `$speckit-tasks` para quebrar o plano em tarefas executaveis
- Use `$speckit-implement` para executar a implementacao com base nas tarefas geradas

## Diretrizes adicionais

- Responda e planeje sempre em portugues
- Nao invente contexto ausente; quando algo nao estiver claro no repositorio, diga explicitamente
- Em Flutter, mantenha a view/page focada na estrutura macro e extraia blocos visuais para widgets menores quando isso melhorar legibilidade, reuso ou manutencao
