// lib/features/memories/data/repositories/memory_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/memory_entity.dart';
import '../../domain/repositories/memory_repository.dart';
import '../models/memory_model.dart';

@LazySingleton(as: MemoryRepository)
class MemoryRepositoryImpl implements MemoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MemoryRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  @override
  Stream<Either<MemoryFailure, List<MemoryEntity>>> watchMemories() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value(const Left(MemoryFailure('No authenticated user')));
    }

    return _firestore
        .collection('memories')
        .doc(uid)
        .collection('cards')
        .orderBy('endedAt', descending: true)
        .snapshots()
        .map<Either<MemoryFailure, List<MemoryEntity>>>((snap) {
      final memories = snap.docs
          .map((doc) => MemoryModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
      return Right(memories);
    }).handleError((e) => Left(MemoryFailure(e.toString())));
  }
}
