import 'package:direcao_financeira_mobile/app/domain/entities/user_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/repositories/i_auth_repository.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/settings/settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements IAuthRepository {
  bool logoutCalled = false;
  UserEntity? storedUser;

  @override
  UserEntity? getStoredUser() => storedUser;

  @override
  Future<String?> getToken() async => null;

  @override
  Future<UserEntity> login(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  Future<Map<String, dynamic>> register(String name, String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveToken(String token) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveUser(UserEntity user) {
    throw UnimplementedError();
  }
}

void main() {
  group('SettingsController', () {
    test('toggleTheme alterna o estado local do switch', () {
      final repository = _FakeAuthRepository();
      final controller = SettingsController(authRepository: repository);

      expect(controller.isDarkModeEnabled.value, isTrue);

      controller.toggleTheme(false);

      expect(controller.isDarkModeEnabled.value, isFalse);
    });

    test('logout reutiliza o repositorio de autenticacao', () async {
      final repository = _FakeAuthRepository();
      final controller = SettingsController(authRepository: repository);

      await controller.logout();

      expect(repository.logoutCalled, isTrue);
    });
  });
}
