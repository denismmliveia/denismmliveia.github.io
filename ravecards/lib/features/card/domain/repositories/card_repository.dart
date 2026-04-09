// lib/features/card/domain/repositories/card_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/card_entity.dart';

abstract class CardRepository {
  Future<Either<CardFailure, CardEntity>> getCard(String uid);
  Future<Either<CardFailure, CardEntity>> createCard({
    required String uid,
    required String displayName,
    required File photo,
    required String genre,
    required String orientation,
    required String relationshipStatus,
    required String favoriteTheme,
  });
  Future<Either<CardFailure, String>> refreshQrToken(String uid);
  Stream<CardEntity?> watchCard(String uid);
}
