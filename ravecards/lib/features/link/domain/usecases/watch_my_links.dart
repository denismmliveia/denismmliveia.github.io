// lib/features/link/domain/usecases/watch_my_links.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/link_entity.dart';
import '../repositories/link_repository.dart';

@injectable
class WatchMyLinks {
  final LinkRepository _repository;
  WatchMyLinks(this._repository);

  Stream<Either<Failure, List<LinkEntity>>> call(String uid) =>
      _repository.watchMyLinks(uid);
}
