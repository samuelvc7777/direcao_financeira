import '../entities/category_entity.dart';

abstract class ICategoryRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<CategoryEntity> createCategory({
    required String name,
    required CategoryType type,
    required String color,
    required String icon,
  });
  Future<CategoryEntity> updateCategory({
    required int id,
    required String name,
    required CategoryType type,
    required String color,
    required String icon,
  });
  Future<void> deactivateCategory(int id);
}
