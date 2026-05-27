# Quickstart - Cadastro de API Google

## Objetivo

Permitir que administrador cadastre/atualize a API Google nas Configurações do admin web e garantir consumo pelo app mobile (OCR/print).

## Passos de validação funcional

1. Abrir a tela de Configurações no admin autenticado como usuário administrativo.
2. Informar valor válido para API Google e salvar.
3. Confirmar mensagem de sucesso e persistência após recarregar a tela.
4. Tentar salvar com campo vazio e validar bloqueio com mensagem de erro.
5. Atualizar para novo valor e confirmar que o valor ativo foi substituído.
6. Validar consulta do consumidor mobile retornando o valor ativo mais recente.

## Critérios de pronto

- Cadastro e atualização funcionam sem inconsistência de estado.
- Campo vazio não é salvo.
- Somente perfil administrativo consegue editar.
- Valor ativo fica disponível para OCR e print no mobile.
