// lib/features/auth/domain/usecases/get_auth_state.dart
import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class GetAuthState {
  final AuthRepository _repository;
  GetAuthState(this._repository);

  Stream<UserEntity?> call() => _repository.authStateChanges;
}
