import 'package:dio/dio.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../models/category_model.dart';

class CategoryRepository implements ICategoryRepository {
  final Dio dio;

  CategoryRepository({required this.dio});

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
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
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, 'Erro ao carregar categorias.'));
    }
  }

  @override
  Future<CategoryEntity> createCategory({
    required String name,
    required CategoryType type,
    required String color,
    required String icon,
  }) async {
    try {
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
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, 'Erro ao criar categoria.'));
    }
  }

  @override
  Future<CategoryEntity> updateCategory({
    required int id,
    required String name,
    required CategoryType type,
    required String color,
    required String icon,
  }) async {
    try {
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
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, 'Erro ao atualizar categoria.'));
    }
  }

  @override
  Future<void> deactivateCategory(int id) async {
    try {
      await dio.delete('/finance/categories/$id');
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, 'Erro ao desativar categoria.'));
    }
  }

  CategoryEntity _parseCategory(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return CategoryModel.fromJson(data['data']);
      }
      return CategoryModel.fromJson(data);
    }

    throw Exception('Resposta invalida da API de categorias.');
  }

  String _extractMessage(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is List && message.isNotEmpty) {
        return message.first.toString();
      }
      if (message != null) {
        return message.toString();
      }
    }
    return fallback;
  }
}
