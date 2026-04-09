// lib/features/auth/presentation/cubit/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/verify_otp.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final SendOtp _sendOtp;
  final VerifyOtp _verifyOtp;
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;

  AuthCubit({
    required SendOtp sendOtp,
    required VerifyOtp verifyOtp,
    required SignInWithGoogle signInWithGoogle,
    required SignOut signOut,
  })  : _sendOtp = sendOtp,
        _verifyOtp = verifyOtp,
        _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        super(AuthInitial());

  Future<void> sendOtp(String phone) async {
    emit(AuthLoading());
    final result = await _sendOtp(phone);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (verificationId) => emit(AuthOtpSent(verificationId)),
    );
  }

  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    emit(AuthLoading());
    final result = await _verifyOtp(
      VerifyOtpParams(verificationId: verificationId, smsCode: smsCode),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    final result = await _signInWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> signOut() async {
    await _signOut();
    emit(AuthUnauthenticated());
  }
}
