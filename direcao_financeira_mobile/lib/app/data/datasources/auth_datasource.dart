import '../dtos/auth_session_dto.dart';

abstract class IAuthRemoteDataSource {
  Future<AuthSessionDto> login({
    required String email,
    required String password,
  });

  Future<AuthSessionDto> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> updatePassword({required String password});
}
