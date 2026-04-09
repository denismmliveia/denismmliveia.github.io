// lib/features/link/domain/repositories/link_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/link_entity.dart';

abstract class LinkRepository {
  /// Streams all PENDING or LINKED links where the user is userA or userB.
  Stream<Either<Failure, List<LinkEntity>>> watchMyLinks(String uid);

  /// Streams a single link document by id.
  Stream<Either<Failure, LinkEntity>> watchLink(String linkId);
}
