// lib/features/card/domain/usecases/refresh_qr_token.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/card_repository.dart';

@injectable
class RefreshQrToken {
  final CardRepository _repository;
  RefreshQrToken(this._repository);

  Future<Either<CardFailure, String>> call(String uid) =>
      _repository.refreshQrToken(uid);
}
