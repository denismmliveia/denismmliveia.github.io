import 'package:equatable/equatable.dart';

enum MessageType { text, photoOnce }

class MessageEntity extends Equatable {
  final String id;
  final MessageType type;
  final String senderId;
  final String? text;
  final String? photoRef;
  final List<String> viewedBy;
  final bool deletedFromStorage;
  final DateTime? createdAt;

  const MessageEntity({
    required this.id,
    required this.type,
    required this.senderId,
    this.text,
    this.photoRef,
    this.viewedBy = const [],
    this.deletedFromStorage = false,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        senderId,
        text,
        photoRef,
        viewedBy,
        deletedFromStorage,
        createdAt,
      ];
}
