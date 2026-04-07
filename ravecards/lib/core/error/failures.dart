// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object> get props => [message];
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class CardFailure extends Failure {
  const CardFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('Sin conexión a internet');
}
