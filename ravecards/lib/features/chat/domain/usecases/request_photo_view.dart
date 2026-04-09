// lib/features/chat/domain/usecases/request_photo_view.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

@injectable
class RequestPhotoView {
  final ChatRepository _repository;
  RequestPhotoView(this._repository);

  Future<Either<Failure, String>> call(String linkId, String msgId) =>
      _repository.requestPhotoView(linkId, msgId);
}
