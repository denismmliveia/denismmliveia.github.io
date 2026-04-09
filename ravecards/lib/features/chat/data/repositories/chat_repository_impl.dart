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
      return Left(ChatFailure('Cannot send message: no authenticated user'));
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
    throw UnimplementedError('sendPhoto implemented in Task 5');
  }

  @override
  Future<Either<Failure, String>> requestPhotoView(String linkId, String msgId) async {
    throw UnimplementedError('requestPhotoView implemented in Task 5');
  }

  @override
  Future<Either<Failure, Map<String, String?>>> getOtherUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return Left(ChatFailure('User not found'));
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
