// lib/features/scan/domain/usecases/validate_qr_token.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/scan_repository.dart';

@injectable
class ValidateQrToken {
  final ScanRepository _repository;
  ValidateQrToken(this._repository);
  Future<Either<Failure, String>> call(String token) =>
      _repository.validateQrToken(token);
}
