// lib/features/chat/domain/usecases/get_other_user_profile.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

@injectable
class GetOtherUserProfile {
  final ChatRepository _repository;
  GetOtherUserProfile(this._repository);

  Future<Either<Failure, Map<String, String?>>> call(String uid) =>
      _repository.getOtherUserProfile(uid);
}
