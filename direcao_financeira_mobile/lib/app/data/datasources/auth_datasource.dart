import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

import '../models/user_model.dart';

abstract class IAuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  });
}

abstract class IAuthLocalDataSource {
  Future<void> saveToken(String token);
  String? getToken();
  Future<void> saveUser(Map<String, dynamic> user);
  UserModel? getStoredUser();
  Future<void> clearSession();
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  AuthRemoteDataSource({required this.dio});

  final Dio dio;

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print('AuthRemoteDataSource.login() - POST /auth/login para o email: $email');
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      print('AuthRemoteDataSource.login() - POST /auth/login Status: ${response.statusCode}');
      print('AuthRemoteDataSource.login() - POST /auth/login Response data: ${response.data}');

      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      print('AuthRemoteDataSource.login() - EXCEPTION durante POST /auth/login: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );

    return Map<String, dynamic>.from(response.data as Map);
  }
}

class AuthLocalDataSource implements IAuthLocalDataSource {
  AuthLocalDataSource({required this.storage});

  final GetStorage storage;

  @override
  Future<void> saveToken(String token) => storage.write('token', token);

  @override
  String? getToken() => storage.read<String>('token');

  @override
  Future<void> saveUser(Map<String, dynamic> user) => storage.write('user', user);

  @override
  UserModel? getStoredUser() {
    final user = storage.read('user');
    if (user is! Map<String, dynamic>) {
      return null;
    }

    return UserModel.fromJson(user);
  }

  @override
  Future<void> clearSession() async {
    await storage.remove('token');
    await storage.remove('user');
  }
}
