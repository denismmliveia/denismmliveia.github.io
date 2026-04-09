// lib/features/auth/domain/usecases/sign_in_with_google.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignInWithGoogle {
  final AuthRepository _repository;
  SignInWithGoogle(this._repository);

  Future<Either<AuthFailure, UserEntity>> call() => _repository.signInWithGoogle();
}
