// lib/features/chat/domain/usecases/watch_messages.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

@injectable
class WatchMessages {
  final ChatRepository _repository;
  WatchMessages(this._repository);

  Stream<Either<Failure, List<MessageEntity>>> call(String linkId) =>
      _repository.watchMessages(linkId);
}
