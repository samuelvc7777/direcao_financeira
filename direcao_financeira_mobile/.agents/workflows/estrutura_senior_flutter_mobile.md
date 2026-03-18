---
description: Estrutura Sênior App Mobile - Padrão Clean Architecture com GetX para criação de apps Flutter profissionais
---

# Estrutura Sênior App Mobile

Este workflow define o padrão de mercado para criar qualquer app mobile Flutter usando **Clean Architecture + GetX + Tratamento de Erros Funcional (Dartz)**.

## Regras Fundamentais

1. **Sempre use `Either<Failure, T>`** para retornos no Domain e Data.
2. **RepositoryImpl é o guardião**: use `try/catch` ali para capturar exceções e retornar `Left(Failure)`.
3. **Controller usa `.fold()`**: nunca use `try/catch` no Controller para lógica de dados.
4. **Domain puro**: sem Flutter ou dependências de UI.

---

## Passo a Passo para Criar um Novo App

### 1. Dependências (pubspec.yaml)
Adicione: `get`, `dartz`, e sua fonte de dados (ex: `sqflite`).
// turbo
```bash
flutter pub add get dartz sqflite path
```

### 2. Core e Erros
Crie `lib/core/errors/failures.dart`:
```dart
abstract class Failure { final String message; Failure(this.message); }
class DatabaseFailure extends Failure { DatabaseFailure(super.message); }
```

### 3. Domain (Contratos e Ações)
1. **Entity**: Classe pura Dart.
2. **Repository (Interface)**:
   ```dart
   Future<Either<Failure, List<Entity>>> getData();
   ```
3. **UseCase**: Recebe Repository e retorna `repository.getData()`.

### 4. Data (Implementação Real)
1. **Model**: Extende Entity com `fromMap/toMap`.
2. **DataSource**: Interface com a tecnologia (SQLite/API).
3. **RepositoryImpl**:
   ```dart
   try {
     final data = await dataSource.fetch();
     return Right(data);
   } catch (e) {
     return Left(DatabaseFailure(e.toString()));
   }
   ```

### 5. App (Apresentação)
1. **Controller**:
   ```dart
   final res = await useCase();
   res.fold(
     (f) => Get.snackbar('Erro', f.message),
     (data) => list.assignAll(data)
   );
   ```
2. **Binding**: Injeta DataSource → RepoImpl → UseCases → Controller.
3. **Theme/Routes**: Configuração padrão GetX.
4. **UI**: `GetView<Controller>` + `Obx`.

---

## Checklist Sênior

- [ ] Repository retorna `Either`?
- [ ] Tem `try/catch` no RepositoryImpl?
- [ ] O Controller usa `.fold()`?
- [ ] As strings de erro são amigáveis para o usuário?
- [ ] Existe um estado de `isLoading` no Controller?
