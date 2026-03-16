import '../entities/user_entity.dart';

abstract class IAuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<Map<String, dynamic>> register(String name, String email, String password);
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUser(UserEntity user);
  UserEntity? getStoredUser();
  Future<void> logout();
}
