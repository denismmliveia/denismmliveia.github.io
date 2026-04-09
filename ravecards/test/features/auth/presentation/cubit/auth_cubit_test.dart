// test/features/auth/presentation/cubit/auth_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ravecards/core/error/failures.dart';
import 'package:ravecards/features/auth/domain/entities/user_entity.dart';
import 'package:ravecards/features/auth/domain/usecases/send_otp.dart';
import 'package:ravecards/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:ravecards/features/auth/domain/usecases/sign_out.dart';
import 'package:ravecards/features/auth/domain/usecases/verify_otp.dart';
import 'package:ravecards/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ravecards/features/auth/presentation/cubit/auth_state.dart';

import 'auth_cubit_test.mocks.dart';

@GenerateMocks([SendOtp, VerifyOtp, SignInWithGoogle, SignOut])
void main() {
  late AuthCubit cubit;
  late MockSendOtp mockSendOtp;
  late MockVerifyOtp mockVerifyOtp;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignOut mockSignOut;

  setUp(() {
    mockSendOtp = MockSendOtp();
    mockVerifyOtp = MockVerifyOtp();
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignOut = MockSignOut();
    cubit = AuthCubit(
      sendOtp: mockSendOtp,
      verifyOtp: mockVerifyOtp,
      signInWithGoogle: mockSignInWithGoogle,
      signOut: mockSignOut,
    );
  });

  tearDown(() => cubit.close());

  group('sendOtp', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthOtpSent] when sendOtp succeeds',
      build: () {
        when(mockSendOtp(any)).thenAnswer((_) async => const Right('ver-id'));
        return cubit;
      },
      act: (c) => c.sendOtp('+34600000000'),
      expect: () => [AuthLoading(), const AuthOtpSent('ver-id')],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] when sendOtp fails',
      build: () {
        when(mockSendOtp(any))
            .thenAnswer((_) async => const Left(AuthFailure('Número inválido')));
        return cubit;
      },
      act: (c) => c.sendOtp('+34600000000'),
      expect: () => [AuthLoading(), const AuthError('Número inválido')],
    );
  });

  group('verifyOtp', () {
    const tUser = UserEntity(uid: 'uid-123', phone: '+34600000000');

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when verifyOtp succeeds',
      build: () {
        when(mockVerifyOtp(any)).thenAnswer((_) async => const Right(tUser));
        return cubit;
      },
      act: (c) => c.verifyOtp(verificationId: 'ver-id', smsCode: '123456'),
      expect: () => [AuthLoading(), const AuthAuthenticated(tUser)],
    );
  });

  group('signInWithGoogle', () {
    const tUser = UserEntity(uid: 'uid-456', email: 'test@gmail.com');

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when Google sign-in succeeds',
      build: () {
        when(mockSignInWithGoogle()).thenAnswer((_) async => const Right(tUser));
        return cubit;
      },
      act: (c) => c.signInWithGoogle(),
      expect: () => [AuthLoading(), const AuthAuthenticated(tUser)],
    );
  });
}
