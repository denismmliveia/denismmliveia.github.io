// lib/features/link/presentation/cubit/links_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/link_entity.dart';

abstract class LinksState extends Equatable {
  const LinksState();
  @override
  List<Object?> get props => [];
}

class LinksInitial extends LinksState {
  const LinksInitial();
}

class LinksLoaded extends LinksState {
  final List<LinkEntity> links;
  const LinksLoaded(this.links);
  @override
  List<Object?> get props => [links];
}

class LinksError extends LinksState {
  final String message;
  const LinksError(this.message);
  @override
  List<Object?> get props => [message];
}
