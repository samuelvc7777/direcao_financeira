import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/user_model.dart';

class AuthRepository implements IAuthRepository {
  final Dio dio;
  final GetStorage storage;

  AuthRepository({required this.dio, required this.storage});

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['access_token'];
      final userData = response.data['user'];

      await saveToken(token);
      await storage.write('user', userData);
      
      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Erro ao realizar login';
      throw Exception(message);
    }
  }

  @override
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      final token = response.data['access_token'];
      final userData = response.data['user'];

      if (token != null) {
        await saveToken(token);
      }
      if (userData != null) {
        await storage.write('user', userData);
      }

      return response.data;
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Erro ao realizar cadastro.';
      throw Exception(message is List ? message.first : message);
    }
  }

  @override
  Future<void> saveToken(String token) async {
    await storage.write('token', token);
  }

  @override
  Future<String?> getToken() async {
    return storage.read('token');
  }

  @override
  Future<void> saveUser(UserEntity user) async {
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
  }

  @override
  UserEntity? getStoredUser() {
    final user = storage.read('user');
    if (user is! Map<String, dynamic>) {
      return null;
    }

    return UserModel.fromJson(user);
  }

  @override
  Future<void> logout() async {
    await storage.remove('token');
    await storage.remove('user');
  }
}
