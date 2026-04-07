// lib/features/card/presentation/cubit/card_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/create_card.dart';
import '../../domain/usecases/get_card.dart';
import '../../domain/usecases/refresh_qr_token.dart';
import 'card_state.dart';

export '../../domain/usecases/create_card.dart' show CreateCardParams;

@injectable
class CardCubit extends Cubit<CardState> {
  final GetCard _getCard;
  final CreateCard _createCard;
  final RefreshQrToken _refreshQrToken;
  Timer? _qrRefreshTimer;

  CardCubit({
    required GetCard getCard,
    required CreateCard createCard,
    required RefreshQrToken refreshQrToken,
  })  : _getCard = getCard,
        _createCard = createCard,
        _refreshQrToken = refreshQrToken,
        super(CardInitial());

  Future<void> createCard(CreateCardParams params) async {
    emit(CardCreating());
    final result = await _createCard(params);
    result.fold(
      (failure) => emit(CardError(failure.message)),
      (card) {
        emit(CardLoaded(card));
        _scheduleQrRefresh(params.uid);
      },
    );
  }

  Future<void> loadCard(String uid) async {
    emit(CardLoading());
    final result = await _getCard(uid);
    result.fold(
      (failure) => emit(CardError(failure.message)),
      (card) {
        emit(CardLoaded(card));
        _scheduleQrRefresh(uid);
      },
    );
  }

  Future<void> refreshQr(String uid) async {
    final currentState = state;
    if (currentState is! CardLoaded) return;

    emit(CardQrRefreshing(currentState.card));
    final result = await _refreshQrToken(uid);
    result.fold(
      (failure) => emit(CardLoaded(currentState.card)), // fallback sin cambio
      (token) {
        final updatedCard = currentState.card.copyWith(
          activeQrToken: token,
        );
        emit(CardLoaded(updatedCard));
        _scheduleQrRefresh(uid);
      },
    );
  }

  void _scheduleQrRefresh(String uid) {
    _qrRefreshTimer?.cancel();
    // Refrescar 60s antes de que expire (TTL 5min → refrescar a los 4min)
    _qrRefreshTimer = Timer(const Duration(minutes: 4), () => refreshQr(uid));
  }

  @override
  Future<void> close() {
    _qrRefreshTimer?.cancel();
    return super.close();
  }
}
