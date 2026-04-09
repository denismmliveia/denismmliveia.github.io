// lib/features/card/data/models/card_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/card_entity.dart';

class CardModel extends CardEntity {
  const CardModel({
    required super.uid,
    required super.displayName,
    required super.photoUrl,
    required super.genre,
    required super.orientation,
    required super.relationshipStatus,
    required super.favoriteTheme,
    super.activeQrToken,
    super.qrTokenExpiresAt,
  });

  factory CardModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data()!;
    return CardModel(
      uid: snap.id,
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      genre: data['genre'] as String? ?? '',
      orientation: data['orientation'] as String? ?? '',
      relationshipStatus: data['relationshipStatus'] as String? ?? '',
      favoriteTheme: data['favoriteTheme'] as String? ?? '',
      activeQrToken: data['activeQrToken'] as String?,
      qrTokenExpiresAt: (data['qrTokenExpiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'photoUrl': photoUrl,
        'genre': genre,
        'orientation': orientation,
        'relationshipStatus': relationshipStatus,
        'favoriteTheme': favoriteTheme,
      };
}
