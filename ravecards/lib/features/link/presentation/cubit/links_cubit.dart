// lib/features/link/presentation/cubit/links_cubit.dart
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/link_entity.dart';
import '../../domain/usecases/watch_my_links.dart';
import 'links_state.dart';

@injectable
class LinksCubit extends Cubit<LinksState> {
  final WatchMyLinks _watchMyLinks;
  StreamSubscription<Either<Failure, List<LinkEntity>>>? _subscription;

  LinksCubit({required WatchMyLinks watchMyLinks})
      : _watchMyLinks = watchMyLinks,
        super(const LinksInitial());

  void watchLinks(String uid) {
    _subscription?.cancel();
    _subscription = _watchMyLinks(uid).listen((result) {
      if (isClosed) return;
      result.fold(
        (failure) => emit(LinksError(failure.message)),
        (links) => emit(LinksLoaded(links)),
      );
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
