# 🏗️ Estrutura Sênior - App Mobile (Flutter + GetX + Clean Architecture)

> [!IMPORTANT]
> Este documento é o guia definitivo para criar qualquer aplicativo mobile seguindo os padrões de mercado utilizados por empresas como Nubank, iFood e similares. É **agnóstico de tecnologia** e utiliza o padrão de **Tratamento de Erros Profissional** com programação funcional.

---

## 📂 Estrutura de Pastas Completa

```text
lib/
├── main.dart                              # Ponto de entrada do app
│
├── domain/                                # 🧠 CORAÇÃO DO APP (Camada mais interna)
│   ├── entities/                          # O que o app É (Classes puras Dart)
│   │   └── [nome]_entity.dart
│   ├── repositories/                      # Contratos (abstract class usando Either)
│   │   └── [nome]_repository.dart
│   └── usecases/                          # Regras de negócio (ações que retornam Either)
│       ├── get_[nome]s.dart
│       ├── add_[nome].dart
│       ├── update_[nome].dart
│       └── delete_[nome].dart
│
├── data/                                  # 💾 CAMADA DE DADOS (Exterior)
│   ├── models/                            # Tradutores (Entity ↔ Fonte de dados)
│   │   └── [nome]_model.dart
│   ├── datasources/                       # Conexão bruta com a tecnologia
│   │   └── [nome]_datasource.dart
│   └── repositories/                      # Implementação com Try/Catch e Either
│       └── [nome]_repository_impl.dart
│
├── core/                                  # ⚙️ INFRAESTRUTURA
│   ├── constants/
│   ├── errors/                            # Failures (DatabaseFailure, ServerFailure)
│   │   └── failures.dart
│   └── utils/                             # Responsive, Helpers
│
└── app/                                   # 📱 CAMADA DE APRESENTAÇÃO
    ├── bindings/                          # Injeção de dependências
    │   └── [nome]_binding.dart
    ├── routes/                            # Navegação (AppPages / AppRoutes)
    ├── controllers/                       # Gerentes de estado usando .fold()
    │   └── [nome]_controller.dart
    └── ui/
        ├── theme/                         # AppTheme (Light/Dark)
        └── pages/                         # GetView + Widgets
```

---

## 🛡️ Pilar: Tratamento de Erros Profissional (Dartz)

Em apps sêniores, não usamos apenas `return data` ou `throw Exception`. Usamos o padrão **Either** da biblioteca `dartz`.
- **Left (Esquerda):** Retorna uma classe `Failure` (O que deu errado).
- **Right (Direita):** Retorna o dado de sucesso (O que você esperava).

### 1. Criando as Failures (lib/core/errors/failures.dart)
```dart
abstract class Failure {
  final String message;
  Failure(this.message);
}

class DatabaseFailure extends Failure { DatabaseFailure(super.message); }
class ServerFailure extends Failure { ServerFailure(super.message); }
```

---

## 🧅 Camadas da Clean Architecture

### 1. Domain (Coração)

#### Repository (O Contrato usando Either)
```dart
import 'package:dartz/dartz.dart';

abstract class NomeRepository {
  Future<Either<Failure, List<NomeEntity>>> getAll();
  Future<Either<Failure, void>> add(NomeEntity item);
}
```

#### UseCase (Regra de Negócio)
```dart
class GetAll {
  final NomeRepository repository;
  GetAll(this.repository);

  Future<Either<Failure, List<NomeEntity>>> call() async {
    return await repository.getAll();
  }
}
```

---

### 2. Data (Dados)

#### Repository Impl (A "casca" com Try/Catch)
```dart
class NomeRepositoryImpl implements NomeRepository {
  final NomeDataSource dataSource;
  NomeRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<NomeEntity>>> getAll() async {
    try {
      final res = await dataSource.fetchAll();
      final list = res.map((m) => NomeModel.fromMap(m)).toList();
      return Right(list); // Sucesso!
    } catch (e) {
      return Left(DatabaseFailure('Erro ao buscar: $e')); // Erro tratado!
    }
  }
}
```

---

### 3. App (Apresentação)

#### Controller (O Consumidor usando .fold)
```dart
class NomeController extends GetxController {
  final GetAll getAll;
  NomeController({required this.getAll});

  var items = <NomeEntity>[].obs;

  Future<void> load() async {
    final result = await getAll();
    
    result.fold(
      (failure) => _showError(failure.message), // Lida com o erro
      (success) => items.assignAll(success),     // Lida com o sucesso
    );
  }

  void _showError(String m) => Get.snackbar('Erro', m);
}
```

---

## 📏 Regras de Ouro do Sênior

1. **Sempre use `Either`** para retorno de UseCases e Repositories.
2. **Handle errors no Controller** usando o método `.fold()`.
3. **Capture exceções no RepositoryImpl** e converta para `Failure`.
4. **Domain nunca importa `dartz`?** Na verdade, o Domain **pode** importar o `dartz` apenas para usar a interface `Either`, pois isso faz parte do contrato de negócio.
5. **A UI (Page) nunca deve saber o que é um Failure**, isso para no Controller que decide como exibir o erro.

---

## 📦 Dependências (pubspec.yaml)
```yaml
dependencies:
  get: ^4.7.3
  dartz: ^0.10.1    # ESSENCIAL para erros profissionais
  sqflite: ^2.4.2
```
