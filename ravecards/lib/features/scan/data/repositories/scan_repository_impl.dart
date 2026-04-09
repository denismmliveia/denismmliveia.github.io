// lib/features/scan/data/repositories/scan_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../card/data/models/card_model.dart';
import '../../../card/domain/entities/card_entity.dart';
import '../../domain/entities/scan_result_entity.dart';
import '../../domain/repositories/scan_repository.dart';

@LazySingleton(as: ScanRepository)
class ScanRepositoryImpl implements ScanRepository {
  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;

  ScanRepositoryImpl(this._functions, this._firestore);

  @override
  Future<Either<Failure, String>> validateQrToken(String token) async {
    try {
      final result = await _functions
          .httpsCallable('validateQrToken')
          .call({'token': token});
      final data = result.data as Map<String, dynamic>;
      if (data['valid'] != true) {
        return const Left(ScanFailure('QR inválido o expirado'));
      }
      return Right(data['uid'] as String);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CardEntity>> previewCard(String uid) async {
    try {
      final snap = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (!snap.exists) {
        return const Left(ScanFailure('Usuario no encontrado'));
      }
      return Right(CardModel.fromSnapshot(snap));
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InitiateLinkResult>> initiateLink(String token) async {
    try {
      final result = await _functions
          .httpsCallable('initiateLink')
          .call({'token': token});
      final data = result.data as Map<String, dynamic>;
      return Right(InitiateLinkResult(
        linkId: data['linkId'] as String,
        isMutual: data['isMutual'] as bool,
      ));
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmLink(
      String linkId, int durationHours) async {
    try {
      await _functions
          .httpsCallable('confirmLink')
          .call({'linkId': linkId, 'duration': durationHours});
      return const Right(unit);
    } catch (e) {
      return Left(ScanFailure(e.toString()));
    }
  }
}
