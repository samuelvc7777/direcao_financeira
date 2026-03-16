import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> execute(String email, String password) async {
    // Aqui podemos adicionar validações de regra de negócio antes do login
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Por favor, informe um e-mail válido.');
    }
    if (password.length < 6) {
      throw Exception('A senha deve ter pelo menos 6 caracteres.');
    }

    return await repository.login(email, password);
  }
}
