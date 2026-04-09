// lib/features/scan/domain/usecases/initiate_link.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/scan_result_entity.dart';
import '../repositories/scan_repository.dart';

@injectable
class InitiateLink {
  final ScanRepository _repository;
  InitiateLink(this._repository);
  Future<Either<Failure, InitiateLinkResult>> call(String token) =>
      _repository.initiateLink(token);
}
