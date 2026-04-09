// lib/features/auth/domain/usecases/verify_otp.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpParams {
  final String verificationId;
  final String smsCode;
  const VerifyOtpParams({required this.verificationId, required this.smsCode});
}

@injectable
class VerifyOtp {
  final AuthRepository _repository;
  VerifyOtp(this._repository);

  Future<Either<AuthFailure, UserEntity>> call(VerifyOtpParams params) =>
      _repository.verifyOtp(
        verificationId: params.verificationId,
        smsCode: params.smsCode,
      );
}
