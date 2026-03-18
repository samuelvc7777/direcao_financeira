import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/user_model.dart';

class AuthRepository implements IAuthRepository {
  final Dio dio;
  final GetStorage storage;

  AuthRepository({required this.dio, required this.storage});

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['access_token'];
      final userData = response.data['user'];

      await storage.write('token', token);
      await storage.write('user', userData);

      return Right(UserModel.fromJson(userData));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Erro ao realizar login';
      return Left(ServerFailure(message is List ? message.first.toString() : message.toString()));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao realizar login.'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      final token = response.data['access_token'];
      final userData = response.data['user'];

      if (token != null) {
        await storage.write('token', token);
      }
      if (userData != null) {
        await storage.write('user', userData);
      }

      return Right(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Erro ao realizar cadastro.';
      return Left(ServerFailure(message is List ? message.first.toString() : message.toString()));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao realizar cadastro.'));
    }
  }

  @override
  Future<Either<Failure, void>> saveToken(String token) async {
    try {
      await storage.write('token', token);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao salvar token.'));
    }
  }

  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      return Right(storage.read('token'));
    } catch (e) {
      return Left(DatabaseFailure('Erro ao ler token.'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUser(UserEntity user) async {
    try {
      final userModel = user is UserModel
          ? user
          : UserModel(
              id: user.id,
              email: user.email,
              name: user.name,
              role: user.role,
              isActive: user.isActive,
              createdAt: user.createdAt,
              updatedAt: user.updatedAt,
              activeSubscription: user.activeSubscription,
              subscriptions: user.subscriptions,
            );

      await storage.write('user', userModel.toJson());
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao salvar dados do usuário.'));
    }
  }

  @override
  Either<Failure, UserEntity?> getStoredUser() {
    try {
      final user = storage.read('user');
      if (user is! Map<String, dynamic>) {
        return const Right(null);
      }
      return Right(UserModel.fromJson(user));
    } catch (e) {
      return Left(DatabaseFailure('Erro ao ler dados do usuário.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await storage.remove('token');
      await storage.remove('user');
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao fazer logout.'));
    }
  }
}
