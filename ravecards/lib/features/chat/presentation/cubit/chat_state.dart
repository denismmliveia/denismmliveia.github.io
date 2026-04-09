import 'package:equatable/equatable.dart';
import '../../domain/entities/message_entity.dart';

enum ChatActionStatus { idle, sendingText, uploadingPhoto, viewingPhoto, error }

class ChatState extends Equatable {
  final List<MessageEntity> messages;
  final bool isLinkExpired;
  final ChatActionStatus actionStatus;
  final String? viewingPhotoUrl;
  final String? errorMessage;
  final String? otherUserName;
  final String? otherUserPhotoUrl;

  const ChatState({
    this.messages = const [],
    this.isLinkExpired = false,
    this.actionStatus = ChatActionStatus.idle,
    this.viewingPhotoUrl,
    this.errorMessage,
    this.otherUserName,
    this.otherUserPhotoUrl,
  });

  ChatState copyWith({
    List<MessageEntity>? messages,
    bool? isLinkExpired,
    ChatActionStatus? actionStatus,
    Object? viewingPhotoUrl = _sentinel,
    Object? errorMessage = _sentinel,
    String? otherUserName,
    String? otherUserPhotoUrl,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLinkExpired: isLinkExpired ?? this.isLinkExpired,
      actionStatus: actionStatus ?? this.actionStatus,
      viewingPhotoUrl: viewingPhotoUrl == _sentinel
          ? this.viewingPhotoUrl
          : viewingPhotoUrl as String?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserPhotoUrl: otherUserPhotoUrl ?? this.otherUserPhotoUrl,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isLinkExpired,
        actionStatus,
        viewingPhotoUrl,
        errorMessage,
        otherUserName,
        otherUserPhotoUrl,
      ];
}

const _sentinel = Object();
