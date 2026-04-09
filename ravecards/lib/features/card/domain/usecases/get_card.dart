// lib/features/card/domain/usecases/get_card.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/card_entity.dart';
import '../repositories/card_repository.dart';

@injectable
class GetCard {
  final CardRepository _repository;
  GetCard(this._repository);

  Future<Either<CardFailure, CardEntity>> call(String uid) =>
      _repository.getCard(uid);
}
