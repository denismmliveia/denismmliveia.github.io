import 'dart:async';
import 'dart:typed_data';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ravecards/core/error/failures.dart';
import 'package:ravecards/features/chat/domain/entities/message_entity.dart';
import 'package:ravecards/features/chat/domain/usecases/watch_messages.dart';
import 'package:ravecards/features/chat/domain/usecases/send_text_message.dart';
import 'package:ravecards/features/chat/domain/usecases/send_photo_message.dart';
import 'package:ravecards/features/chat/domain/usecases/request_photo_view.dart';
import 'package:ravecards/features/chat/domain/usecases/get_other_user_profile.dart';
import 'package:ravecards/features/link/domain/usecases/watch_link.dart';
import 'package:ravecards/features/link/domain/entities/link_entity.dart';
import 'package:ravecards/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:ravecards/features/chat/presentation/cubit/chat_state.dart';

class MockWatchMessages extends Mock implements WatchMessages {}
class MockSendTextMessage extends Mock implements SendTextMessage {}
class MockSendPhotoMessage extends Mock implements SendPhotoMessage {}
class MockRequestPhotoView extends Mock implements RequestPhotoView {}
class MockGetOtherUserProfile extends Mock implements GetOtherUserProfile {}
class MockWatchLink extends Mock implements WatchLink {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

ChatCubit _buildCubit({
  required MockWatchMessages watchMessages,
  required MockSendTextMessage sendText,
  required MockSendPhotoMessage sendPhoto,
  required MockRequestPhotoView requestView,
  required MockGetOtherUserProfile getProfile,
  required MockWatchLink watchLink,
  required MockFirebaseAuth auth,
}) =>
    ChatCubit(
      watchMessages: watchMessages,
      sendText: sendText,
      sendPhoto: sendPhoto,
      requestView: requestView,
      getOtherUserProfile: getProfile,
      watchLink: watchLink,
      auth: auth,
    );

void main() {
  late MockWatchMessages watchMessages;
  late MockSendTextMessage sendText;
  late MockSendPhotoMessage sendPhoto;
  late MockRequestPhotoView requestView;
  late MockGetOtherUserProfile getProfile;
  late MockWatchLink watchLink;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    watchMessages = MockWatchMessages();
    sendText = MockSendTextMessage();
    sendPhoto = MockSendPhotoMessage();
    requestView = MockRequestPhotoView();
    getProfile = MockGetOtherUserProfile();
    watchLink = MockWatchLink();
    auth = MockFirebaseAuth();
    user = MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('uid-alice');

    // Default: empty streams so init doesn't crash in tests that don't call it
    when(() => watchMessages(any()))
        .thenAnswer((_) => const Stream.empty());
    when(() => watchLink(any()))
        .thenAnswer((_) => const Stream.empty());
    when(() => getProfile(any()))
        .thenAnswer((_) async => const Right({'displayName': null, 'photoUrl': null}));
  });

  group('sendText', () {
    blocTest<ChatCubit, ChatState>(
      'emits sendingText then idle on success',
      build: () {
        when(() => sendText('link-1', 'Hola'))
            .thenAnswer((_) async => const Right(unit));
        return _buildCubit(
          watchMessages: watchMessages, sendText: sendText,
          sendPhoto: sendPhoto, requestView: requestView,
          getProfile: getProfile, watchLink: watchLink, auth: auth,
        );
      },
      act: (c) => c.sendText('link-1', 'Hola'),
      expect: () => [
        const ChatState(actionStatus: ChatActionStatus.sendingText),
        const ChatState(actionStatus: ChatActionStatus.idle),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'emits error state on failure',
      build: () {
        when(() => sendText('link-1', 'Hola'))
            .thenAnswer((_) async => Left(const ChatFailure('net error')));
        return _buildCubit(
          watchMessages: watchMessages, sendText: sendText,
          sendPhoto: sendPhoto, requestView: requestView,
          getProfile: getProfile, watchLink: watchLink, auth: auth,
        );
      },
      act: (c) => c.sendText('link-1', 'Hola'),
      expect: () => [
        const ChatState(actionStatus: ChatActionStatus.sendingText),
        const ChatState(actionStatus: ChatActionStatus.error, errorMessage: 'net error'),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'does nothing when text is empty',
      build: () => _buildCubit(
        watchMessages: watchMessages, sendText: sendText,
        sendPhoto: sendPhoto, requestView: requestView,
        getProfile: getProfile, watchLink: watchLink, auth: auth,
      ),
      act: (c) => c.sendText('link-1', '   '),
      expect: () => [],
    );
  });

  group('sendPhoto', () {
    blocTest<ChatCubit, ChatState>(
      'emits uploadingPhoto then idle on success',
      build: () {
        when(() => sendPhoto('link-1', any()))
            .thenAnswer((_) async => const Right(unit));
        return _buildCubit(
          watchMessages: watchMessages, sendText: sendText,
          sendPhoto: sendPhoto, requestView: requestView,
          getProfile: getProfile, watchLink: watchLink, auth: auth,
        );
      },
      act: (c) => c.sendPhoto('link-1', Uint8List.fromList([1, 2])),
      expect: () => [
        const ChatState(actionStatus: ChatActionStatus.uploadingPhoto),
        const ChatState(actionStatus: ChatActionStatus.idle),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'emits error state on failure',
      build: () {
        when(() => sendPhoto('link-1', any()))
            .thenAnswer((_) async => Left(const ChatFailure('upload error')));
        return _buildCubit(
          watchMessages: watchMessages, sendText: sendText,
          sendPhoto: sendPhoto, requestView: requestView,
          getProfile: getProfile, watchLink: watchLink, auth: auth,
        );
      },
      act: (c) => c.sendPhoto('link-1', Uint8List.fromList([1, 2])),
      expect: () => [
        const ChatState(actionStatus: ChatActionStatus.uploadingPhoto),
        const ChatState(actionStatus: ChatActionStatus.error, errorMessage: 'upload error'),
      ],
    );
  });

  group('requestPhotoView', () {
    blocTest<ChatCubit, ChatState>(
      'emits viewingPhoto with URL on success',
      build: () {
        when(() => requestView('link-1', 'msg-1'))
            .thenAnswer((_) async => const Right('https://example.com/photo.jpg'));
        return _buildCubit(
          watchMessages: watchMessages, sendText: sendText,
          sendPhoto: sendPhoto, requestView: requestView,
          getProfile: getProfile, watchLink: watchLink, auth: auth,
        );
      },
      act: (c) => c.requestPhotoView('link-1', 'msg-1'),
      expect: () => [
        const ChatState(
          actionStatus: ChatActionStatus.viewingPhoto,
          viewingPhotoUrl: 'https://example.com/photo.jpg',
        ),
      ],
    );
  });

  group('dismissPhoto', () {
    blocTest<ChatCubit, ChatState>(
      'clears viewingPhoto state',
      build: () => _buildCubit(
        watchMessages: watchMessages, sendText: sendText,
        sendPhoto: sendPhoto, requestView: requestView,
        getProfile: getProfile, watchLink: watchLink, auth: auth,
      ),
      seed: () => const ChatState(
        actionStatus: ChatActionStatus.viewingPhoto,
        viewingPhotoUrl: 'https://example.com/photo.jpg',
      ),
      act: (c) => c.dismissPhoto(),
      expect: () => [
        const ChatState(actionStatus: ChatActionStatus.idle),
      ],
    );
  });

  group('init — link expiry', () {
    test('emits isLinkExpired when link status changes to expired', () async {
      final linkController = StreamController<Either<Failure, LinkEntity>>();
      when(() => watchLink('link-1')).thenAnswer((_) => linkController.stream);

      final cubit = _buildCubit(
        watchMessages: watchMessages, sendText: sendText,
        sendPhoto: sendPhoto, requestView: requestView,
        getProfile: getProfile, watchLink: watchLink, auth: auth,
      );
      cubit.init('link-1', otherUid: 'uid-bob');

      final expiredLink = LinkEntity(
        linkId: 'link-1',
        userA: 'uid-alice',
        userB: 'uid-bob',
        status: 'expired',
        initiatedBy: 'uid-alice',
      );
      linkController.add(Right(expiredLink));
      await Future.delayed(Duration.zero);

      expect(cubit.state.isLinkExpired, isTrue);
      await linkController.close();
      await cubit.close();
    });
  });
}
