import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/watch_messages.dart';
import '../../domain/usecases/send_text_message.dart';
import '../../domain/usecases/send_photo_message.dart';
import '../../domain/usecases/request_photo_view.dart';
import '../../domain/usecases/get_other_user_profile.dart';
import '../../../link/domain/usecases/watch_link.dart';
import 'chat_state.dart';

@injectable
class ChatCubit extends Cubit<ChatState> {
  final WatchMessages _watchMessages;
  final SendTextMessage _sendText;
  final SendPhotoMessage _sendPhoto;
  final RequestPhotoView _requestView;
  final GetOtherUserProfile _getOtherUserProfile;
  final WatchLink _watchLink;
  final FirebaseAuth _auth;

  StreamSubscription<dynamic>? _messagesSubscription;
  StreamSubscription<dynamic>? _linkSubscription;
  Timer? _photoTimer;

  ChatCubit({
    required WatchMessages watchMessages,
    required SendTextMessage sendText,
    required SendPhotoMessage sendPhoto,
    required RequestPhotoView requestView,
    required GetOtherUserProfile getOtherUserProfile,
    required WatchLink watchLink,
    required FirebaseAuth auth,
  })  : _watchMessages = watchMessages,
        _sendText = sendText,
        _sendPhoto = sendPhoto,
        _requestView = requestView,
        _getOtherUserProfile = getOtherUserProfile,
        _watchLink = watchLink,
        _auth = auth,
        super(const ChatState());

  String get currentUid => _auth.currentUser?.uid ?? '';

  void init(String linkId, {required String otherUid}) {
    _getOtherUserProfile(otherUid).then((result) {
      if (isClosed) return;
      result.fold(
        (_) {},
        (profile) => emit(state.copyWith(
          otherUserName: profile['displayName'],
          otherUserPhotoUrl: profile['photoUrl'],
        )),
      );
    });

    _messagesSubscription = _watchMessages(linkId).listen((result) {
      result.fold(
        (failure) => emit(state.copyWith(errorMessage: failure.message)),
        (messages) => emit(state.copyWith(messages: messages)),
      );
    });

    _linkSubscription = _watchLink(linkId).listen((result) {
      result.fold(
        (_) {},
        (link) {
          if (link.isExpired || link.isRevoked) {
            emit(state.copyWith(isLinkExpired: true));
          }
        },
      );
    });
  }

  Future<void> sendText(String linkId, String text) async {
    if (text.trim().isEmpty) return;
    emit(state.copyWith(actionStatus: ChatActionStatus.sendingText));
    final result = await _sendText(linkId, text.trim());
    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: ChatActionStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(actionStatus: ChatActionStatus.idle)),
    );
  }

  Future<void> sendPhoto(String linkId, Uint8List imageBytes) async {
    emit(state.copyWith(actionStatus: ChatActionStatus.uploadingPhoto));
    final result = await _sendPhoto(linkId, imageBytes);
    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: ChatActionStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(actionStatus: ChatActionStatus.idle)),
    );
  }

  Future<void> requestPhotoView(String linkId, String msgId) async {
    final result = await _requestView(linkId, msgId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (viewUrl) {
        emit(state.copyWith(
          actionStatus: ChatActionStatus.viewingPhoto,
          viewingPhotoUrl: viewUrl,
        ));
        _photoTimer?.cancel();
        _photoTimer = Timer(const Duration(seconds: 5), dismissPhoto);
      },
    );
  }

  void dismissPhoto() {
    _photoTimer?.cancel();
    emit(state.copyWith(
      actionStatus: ChatActionStatus.idle,
      viewingPhotoUrl: null,
    ));
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _linkSubscription?.cancel();
    _photoTimer?.cancel();
    return super.close();
  }
}
