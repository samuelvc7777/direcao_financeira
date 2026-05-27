# Research - Cadastro de API Google

## Decisão 1: Manter a configuração como registro único administrativo
- Decision: Utilizar um único registro lógico para a API Google ativa nas configurações.
- Rationale: A spec exige apenas uma API ativa por ambiente e simplifica leitura pelo mobile.
- Alternatives considered: múltiplos registros versionados (adiado por aumentar complexidade sem ganho imediato do escopo atual).

## Decisão 2: Validação mínima no ponto de edição
- Decision: Bloquear envio quando o valor estiver vazio ou com apenas espaços.
- Rationale: Atende FR-003 com regra objetiva e previsível para o administrador.
- Alternatives considered: validação semântica profunda do formato da chave (não obrigatória no escopo atual e sujeita a falsos negativos).

## Decisão 3: Restrição de edição por perfil administrativo
- Decision: Exigir perfil administrativo para operação de escrita.
- Rationale: Alinha com FR-008 e reduz risco de alteração indevida.
- Alternatives considered: liberar para qualquer usuário autenticado (rejeitado por risco de governança).

## Decisão 4: Disponibilização para consumo mobile via contrato estável
- Decision: Expor leitura da configuração ativa em contrato simples e estável para OCR/print.
- Rationale: Minimiza acoplamento entre admin e mobile e atende FR-006/FR-007.
- Alternatives considered: embutir configuração diretamente no app mobile (rejeitado por inviabilizar gestão centralizada).
