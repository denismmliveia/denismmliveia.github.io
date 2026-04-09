// lib/features/moderation/domain/usecases/revoke_link.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/moderation_repository.dart';

@injectable
class RevokeLink {
  final ModerationRepository _repo;
  RevokeLink(this._repo);
  Future<Either<ModerationFailure, void>> call(String linkId) =>
      _repo.revokeLink(linkId);
}
