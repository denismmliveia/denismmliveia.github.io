// lib/features/card/presentation/cubit/card_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/card_entity.dart';

abstract class CardState extends Equatable {
  const CardState();
  @override
  List<Object?> get props => [];
}

class CardInitial extends CardState {}
class CardLoading extends CardState {}

class CardLoaded extends CardState {
  final CardEntity card;
  const CardLoaded(this.card);
  @override
  List<Object?> get props => [card];
}

class CardNotFound extends CardState {}
class CardCreating extends CardState {}

class CardError extends CardState {
  final String message;
  const CardError(this.message);
  @override
  List<Object?> get props => [message];
}

class CardQrRefreshing extends CardState {
  final CardEntity card;
  const CardQrRefreshing(this.card);
  @override
  List<Object?> get props => [card];
}
