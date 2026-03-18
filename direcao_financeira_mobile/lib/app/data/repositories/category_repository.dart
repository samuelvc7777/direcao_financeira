import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../datasources/category_datasource.dart';

class CategoryRepository implements ICategoryRepository {
  CategoryRepository({required this.dataSource});

  final ICategoryDataSource dataSource;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      return Right(await dataSource.getCategories());
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
      return Right(
        await dataSource.createCategory(
          name: name,
          type: type,
          color: color,
          icon: icon,
        ),
      );
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
      return Right(
        await dataSource.updateCategory(
          id: id,
          name: name,
          type: type,
          color: color,
          icon: icon,
        ),
      );
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e, 'Erro ao atualizar categoria.')));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao atualizar categoria.'));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateCategory(int id) async {
    try {
      await dataSource.deactivateCategory(id);
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
      await dataSource.reactivateCategory(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(_extractMessage(e, 'Erro ao reativar categoria.')),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao reativar categoria.'));
    }
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
