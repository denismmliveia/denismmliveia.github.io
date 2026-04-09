// lib/features/chat/domain/usecases/send_photo_message.dart
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

@injectable
class SendPhotoMessage {
  final ChatRepository _repository;
  SendPhotoMessage(this._repository);

  Future<Either<Failure, Unit>> call(String linkId, Uint8List imageBytes) =>
      _repository.sendPhoto(linkId, imageBytes);
}
