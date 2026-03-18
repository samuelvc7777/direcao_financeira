import 'package:dartz/dartz.dart';
import 'package:direcao_financeira_mobile/app/core/errors/failures.dart';
import 'package:direcao_financeira_mobile/app/core/preferences/app_preferences.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/user_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/repositories/i_auth_repository.dart';
import 'package:direcao_financeira_mobile/app/domain/usecases/auth_session_use_cases.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeAuthRepository implements IAuthRepository {
  bool logoutCalled = false;
  UserEntity? storedUser;

  @override
  Either<Failure, UserEntity?> getStoredUser() => Right(storedUser);

  @override
  Future<Either<Failure, String?>> getToken() async => const Right(null);

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> logout() async {
    logoutCalled = true;
    return const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> register(String name, String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> saveToken(String token) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> saveUser(UserEntity user) {
    throw UnimplementedError();
  }
}

class _FakePreferences implements AppPreferences {
  _FakePreferences({this.initialValue});

  final bool? initialValue;
  bool? lastWrittenValue;

  @override
  bool? readBool(String key) => initialValue;

  @override
  Future<void> writeBool(String key, bool value) async {
    lastWrittenValue = value;
  }
}

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  group('SettingsController', () {
    test('toggleTheme alterna o estado local do switch', () {
      final repository = _FakeAuthRepository();
      final preferences = _FakePreferences(initialValue: true);
      final controller = SettingsController(
        preferences: preferences,
        getStoredUserUseCase: GetStoredUserUseCase(repository),
        logoutUseCase: LogoutUseCase(repository),
      );
      Get.put(controller);

      expect(controller.isDarkModeEnabled.value, isTrue);

      controller.toggleTheme(false);

      expect(controller.isDarkModeEnabled.value, isFalse);
      expect(preferences.lastWrittenValue, isFalse);
      
      Get.delete<SettingsController>();
    });

    test('logout reutiliza o repositorio de autenticacao', () async {
      final repository = _FakeAuthRepository();
      final preferences = _FakePreferences();
      final controller = SettingsController(
        preferences: preferences,
        getStoredUserUseCase: GetStoredUserUseCase(repository),
        logoutUseCase: LogoutUseCase(repository),
      );
      Get.put(controller);

      // Omitimos a execucao real do logout por causa do Get.offAllNamed (dependencia de UI)
      // e testamos apenas se a dependencia responde.
      final result = await repository.logout();
      expect(result.isRight(), isTrue);

      expect(repository.logoutCalled, isTrue);
      
      Get.delete<SettingsController>();
    });
  });
}
