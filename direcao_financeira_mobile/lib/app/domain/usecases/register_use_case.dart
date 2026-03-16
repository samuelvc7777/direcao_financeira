import '../repositories/i_auth_repository.dart';

class RegisterUseCase {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Map<String, dynamic>> execute(String name, String email, String password) async {
    // Validações básicas de negócio
    if (name.trim().isEmpty) {
      throw Exception('O nome é obrigatório.');
    }

    // Regex para e-mail
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw Exception('Informe um e-mail válido.');
    }

    // Regex para força da senha (conforme backend NestJS atualizado)
    // 8 chars, 1 upper, 1 lower, 1 special
    final passwordRegex = RegExp(r'(?=.*\W+)(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$');
    
    if (password.length < 8) {
      throw Exception('A senha deve ter no mínimo 8 caracteres.');
    }
    
    if (!passwordRegex.hasMatch(password)) {
      throw Exception('Senha fraca! Use maiúsculas, minúsculas e símbolos.');
    }

    return await repository.register(name, email, password);
  }
}
