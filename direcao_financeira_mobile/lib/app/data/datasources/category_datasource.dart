import 'package:dio/dio.dart';

import '../../domain/entities/category_entity.dart';
import '../models/category_model.dart';

abstract class ICategoryDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> createCategory({
    required String name,
    required CategoryType type,
    required String color,
    required String icon,
  });
  Future<CategoryModel> updateCategory({
    required int id,
    required String name,
    required CategoryType type,
    required String color,
    required String icon,
  });
  Future<void> deactivateCategory(int id);
  Future<void> reactivateCategory(int id);
}

class CategoryRemoteDataSource implements ICategoryDataSource {
  CategoryRemoteDataSource({required this.dio});

  final Dio dio;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await dio.get('/finance/categories');
    final data = response.data;
    final items = data is List
        ? data
        : data is Map<String, dynamic>
            ? (data['data'] ?? data['categories'] ?? [])
            : [];

    if (items is! List) {
      return [];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }

  @override
  Future<CategoryModel> createCategory({
    required String name,
    required CategoryType type,
    required String color,
    required String icon,
  }) async {
    final response = await dio.post(
      '/finance/categories',
      data: {
        'name': name,
        'type': type.toApiValue(),
        'color': color,
        'icon': icon,
      },
    );

    return _parseCategory(response.data);
  }

  @override
  Future<CategoryModel> updateCategory({
    required int id,
    required String name,
    required CategoryType type,
    required String color,
    required String icon,
  }) async {
    final response = await dio.patch(
      '/finance/categories/$id',
      data: {
        'name': name,
        'type': type.toApiValue(),
        'color': color,
        'icon': icon,
      },
    );

    return _parseCategory(response.data);
  }

  @override
  Future<void> deactivateCategory(int id) {
    return dio.patch(
      '/finance/categories/$id',
      data: {'isActive': false},
    );
  }

  @override
  Future<void> reactivateCategory(int id) {
    return dio.patch(
      '/finance/categories/$id',
      data: {'isActive': true},
    );
  }

  CategoryModel _parseCategory(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return CategoryModel.fromJson(data['data'] as Map<String, dynamic>);
      }

      return CategoryModel.fromJson(data);
    }

    throw Exception('Resposta invalida da API de categorias.');
  }
}
