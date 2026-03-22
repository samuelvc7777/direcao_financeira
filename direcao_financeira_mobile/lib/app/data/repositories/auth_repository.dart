import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepository implements IAuthRepository {
  AuthRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final IAuthRemoteDataSource remoteDataSource;
  final IAuthLocalDataSource localDataSource;

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    print('AuthRepository.login() - Iniciando login no repositório');
    try {
      final response = await remoteDataSource.login(
        email: email,
        password: password,
      );
      print('AuthRepository.login() - Resposta do datasource recebida');
      final token = response['access_token'];
      final userData = response['user'];

      if (token is String && token.isNotEmpty) {
        print('AuthRepository.login() - Token válido, salvando no localDataSource');
        await localDataSource.saveToken(token);
      } else {
        print('AuthRepository.login() - ALERTA: Token ausente ou inválido na resposta');
      }

      if (userData is Map<String, dynamic>) {
        print('AuthRepository.login() - User data válido, salvando e retornando');
        await localDataSource.saveUser(userData);
        return Right(UserModel.fromJson(userData));
      } else {
        print('AuthRepository.login() - ALERTA: User data ausente ou inválido na resposta');
      }

      print('AuthRepository.login() - Retornando ServerFailure (Resposta inválida)');
      return Left(ServerFailure('Resposta invalida ao realizar login.'));
    } on DioException catch (e) {
      print('AuthRepository.login() - Capturado DioException: ${e.message}, status: ${e.response?.statusCode}');
      print('AuthRepository.login() - Dados do erro: ${e.response?.data}');
      final message = _extractMessage(e, 'Erro ao realizar login.');
      return Left(ServerFailure(message));
    } catch (e, stack) {
      print('AuthRepository.login() - Erro inesperado: $e');
      print('AuthRepository.login() - StackTrace: $stack');
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
      final response = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );
      final token = response['access_token'];
      final userData = response['user'];

      if (token is String && token.isNotEmpty) {
        await localDataSource.saveToken(token);
      }
      if (userData is Map<String, dynamic>) {
        await localDataSource.saveUser(userData);
      }

      return Right(response);
    } on DioException catch (e) {
      final message = _extractMessage(e, 'Erro ao realizar cadastro.');
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao realizar cadastro.'));
    }
  }

  @override
  Future<Either<Failure, void>> saveToken(String token) async {
    try {
      await localDataSource.saveToken(token);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao salvar token.'));
    }
  }

  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      return Right(localDataSource.getToken());
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

      await localDataSource.saveUser(userModel.toJson());
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao salvar dados do usuário.'));
    }
  }

  @override
  Either<Failure, UserEntity?> getStoredUser() {
    try {
      return Right(localDataSource.getStoredUser());
    } catch (e) {
      return Left(DatabaseFailure('Erro ao ler dados do usuário.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearSession();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao fazer logout.'));
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
