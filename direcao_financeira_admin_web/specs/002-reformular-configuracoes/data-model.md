# Data Model - Reformular tela de configuracoes

## Entidade: PreferenciaUsuario
- Campos:
  - userId (identificador do usuario)
  - tema (claro, escuro, sistema)
  - idioma
  - formatoRegional
  - notificacoesPorCategoria (mapa categoria -> habilitado)
  - updatedAt
- Regras:
  - tema deve aceitar somente valores permitidos
  - idioma e formato regional devem ser validos para a plataforma

## Entidade: SegurancaConta
- Campos:
  - userId
  - sessoesAtivas (colecao de sessoes)
  - ultimoResetSenhaAt
  - historicoAcoesSeguranca
- Regras:
  - encerrar sessoes remotas nao pode invalidar sessao atual
  - troca de senha exige validacao da credencial atual

## Entidade: IntegracaoExterna
- Campos:
  - id
  - userId
  - nome
  - status (ativo, degradado, desconectado)
  - ultimaSincronizacaoAt
  - ultimoErro
- Regras:
  - acao de reconexao disponivel quando status for degradado/desconectado

## Entidade: CanalSuporte
- Campos:
  - id
  - tipo (ajuda, contato, reporte)
  - titulo
  - destino
  - disponibilidade
- Regras:
  - todo canal exibido deve ter destino navegavel valido
