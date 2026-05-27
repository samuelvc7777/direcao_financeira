# Contract - Google API Settings (Admin <-> Mobile)

## Objetivo

Definir o contrato funcional para leitura da API Google ativa usada nos fluxos mobile de OCR e print.

## Operações

### 1) Atualizar configuração (Admin)

- Endpoint: `PATCH /api/admin/company-settings`
- Payload:
  - `googleApiKey`: string obrigatória (após trim, não vazia)
- Resposta de sucesso:
  - `id`: number
  - `googleApiKey`: string
  - `supportPhone`: string | null
- Pré-condições:
  - usuário autenticado
  - usuário com permissão administrativa
  - valor não vazio
- Resultado esperado:
  - valor persistido como configuração ativa única
  - retorno de sucesso para a interface

### 2) Ler configuração ativa (Consumidor Mobile)

- Endpoint: `GET /api/admin/company-settings`
- Resposta:
  - `id`: number
  - `googleApiKey`: string | null
  - `supportPhone`: string | null
- Ação: consultar configuração ativa para OCR/print.
- Pré-condições:
  - canal de leitura autorizado conforme política existente
- Resultado esperado:
  - retorno do valor ativo atual
  - ausência explícita quando não houver configuração

## Regras de negócio

- Deve existir no máximo uma configuração ativa por ambiente.
- Atualização substitui o valor ativo anterior.
- Falha de persistência não pode corromper valor ativo anterior.
- Escrita é exclusiva para perfil administrativo.
