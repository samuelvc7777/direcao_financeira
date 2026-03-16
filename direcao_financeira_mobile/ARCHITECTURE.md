# Arquitetura Direcao Financeira Mobile

Este projeto utiliza Clean Architecture, principios SOLID e Design Patterns com GetX para coordenacao de UI e injecao de dependencias.

## Camadas do Sistema

### 1. Domain (Negocio)
- Entities: classes puras de dados.
- Use Cases: regras de negocio de grao fino.
- Repositories (abstract): contratos para acesso a dados.

### 2. Data (Infraestrutura)
- Models: extensoes das entidades para serializacao.
- Repositories (implementation): conectam interfaces do dominio a fontes reais.
- Data Sources: clientes HTTP ou banco local.

### 3. Presentation (Interface)
- Modules: conjunto de View + Controller + Binding.
- Controllers: gerenciam estado e invocam os use cases.
- Bindings: configuram injecao de dependencias.
- Views: widgets puras e reativas.

## Estrutura de Pastas

```text
lib/
  app/
    core/               # Temas, utils, constantes e erros globais
    domain/             # Entities, use cases e interfaces de repositorio
    data/               # Models, repositorios concretos e data sources
    presentation/       # Modules, rotas e widgets compartilhados
    bindings/           # DI geral
    routes/             # Rotas do app
  main.dart
```

## Global Style & Design System

Para garantir uma experiencia premium e consistente, o app utiliza um sistema de design centralizado em `app/core/theme`:
- Typography: fonte Inter para legibilidade.
- Color Palette: tons de Petrol, Teal, Sand e Rust.
- Theming: suporte a Light Mode e Dark Mode.
- Material 3: componentes alinhados com as diretrizes atuais do Google.

### Padrao de Componentizacao
1. Widgets globais (`app/presentation/widgets/`): componentes genericos e reutilizaveis em qualquer modulo.
2. Widgets locais (`app/presentation/modules/{module}/widgets/`): componentes especificos de cada modulo para reduzir o tamanho da view e isolar responsabilidades visuais.

## Responsividade & Design Adaptativo

O aplicativo e mobile-only e deve oferecer uma experiencia consistente em qualquer tamanho de tela Android.
- Layouts fluidos: uso de `Flexible`, `Expanded`, `Spacer`, `Wrap` e constraints adaptativas para evitar overflow.
- Scaling inteligente: dimensoes baseadas em `MediaQuery` ou `LayoutBuilder` quando necessario.
- Scrollable areas: telas com inputs devem usar `SingleChildScrollView` para evitar que o teclado cubra o conteudo.
- Adaptabilidade: fontes, paddings e distribuicao visual devem ser testados em celulares compactos, intermediarios e telas Android maiores.

## Principios Aplicados
- Single Responsibility: cada use case faz apenas uma coisa.
- Open/Closed: extensibilidade via abstracoes.
- Liskov Substitution: repositories seguem interfaces rigorosas.
- Interface Segregation: interfaces pequenas e especificas.
- Dependency Inversion: controllers dependem de abstracoes, nao de implementacoes.

## Design Patterns
- Repository Pattern: abstracao de persistencia.
- Mapper Pattern: conversao entre camadas.
- Observer Pattern: gerenciamento reativo com GetX.
- Factory Pattern: criacao de instancias e desserializacao.
