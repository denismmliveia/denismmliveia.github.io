// lib/features/card/domain/usecases/create_card.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/card_entity.dart';
import '../repositories/card_repository.dart';

class CreateCardParams {
  final String uid;
  final String displayName;
  final File photo;
  final String genre;
  final String orientation;
  final String relationshipStatus;
  final String favoriteTheme;

  const CreateCardParams({
    required this.uid,
    required this.displayName,
    required this.photo,
    required this.genre,
    required this.orientation,
    required this.relationshipStatus,
    required this.favoriteTheme,
  });
}

@injectable
class CreateCard {
  final CardRepository _repository;
  CreateCard(this._repository);

  Future<Either<CardFailure, CardEntity>> call(CreateCardParams params) =>
      _repository.createCard(
        uid: params.uid,
        displayName: params.displayName,
        photo: params.photo,
        genre: params.genre,
        orientation: params.orientation,
        relationshipStatus: params.relationshipStatus,
        favoriteTheme: params.favoriteTheme,
      );
}
