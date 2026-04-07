// lib/features/auth/domain/usecases/sign_out.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignOut {
  final AuthRepository _repository;
  SignOut(this._repository);

  Future<Either<AuthFailure, Unit>> call() => _repository.signOut();
}
