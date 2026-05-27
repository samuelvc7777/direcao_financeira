# Feature Specification: Cadastro de API Google

**Feature Branch**: `003-configurar-api-google`  
**Created**: 2026-05-27  
**Status**: Draft  
**Input**: User description: "na tela de configurações será onde iremos colocar a API do Google que nosso app mobile irá consumir no OCR e na tela de print"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Cadastrar API Google nas Configurações (Priority: P1)

Como administrador, quero cadastrar e atualizar a API do Google na tela de Configurações para centralizar a gestão da credencial consumida pelo app mobile.

**Why this priority**: Sem esse cadastro centralizado, OCR e print no app mobile ficam dependentes de configuração manual fora do fluxo administrativo.

**Independent Test**: Pode ser testada de forma independente acessando Configurações, preenchendo a API e salvando, com confirmação de persistência ao recarregar a tela.

**Acceptance Scenarios**:

1. **Given** que estou na tela de Configurações com permissão administrativa, **When** informo uma API válida e salvo, **Then** o sistema persiste o valor e exibe confirmação de sucesso.
2. **Given** que já existe uma API salva, **When** edito e salvo um novo valor, **Then** o valor anterior é substituído e o novo valor passa a ser o ativo.

---

### User Story 2 - Validar entrada para evitar configuração inválida (Priority: P2)

Como administrador, quero validação de preenchimento para evitar salvar uma API vazia ou claramente inválida.

**Why this priority**: Evita falhas operacionais no app mobile por erro básico de cadastro.

**Independent Test**: Pode ser testada tentando salvar campo vazio, com espaços ou valor fora do padrão aceito.

**Acceptance Scenarios**:

1. **Given** que o campo da API está vazio, **When** tento salvar, **Then** o sistema bloqueia o salvamento e apresenta mensagem de validação.
2. **Given** que o campo contém apenas espaços, **When** tento salvar, **Then** o sistema bloqueia o salvamento e orienta correção.

---

### User Story 3 - Disponibilizar configuração para consumo mobile (Priority: P3)

Como produto, quero que a API cadastrada no admin fique disponível para o app mobile consumir nos fluxos de OCR e print.

**Why this priority**: Garante integração ponta a ponta após o cadastro administrativo.

**Independent Test**: Pode ser testada consultando o ponto de consumo do app mobile e verificando retorno da API ativa cadastrada no admin.

**Acceptance Scenarios**:

1. **Given** que existe API ativa cadastrada, **When** o app mobile consulta a configuração para OCR/print, **Then** recebe a API ativa atual.
2. **Given** que a API foi atualizada no admin, **When** o app mobile consulta novamente, **Then** recebe o valor mais recente.

### Edge Cases

- Tentativa de salvar duas vezes em sequência rápida não deve gerar estado inconsistente.
- Falha temporária de persistência deve manter o valor anterior e retornar erro claro para o administrador.
- Se não houver API cadastrada, o sistema deve retornar ausência de configuração de forma explícita para o consumidor.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O sistema MUST disponibilizar na tela de Configurações um campo dedicado para cadastro da API Google usada pelo app mobile.
- **FR-002**: O sistema MUST permitir criar e atualizar o valor da API Google.
- **FR-003**: O sistema MUST validar que o valor informado não está vazio antes de salvar.
- **FR-004**: O sistema MUST persistir o valor salvo e exibir o valor atual ao reabrir a tela.
- **FR-005**: O sistema MUST registrar status de sucesso ou falha de salvamento com feedback claro para o administrador.
- **FR-006**: O sistema MUST expor a API Google ativa para consumo do app mobile nos fluxos de OCR e print.
- **FR-007**: O sistema MUST garantir que, após atualização, apenas o valor mais recente seja considerado ativo.
- **FR-008**: O sistema MUST restringir edição dessa configuração a usuários com permissão administrativa.

### Key Entities *(include if feature involves data)*

- **Configuração de API Google**: Representa a credencial ativa para integração mobile; atributos principais: valor da API, data de atualização, usuário responsável pela atualização, status ativo.
- **Permissão de Administração**: Representa a autorização necessária para leitura e escrita da configuração; define quem pode alterar o valor.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% das tentativas de salvamento com campo vazio são bloqueadas com mensagem de validação.
- **SC-002**: Em ambiente normal, administradores conseguem cadastrar ou atualizar a API em até 1 minuto.
- **SC-003**: Em testes de aceitação, 95% ou mais das consultas do app mobile para OCR/print retornam a API ativa esperada na primeira tentativa.
- **SC-004**: Após atualização da API no admin, o novo valor fica disponível para consumo mobile em até 30 segundos.

## Assumptions

- Existe um mecanismo já disponível no backend para armazenar configuração administrativa persistente.
- O app mobile já possui fluxo para consultar essa configuração sem necessidade de novo canal de autenticação.
- Apenas uma API Google ativa é necessária por ambiente.
- A feature cobre cadastro e atualização da API; rotação automática e versionamento histórico detalhado ficam fora do escopo inicial.
