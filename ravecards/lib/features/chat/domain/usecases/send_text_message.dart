// lib/features/chat/domain/usecases/send_text_message.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

@injectable
class SendTextMessage {
  final ChatRepository _repository;
  SendTextMessage(this._repository);

  Future<Either<Failure, Unit>> call(String linkId, String text) =>
      _repository.sendText(linkId, text);
}
