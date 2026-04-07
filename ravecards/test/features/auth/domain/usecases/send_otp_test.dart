// test/features/auth/domain/usecases/send_otp_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ravecards/core/error/failures.dart';
import 'package:ravecards/features/auth/domain/repositories/auth_repository.dart';
import 'package:ravecards/features/auth/domain/usecases/send_otp.dart';

import 'send_otp_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SendOtp usecase;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    usecase = SendOtp(mockRepo);
  });

  const tPhone = '+34600000000';
  const tVerificationId = 'test-verification-id';

  test('should call repository.sendOtp and return verificationId on success', () async {
    when(mockRepo.sendOtp(any)).thenAnswer((_) async => const Right(tVerificationId));

    final result = await usecase(tPhone);

    expect(result, const Right(tVerificationId));
    verify(mockRepo.sendOtp(tPhone));
    verifyNoMoreInteractions(mockRepo);
  });

  test('should return AuthFailure when repository fails', () async {
    when(mockRepo.sendOtp(any))
        .thenAnswer((_) async => const Left(AuthFailure('Invalid phone')));

    final result = await usecase(tPhone);

    expect(result, const Left(AuthFailure('Invalid phone')));
  });
}
