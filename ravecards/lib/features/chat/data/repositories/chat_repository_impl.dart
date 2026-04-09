import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/message_model.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
  final http.Client _httpClient;

  ChatRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebaseFunctions functions,
    required http.Client httpClient,
  })  : _firestore = firestore,
        _auth = auth,
        _functions = functions,
        _httpClient = httpClient;

  CollectionReference<Map<String, dynamic>> _messagesRef(String linkId) =>
      _firestore.collection('links').doc(linkId).collection('messages');

  @override
  Stream<Either<Failure, List<MessageEntity>>> watchMessages(String linkId) {
    final source = _messagesRef(linkId)
        .orderBy('createdAt', descending: false)
        .limit(100)
        .snapshots();

    return Stream.multi((controller) {
      source.listen(
        (snapshot) {
          try {
            final messages = snapshot.docs
                .map((doc) => MessageModel.fromFirestore(doc))
                .toList();
            controller.add(Right(messages));
          } catch (e) {
            controller.add(Left(ChatFailure('Failed to parse messages: $e')));
          }
        },
        onError: (Object e) {
          controller.add(Left(ChatFailure(e.toString())));
        },
        onDone: controller.close,
        cancelOnError: false,
      );
    });
  }

  @override
  Future<Either<Failure, Unit>> sendText(String linkId, String text) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Left(ChatFailure('Cannot send message: no authenticated user'));
    }
    try {
      await _messagesRef(linkId).add({
        'type': 'text',
        'senderId': currentUser.uid,
        'text': text,
        'photoRef': null,
        'viewedBy': [],
        'deletedFromStorage': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const Right(unit);
    } catch (e) {
      return Left(ChatFailure('Failed to send message: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendPhoto(String linkId, Uint8List imageBytes) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Left(ChatFailure('Cannot send photo: no authenticated user'));
    }
    try {
      final msgId = _messagesRef(linkId).doc().id;

      final callable = _functions.httpsCallable('requestPhotoUploadUrl');
      final result = await callable.call({'linkId': linkId, 'msgId': msgId});
      final uploadUrl = result.data['uploadUrl'] as String;
      final photoRef = result.data['photoRef'] as String;

      final response = await _httpClient.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': 'image/jpeg'},
        body: imageBytes,
      );
      if (response.statusCode != 200) {
        return Left(ChatFailure('Upload failed: ${response.statusCode}'));
      }

      await _messagesRef(linkId).doc(msgId).set({
        'type': 'photo_once',
        'senderId': currentUser.uid,
        'text': null,
        'photoRef': photoRef,
        'viewedBy': [],
        'deletedFromStorage': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return const Right(unit);
    } on FirebaseFunctionsException catch (e) {
      return Left(ChatFailure(e.message ?? 'Photo upload failed: $e'));
    } catch (e) {
      return Left(ChatFailure('Photo upload failed: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> requestPhotoView(String linkId, String msgId) async {
    try {
      final callable = _functions.httpsCallable('getPhotoViewUrl');
      final result = await callable.call({'linkId': linkId, 'msgId': msgId});
      return Right(result.data['viewUrl'] as String);
    } on FirebaseFunctionsException catch (e) {
      return Left(ChatFailure(e.message ?? 'Could not get photo URL: $e'));
    } catch (e) {
      return Left(ChatFailure('Could not get photo URL: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, String?>>> getOtherUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return const Left(ChatFailure('User not found'));
      }
      final data = doc.data()!;
      return Right({
        'displayName': data['displayName'] as String?,
        'photoUrl': data['photoUrl'] as String?,
      });
    } catch (e) {
      return Left(ChatFailure('Could not load user profile: $e'));
    }
  }
}
