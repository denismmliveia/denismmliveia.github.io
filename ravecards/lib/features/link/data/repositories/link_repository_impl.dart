// lib/features/link/data/repositories/link_repository_impl.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/link_entity.dart';
import '../../domain/repositories/link_repository.dart';
import '../models/link_model.dart';

@LazySingleton(as: LinkRepository)
class LinkRepositoryImpl implements LinkRepository {
  final FirebaseFirestore _firestore;
  LinkRepositoryImpl(this._firestore);

  static const _activeStatuses = ['pending', 'linked'];

  @override
  Stream<Either<Failure, List<LinkEntity>>> watchMyLinks(String uid) {
    final controller =
        StreamController<Either<Failure, List<LinkEntity>>>.broadcast();
    final List<LinkEntity> listA = [];
    final List<LinkEntity> listB = [];

    // Emit on every update from either query (not combineLatest semantics).
    // The list may be partial until both queries have fired at least once.
    void emit() => controller.add(Right([...listA, ...listB]));

    final subA = _firestore
        .collection('links')
        .where('userA', isEqualTo: uid)
        .where('status', whereIn: _activeStatuses)
        .snapshots()
        .listen(
          (snap) {
            listA
              ..clear()
              ..addAll(snap.docs.map(LinkModel.fromFirestore));
            emit();
          },
          onError: (e) => controller.add(Left(LinkFailure(e.toString()))),
        );

    final subB = _firestore
        .collection('links')
        .where('userB', isEqualTo: uid)
        .where('status', whereIn: _activeStatuses)
        .snapshots()
        .listen(
          (snap) {
            listB
              ..clear()
              ..addAll(snap.docs.map(LinkModel.fromFirestore));
            emit();
          },
          onError: (e) => controller.add(Left(LinkFailure(e.toString()))),
        );

    controller.onCancel = () {
      subA.cancel();
      subB.cancel();
    };
    return controller.stream;
  }

  @override
  Stream<Either<Failure, LinkEntity>> watchLink(String linkId) {
    return _firestore
        .collection('links')
        .doc(linkId)
        .snapshots()
        .map<Either<Failure, LinkEntity>>((doc) {
          if (!doc.exists) {
            return const Left(LinkFailure('Link not found'));
          }
          return Right(LinkModel.fromFirestore(doc));
        })
        .handleError(
          (e) => Left<Failure, LinkEntity>(LinkFailure(e.toString())),
        );
  }
}
