// test/features/auth/domain/usecases/verify_otp_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ravecards/core/error/failures.dart';
import 'package:ravecards/features/auth/domain/entities/user_entity.dart';
import 'package:ravecards/features/auth/domain/repositories/auth_repository.dart';
import 'package:ravecards/features/auth/domain/usecases/verify_otp.dart';

import 'verify_otp_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late VerifyOtp usecase;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    usecase = VerifyOtp(mockRepo);
  });

  const tUser = UserEntity(uid: 'uid-123', phone: '+34600000000');
  const tParams = VerifyOtpParams(verificationId: 'ver-id', smsCode: '123456');

  test('should return UserEntity on successful verification', () async {
    when(mockRepo.verifyOtp(verificationId: anyNamed('verificationId'), smsCode: anyNamed('smsCode')))
        .thenAnswer((_) async => const Right(tUser));

    final result = await usecase(tParams);

    expect(result, const Right(tUser));
    verify(mockRepo.verifyOtp(verificationId: 'ver-id', smsCode: '123456'));
  });

  test('should return AuthFailure when code is wrong', () async {
    when(mockRepo.verifyOtp(verificationId: anyNamed('verificationId'), smsCode: anyNamed('smsCode')))
        .thenAnswer((_) async => const Left(AuthFailure('Código incorrecto')));

    final result = await usecase(tParams);

    expect(result, const Left(AuthFailure('Código incorrecto')));
  });
}
