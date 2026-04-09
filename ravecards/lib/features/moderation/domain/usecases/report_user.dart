// lib/features/moderation/domain/usecases/report_user.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/moderation_repository.dart';

@injectable
class ReportUser {
  final ModerationRepository _repo;
  ReportUser(this._repo);
  Future<Either<ModerationFailure, void>> call({
    required String targetUid,
    required String reason,
    String? linkId,
  }) =>
      _repo.reportUser(targetUid: targetUid, reason: reason, linkId: linkId);
}
