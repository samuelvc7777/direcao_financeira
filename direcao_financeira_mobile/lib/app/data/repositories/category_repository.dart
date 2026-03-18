import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../models/category_model.dart';

class CategoryRepository implements ICategoryRepository {
  final Dio dio;

  CategoryRepository({required this.dio});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final response = await dio.get('/finance/categories');
      final data = response.data;
      final items = data is List
          ? data
          : data is Map<String, dynamic>
              ? (data['data'] ?? data['categories'] ?? [])
              : [];

      if (items is! List) {
        return const Right([]);
      }

      return Right(
        items
            .whereType<Map<String, dynamic>>()
            .map(CategoryModel.fromJson)
            .toList(),
      );
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e, 'Erro ao carregar categorias.')));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao carregar categorias.'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> createCategory({
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

      return Right(_parseCategory(response.data));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e, 'Erro ao criar categoria.')));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao criar categoria.'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory({
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

      return Right(_parseCategory(response.data));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e, 'Erro ao atualizar categoria.')));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao atualizar categoria.'));
    }
  }
@override
Future<Either<Failure, void>> deactivateCategory(int id) async {
  try {
    await dio.patch(
      '/finance/categories/$id',
      data: {'isActive': false},
    );
    return const Right(null);
  } on DioException catch (e) {
    return Left(
      ServerFailure(_extractMessage(e, 'Erro ao desativar categoria.')),
    );
  } catch (e) {
    return Left(ServerFailure('Erro inesperado ao desativar categoria.'));
  }
}
  @override
  Future<Either<Failure, void>> reactivateCategory(int id) async {
    try {
      await dio.patch(
        '/finance/categories/$id',
        data: {'isActive': true},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(_extractMessage(e, 'Erro ao reativar categoria.')),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao reativar categoria.'));
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
