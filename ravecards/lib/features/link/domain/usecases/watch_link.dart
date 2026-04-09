// lib/features/link/domain/usecases/watch_link.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/link_entity.dart';
import '../repositories/link_repository.dart';

@injectable
class WatchLink {
  final LinkRepository _repository;
  WatchLink(this._repository);

  Stream<Either<Failure, LinkEntity>> call(String linkId) =>
      _repository.watchLink(linkId);
}
