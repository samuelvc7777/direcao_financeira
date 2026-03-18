---
description: Padroes de Input e Formularios Sênior para Flutter e Web - Guia de UX, Validacao e Mascaras
---

# Padroes Sênior para Inputs e Formularios

Este workflow define as melhores praticas para criacao, validacao e comportamento de inputs de texto (TextFields/TextFormFields) em aplicativos Flutter e sistemas Web, com foco em conversao, usabilidade e prevencao de erros.

## 1. Experiencia do Usuario (UX) em Inputs

Inputs mal configurados sao a principal causa de abandono de formularios. Siga estas regras de ouro:

### 1.1. Teclado Contextual (Keyboard Type)
Sempre acione o teclado correto para o tipo de dado solicitado.
- **Numeros/Senhas Numericas:** `TextInputType.number`
- **Telefone:** `TextInputType.phone`
- **Email:** `TextInputType.emailAddress` (adiciona o `@` e `.com` no teclado)
- **URLs:** `TextInputType.url`
- **Texto Longo:** `TextInputType.multiline` com `textInputAction: TextInputAction.newline`

### 1.2. Capitalizacao Automatica (Text Capitalization)
Reduza o atrito formatando o texto automaticamente.
- **Nomes Proprios:** `TextCapitalization.words` (Ex: "Joao Da Silva")
- **Frases/Descricoes:** `TextCapitalization.sentences` (Primeira letra maiuscula)
- **Codigos/Placas/Cupons:** `TextCapitalization.characters` (TUDO MAIUSCULO)
- **Emails/Senhas:** `TextCapitalization.none`

### 1.3. Acao do Teclado (TextInputAction)
O botao de "Enter" do teclado deve guiar o fluxo.
- **Proximo Campo:** `TextInputAction.next`
- **Ultimo Campo:** `TextInputAction.done` ou `TextInputAction.send`
- **Pesquisa:** `TextInputAction.search`

## 2. Mascaras e Formatacao (Masks)

Nunca espere que o usuario digite pontuacoes (hifens, pontos, barras). O sistema deve formatar enquanto ele digita.

### 2.1. Uso no Flutter
Utilize packages como `mask_text_input_formatter` ou crie formatadores customizados usando `TextInputFormatter`.

- **CPF:** `###.###.###-##`
- **CNPJ:** `##.###.###/####-##`
- **Telefone:** `(##) #####-####` ou `(##) ####-####`
- **CEP:** `#####-###`
- **Data:** `##/##/####`

### 2.2. Tratamento de Valores Monetarios (Padrao BR - BRL)
Dinheiro exige precisao absoluta. Nunca utilize tipos flutuantes (`double`) para calculos ou persistencia.

- **Exibicao (UI):** Use o pacote nativo `intl` para formatar a string de saida.
  ```dart
  // Exemplo: R$ 1.500,50
  final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
  String displayValue = currencyFormat.format(valorEmDouble);
  ```
- **Input de Digitacao (TextField):** Valores monetarios **devem** ser alinhados a direita (`textAlign: TextAlign.right`). Comece do zero e formate conforme o usuario digita (Ex: `0,00` -> digita `5` -> `0,05` -> digita `0` -> `0,50`). Utilize pacotes maduros como `currency_text_input_formatter` ou `brasil_fields`.
- **Persistencia (Backend):** No banco de dados e na API, sempre trafegue e salve como **Inteiro (cents/centavos)**. 
  - *Do App para API:* Pegue o valor visual "150,50", converta para `150.50` (double) e multiplique por 100 -> `15050` (int).
  - *Da API para o App:* Receba `15050` (int) e divida por 100 -> `150.50` (double) para exibicao.

## 3. Validacao e Feedback Visual

O usuario deve saber imediatamente se errou, mas nao seja punitivo antes da hora.

### 3.1. Quando validar?
- **Ao digitar (onChange):** Apenas para checagens de forca de senha ou limites de caracteres.
- **Ao perder o foco (onUnfocus / onEditingComplete):** Ideal para verificar emails invalidos ou CPFs incorretos.
- **Ao enviar (onSubmit):** Obrigatorio para garantir que nada passe em branco.

### 3.2. Mensagens de Erro
- Nao use: "Erro 404" ou "Campo invalido".
- Use: "O email deve conter um @" ou "A senha precisa ter pelo menos 8 caracteres".
- O erro deve aparecer logo abaixo do input, em cor de contraste (geralmente vermelho/rust) e, de preferencia, acompanhado de um icone de alerta para daltonicos.

## 4. Acessibilidade (A11y)

- **Labels vs Hints:** O `hintText` (placeholder) some quando o usuario digita. Sempre tenha um `labelText` ou um texto descritivo acima do campo.
- **Focus Nodes:** Garanta que a navegacao por `Tab` no teclado fisico siga a ordem logica do formulario (esquerda->direita, cima->baixo).
- **Semantica:** No Flutter Web, certifique-se de que os inputs tenham a propriedade `semanticsLabel` preenchida para leitores de tela.

## 5. Botoes de Acao em Formularios

- **Estado de Loading:** Ao clicar em salvar, o botao deve assumir um estado de carregamento (`CircularProgressIndicator`) e ser **desabilitado** para evitar cliques duplos (duplo POST).
- **Feedback de Sucesso/Falha:** Apos a conclusao, exiba um Snackbar (Get.snackbar) ou um Toast claro na parte inferior ou superior da tela.

## Checklist Sênior de Formularios
- [ ] O teclado abre no formato correto (numero, email, texto)?
- [ ] A primeira letra fica maiuscula quando necessario?
- [ ] Existe mascara para CPFs, telefones e datas?
- [ ] O botao "Enter" pula para o proximo campo?
- [ ] O botao de envio bloqueia duplos cliques?
- [ ] Os erros sao explicativos e humanizados?
- [ ] Valores monetarios estao sendo convertidos para centavos antes do POST?
