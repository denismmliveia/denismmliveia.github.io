// lib/features/scan/domain/usecases/confirm_link.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/scan_repository.dart';

@injectable
class ConfirmLink {
  final ScanRepository _repository;
  ConfirmLink(this._repository);
  Future<Either<Failure, Unit>> call(String linkId, int durationHours) =>
      _repository.confirmLink(linkId, durationHours);
}
