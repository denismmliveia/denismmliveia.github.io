// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Envía OTP por SMS. Devuelve verificationId en Right.
  Future<Either<AuthFailure, String>> sendOtp(String phone);

  /// Verifica el código SMS. Devuelve el usuario en Right.
  Future<Either<AuthFailure, UserEntity>> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  /// Inicia sesión con Google. Devuelve el usuario en Right.
  Future<Either<AuthFailure, UserEntity>> signInWithGoogle();

  /// Cierra sesión.
  Future<Either<AuthFailure, Unit>> signOut();

  /// Stream del estado de autenticación. Null = no autenticado.
  Stream<UserEntity?> get authStateChanges;
}
