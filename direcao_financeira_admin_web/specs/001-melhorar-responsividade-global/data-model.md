# Data Model - Responsividade Global da Aplicacao

## Entidade: TelaAplicacional
- Descricao: Cada rota funcional da aplicacao que precisa cumprir contrato de responsividade.
- Campos:
  - `id`: identificador unico da tela (slug da rota)
  - `modulo`: agrupamento funcional (auth, dashboard, billing, plans, users, settings, etc.)
  - `criticidade`: nivel de prioridade operacional (P1, P2, P3)
  - `acoesPrimarias`: lista de acoes que nao podem ficar inacessiveis
  - `estadosCobertos`: estados previstos (dados, vazio, erro, loading)
- Relacionamentos:
  - 1:N com `ResultadoValidacaoResponsiva`

## Entidade: PerfilViewport
- Descricao: Faixa de dimensao usada para avaliar adaptacao visual.
- Campos:
  - `id`: nome do perfil (mobile, tablet, notebook, desktop)
  - `larguraMin`: limite inferior da faixa
  - `larguraMax`: limite superior da faixa
  - `orientacoes`: orientacoes relevantes quando aplicavel
- Relacionamentos:
  - 1:N com `ResultadoValidacaoResponsiva`

## Entidade: CriterioQualidadeResponsiva
- Descricao: Regra objetiva que define aprovacao/reprovacao por tela e viewport.
- Campos:
  - `id`: identificador do criterio
  - `descricao`: regra em linguagem de produto
  - `tipo`: integridade-visual, legibilidade, acessibilidade-operacional, consistencia
  - `severidade`: bloqueante, alta, media
- Relacionamentos:
  - 1:N com `ResultadoValidacaoResponsiva`

## Entidade: ResultadoValidacaoResponsiva
- Descricao: Registro de verificacao da tela em um perfil de viewport contra criterios definidos.
- Campos:
  - `id`: identificador da validacao
  - `telaId`: referencia para `TelaAplicacional`
  - `viewportId`: referencia para `PerfilViewport`
  - `criterioId`: referencia para `CriterioQualidadeResponsiva`
  - `status`: aprovado ou reprovado
  - `evidencia`: observacao objetiva da validacao
  - `dataValidacao`: data/hora da verificacao
- Regras de validacao:
  - Nao pode haver aprovacao global da feature com item bloqueante reprovado.
  - Cada `TelaAplicacional` deve ter resultado para todos os `PerfilViewport` obrigatorios.

## Transicoes de estado relevantes
- `Nao Avaliado` -> `Reprovado` quando qualquer criterio bloqueante falha
- `Nao Avaliado` -> `Aprovado` quando todos os criterios obrigatorios passam
- `Reprovado` -> `Aprovado` apos correcao e nova validacao

## Catalogo de componentes equivalentes
- Shell do dashboard: sidebar fixa em desktop, drawer lateral mobile, labels completas no menu aberto e header fixo.
- Container de pagina: `ResponsiveContainer` aplicado em telas P1 e disponivel para novas telas.
- Grid de cards: `responsive-grid-cards` para metricas e planos.
- Tabelas: wrapper `overflow-x-auto` com padding responsivo em celulas.
- Formularios: largura limitada, padding fluido e controles com largura total em mobile.
