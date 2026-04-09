// lib/features/scan/domain/repositories/scan_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../card/domain/entities/card_entity.dart';
import '../entities/scan_result_entity.dart';

abstract class ScanRepository {
  /// Calls the existing validateQrToken Cloud Function.
  /// Returns the target user uid if valid.
  Future<Either<Failure, String>> validateQrToken(String token);

  /// Reads the target user's card from Firestore for the preview screen.
  Future<Either<Failure, CardEntity>> previewCard(String uid);

  /// Calls the initiateLink Cloud Function.
  /// Creates a PENDING link or detects mutual scan (isMutual: true).
  Future<Either<Failure, InitiateLinkResult>> initiateLink(String token);

  /// Calls the confirmLink Cloud Function.
  /// Transitions PENDING → LINKED with the chosen duration in hours.
  /// Valid durations: 4, 12, 24, 72.
  Future<Either<Failure, Unit>> confirmLink(String linkId, int durationHours);
}
