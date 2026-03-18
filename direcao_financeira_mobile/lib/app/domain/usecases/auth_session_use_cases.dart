import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

class GetStoredUserUseCase {
  GetStoredUserUseCase(this._repository);

  final IAuthRepository _repository;

  Either<Failure, UserEntity?> call() => _repository.getStoredUser();
}

class LogoutUseCase {
  LogoutUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Either<Failure, void>> call() => _repository.logout();
}
