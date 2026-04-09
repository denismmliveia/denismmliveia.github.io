// lib/features/card/data/repositories/card_repository_impl.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/card_repository.dart';
import '../models/card_model.dart';

@LazySingleton(as: CardRepository)
class CardRepositoryImpl implements CardRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseFunctions _functions;

  CardRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required FirebaseFunctions functions,
  })  : _firestore = firestore,
        _storage = storage,
        _functions = functions;

  @override
  Future<Either<CardFailure, CardEntity>> getCard(String uid) async {
    try {
      final snap = await _firestore.collection('users').doc(uid).get();
      if (!snap.exists) return const Left(CardFailure('Tarjeta no encontrada'));
      return Right(CardModel.fromSnapshot(snap));
    } catch (e) {
      return Left(CardFailure(e.toString()));
    }
  }

  @override
  Future<Either<CardFailure, CardEntity>> createCard({
    required String uid,
    required String displayName,
    required File photo,
    required String genre,
    required String orientation,
    required String relationshipStatus,
    required String favoriteTheme,
  }) async {
    try {
      // 1. Subir foto a Storage
      final ref = _storage.ref('profiles/$uid/avatar.jpg');
      await ref.putFile(photo, SettableMetadata(contentType: 'image/jpeg'));
      final photoUrl = await ref.getDownloadURL();

      // 2. Guardar tarjeta en Firestore
      final data = {
        'displayName': displayName,
        'photoUrl': photoUrl,
        'genre': genre,
        'orientation': orientation,
        'relationshipStatus': relationshipStatus,
        'favoriteTheme': favoriteTheme,
        'hasCard': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));

      final card = CardModel(
        uid: uid,
        displayName: displayName,
        photoUrl: photoUrl,
        genre: genre,
        orientation: orientation,
        relationshipStatus: relationshipStatus,
        favoriteTheme: favoriteTheme,
      );

      return Right(card);
    } catch (e) {
      return Left(CardFailure(e.toString()));
    }
  }

  @override
  Future<Either<CardFailure, String>> refreshQrToken(String uid) async {
    try {
      final callable = _functions.httpsCallable('generateQrToken');
      final result = await callable.call<Map<String, dynamic>>();
      final token = result.data['token'] as String;
      return Right(token);
    } catch (e) {
      return Left(CardFailure('No se pudo refrescar el QR: ${e.toString()}'));
    }
  }

  @override
  Stream<CardEntity?> watchCard(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return CardModel.fromSnapshot(snap);
    });
  }
}
