# Data Model - Cadastro de API Google

## Entidade: GoogleApiSetting

- id: identificador único do registro de configuração
- apiValue: valor da API Google ativa
- isActive: indicador de configuração ativa
- updatedAt: data/hora da última atualização
- updatedBy: identificador do usuário administrador que realizou a alteração

## Regras de Validação

- `apiValue` é obrigatório e não pode ser vazio após trim.
- Apenas um registro pode estar ativo por ambiente.
- Atualizações substituem o valor ativo anterior.

## Relações

- GoogleApiSetting -> AdminUser (N:1) via `updatedBy`.

## Transições de Estado

1. Sem configuração ativa -> configuração criada e marcada ativa.
2. Configuração ativa existente -> valor atualizado e permanece única ativa.
3. Falha na persistência -> estado anterior mantido integralmente.
