// lib/features/auth/domain/usecases/send_otp.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class SendOtp {
  final AuthRepository _repository;
  SendOtp(this._repository);

  Future<Either<AuthFailure, String>> call(String phone) =>
      _repository.sendOtp(phone);
}
