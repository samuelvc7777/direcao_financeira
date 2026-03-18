import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/i_category_repository.dart';

class LoadCategoriesUseCase {
  LoadCategoriesUseCase(this._repository);

  final ICategoryRepository _repository;

  Future<Either<Failure, List<CategoryEntity>>> call() {
    return _repository.getCategories();
  }
}

class CreateCategoryUseCase {
  CreateCategoryUseCase(this._repository);

  final ICategoryRepository _repository;

  Future<Either<Failure, CategoryEntity>> call({
    required String name,
    required CategoryType type,
    required String color,
    required String icon,
  }) {
    return _repository.createCategory(
      name: name,
      type: type,
      color: color,
      icon: icon,
    );
  }
}

class UpdateCategoryUseCase {
  UpdateCategoryUseCase(this._repository);

  final ICategoryRepository _repository;

  Future<Either<Failure, CategoryEntity>> call({
    required int id,
    required String name,
    required CategoryType type,
    required String color,
    required String icon,
  }) {
    return _repository.updateCategory(
      id: id,
      name: name,
      type: type,
      color: color,
      icon: icon,
    );
  }
}

class DeactivateCategoryUseCase {
  DeactivateCategoryUseCase(this._repository);

  final ICategoryRepository _repository;

  Future<Either<Failure, void>> call(int id) {
    return _repository.deactivateCategory(id);
  }
}

class ReactivateCategoryUseCase {
  ReactivateCategoryUseCase(this._repository);

  final ICategoryRepository _repository;

  Future<Either<Failure, void>> call(int id) {
    return _repository.reactivateCategory(id);
  }
}
