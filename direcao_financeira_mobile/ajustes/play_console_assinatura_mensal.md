# Checklist de assinatura mensal Android

## Contrato desta versao

- Produto oficial Android: `premium_monthly`
- O `productId` da Google Play deve ser exatamente igual ao `plan.code` vindo do backend.
- Pacote Android do app: `br.com.direcaofinanceira.app`

## Play Console

1. Abrir o app `br.com.direcaofinanceira.app` no Play Console.
2. Ir em `Monetizar com o Google Play` -> `Produtos` -> `Assinaturas`.
3. Criar a assinatura com o ID `premium_monthly`.
4. Criar uma oferta base mensal para essa assinatura.
5. Preencher preco, disponibilidade e paises suportados.
6. Ativar testadores licenciados e uma faixa de teste interno ou fechado.

## Backend

- O plano mensal Android precisa sair do backend com `code = premium_monthly`.
- Nao usar alias, nome amigavel ou outro code para o Android nesta rodada.
- Se o backend devolver outro `code`, corrigir no backend antes do teste de compra.

## Teste esperado no app

- A tela de assinatura deve carregar o plano mensal.
- A Google Play deve retornar o produto `premium_monthly`.
- O botao de compra so fica habilitado quando esse produto existir na loja.
- Compras `purchased` e `restored` devem sincronizar a assinatura usando o fluxo atual do app.
