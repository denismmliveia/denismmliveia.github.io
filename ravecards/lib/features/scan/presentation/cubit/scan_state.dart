// lib/features/scan/presentation/cubit/scan_state.dart
import 'package:equatable/equatable.dart';
import '../../../../features/card/domain/entities/card_entity.dart';

abstract class ScanState extends Equatable {
  const ScanState();
  @override
  List<Object?> get props => [];
}

class ScanInitial extends ScanState {
  const ScanInitial();
}

/// QR decoded, calling validateQrToken + previewCard
class ScanValidating extends ScanState {
  const ScanValidating();
}

/// Preview screen: shows other user's card before confirming
class ScanPreview extends ScanState {
  final CardEntity otherCard;
  final String token; // preserved to call initiateLink later
  const ScanPreview({required this.otherCard, required this.token});
  @override
  List<Object?> get props => [otherCard, token];
}

/// Calling initiateLink
class ScanInitiating extends ScanState {
  final CardEntity otherCard;
  const ScanInitiating({required this.otherCard});
  @override
  List<Object?> get props => [otherCard];
}

/// Waiting for mutual scan — countdown ticks via [onCountdownTick]
class ScanPending extends ScanState {
  final String linkId;
  final CardEntity otherCard;
  final int remainingSeconds;
  const ScanPending({
    required this.linkId,
    required this.otherCard,
    required this.remainingSeconds,
  });
  @override
  List<Object?> get props => [linkId, otherCard, remainingSeconds];
}

/// Mutual scan detected — show duration picker (isConfirmer) or "¡Enlazado!" (!isConfirmer)
class ScanLinked extends ScanState {
  final String linkId;
  final CardEntity otherCard;
  /// True if THIS user completed the mutual scan (they see the duration picker).
  final bool isConfirmer;
  const ScanLinked({
    required this.linkId,
    required this.otherCard,
    required this.isConfirmer,
  });
  @override
  List<Object?> get props => [linkId, otherCard, isConfirmer];
}

/// Calling confirmLink
class ScanConfirming extends ScanState {
  final String linkId;
  const ScanConfirming({required this.linkId});
  @override
  List<Object?> get props => [linkId];
}

/// confirmLink succeeded — navigate to links tab
class ScanConfirmed extends ScanState {
  final String linkId;
  const ScanConfirmed({required this.linkId});
  @override
  List<Object?> get props => [linkId];
}

class ScanError extends ScanState {
  final String message;
  const ScanError(this.message);
  @override
  List<Object?> get props => [message];
}
