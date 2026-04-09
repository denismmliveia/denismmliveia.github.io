// lib/features/scan/presentation/cubit/scan_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../features/card/domain/entities/card_entity.dart';
import '../../../../features/link/domain/entities/link_entity.dart';
import '../../../../features/link/domain/usecases/watch_link.dart';
import '../../domain/usecases/confirm_link.dart';
import '../../domain/usecases/initiate_link.dart';
import '../../domain/usecases/preview_card.dart';
import '../../domain/usecases/validate_qr_token.dart';
import 'scan_state.dart';

@injectable
class ScanCubit extends Cubit<ScanState> {
  final ValidateQrToken _validateQrToken;
  final PreviewCard _previewCard;
  final InitiateLink _initiateLink;
  final ConfirmLink _confirmLink;
  final WatchLink _watchLink;

  StreamSubscription<dynamic>? _linkSubscription;
  Timer? _countdownTimer;

  ScanCubit({
    required ValidateQrToken validateQrToken,
    required PreviewCard previewCard,
    required InitiateLink initiateLink,
    required ConfirmLink confirmLink,
    required WatchLink watchLink,
  })  : _validateQrToken = validateQrToken,
        _previewCard = previewCard,
        _initiateLink = initiateLink,
        _confirmLink = confirmLink,
        _watchLink = watchLink,
        super(const ScanInitial());

  /// Called when mobile_scanner decodes a QR code.
  Future<void> onQrScanned(String token) async {
    emit(const ScanValidating());

    final uidResult = await _validateQrToken(token);
    await uidResult.fold(
      (failure) async => emit(ScanError(failure.message)),
      (uid) async {
        final cardResult = await _previewCard(uid);
        cardResult.fold(
          (failure) => emit(ScanError(failure.message)),
          (card) => emit(ScanPreview(otherCard: card, token: token)),
        );
      },
    );
  }

  /// Called when user taps "Iniciar enlace" on the preview screen.
  Future<void> onInitiateLink(String token, CardEntity otherCard) async {
    emit(ScanInitiating(otherCard: otherCard));

    final result = await _initiateLink(token);
    result.fold(
      (failure) => emit(ScanError(failure.message)),
      (scanResult) {
        if (scanResult.isMutual) {
          _countdownTimer?.cancel();
          _linkSubscription?.cancel();
          emit(ScanLinked(
            linkId: scanResult.linkId,
            otherCard: otherCard,
            isConfirmer: true,
          ));
        } else {
          _startPending(scanResult.linkId, otherCard);
        }
      },
    );
  }

  void _startPending(String linkId, CardEntity otherCard) {
    emit(ScanPending(linkId: linkId, otherCard: otherCard, remainingSeconds: 60));

    // Watch Firestore for mutual scan from the other side
    _linkSubscription = _watchLink(linkId).listen((result) {
      result.fold(
        (_) {},
        (link) => onLinkStatusChanged(link),
      );
    });

    // Countdown timer — ticks every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      onCountdownTick();
    });
  }

  /// Called by the Firestore stream subscription and directly in tests.
  void onLinkStatusChanged(LinkEntity link) {
    final currentState = state;
    if (currentState is! ScanPending) return;
    if (link.isLinked) {
      _countdownTimer?.cancel();
      _linkSubscription?.cancel();
      emit(ScanLinked(
        linkId: currentState.linkId,
        otherCard: currentState.otherCard,
        isConfirmer: false, // other side already confirmed
      ));
    }
  }

  /// Called by the countdown timer and directly in tests.
  void onCountdownTick() {
    final currentState = state;
    if (currentState is! ScanPending) return;

    final newRemaining = currentState.remainingSeconds - 1;
    if (newRemaining <= 0) {
      _countdownTimer?.cancel();
      _linkSubscription?.cancel();
      emit(const ScanError('El tiempo se agotó. Pídele que te escanee de nuevo.'));
    } else {
      emit(ScanPending(
        linkId: currentState.linkId,
        otherCard: currentState.otherCard,
        remainingSeconds: newRemaining,
      ));
    }
  }

  /// Called when confirmer picks a duration on the ScanLinkedPage.
  Future<void> onConfirmLink(String linkId, int durationHours) async {
    emit(ScanConfirming(linkId: linkId));

    final result = await _confirmLink(linkId, durationHours);
    result.fold(
      (failure) => emit(ScanError(failure.message)),
      (_) => emit(ScanConfirmed(linkId: linkId)),
    );
  }

  @override
  Future<void> close() {
    _linkSubscription?.cancel();
    _countdownTimer?.cancel();
    return super.close();
  }
}
