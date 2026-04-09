// lib/features/chat/domain/repositories/chat_repository.dart
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  /// Streams all messages for a given link.
  Stream<Either<Failure, List<MessageEntity>>> watchMessages(String linkId);

  /// Sends a text message to a link.
  Future<Either<Failure, Unit>> sendText(String linkId, String text);

  /// Sends a photo message to a link.
  Future<Either<Failure, Unit>> sendPhoto(String linkId, Uint8List imageBytes);

  /// Requests a view token for a photo message (ephemeral access).
  Future<Either<Failure, String>> requestPhotoView(String linkId, String msgId);

  /// Gets the other user's profile (displayName, photoUrl, etc.)
  Future<Either<Failure, Map<String, String?>>> getOtherUserProfile(String uid);
}
