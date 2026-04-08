// lib/features/scan/domain/entities/scan_result_entity.dart
import 'package:equatable/equatable.dart';

/// Returned by the initiateLink Cloud Function.
class InitiateLinkResult extends Equatable {
  final String linkId;

  /// True when this scan completed a mutual exchange (B scanned A who already has PENDING for B).
  final bool isMutual;

  const InitiateLinkResult({required this.linkId, required this.isMutual});

  @override
  List<Object> get props => [linkId, isMutual];
}
