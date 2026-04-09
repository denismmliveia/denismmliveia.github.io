// lib/features/card/domain/entities/card_entity.dart
import 'package:equatable/equatable.dart';

class CardEntity extends Equatable {
  final String uid;
  final String displayName;
  final String photoUrl;
  final String genre;
  final String orientation;
  final String relationshipStatus;
  final String favoriteTheme;
  final String? activeQrToken;
  final DateTime? qrTokenExpiresAt;

  const CardEntity({
    required this.uid,
    required this.displayName,
    required this.photoUrl,
    required this.genre,
    required this.orientation,
    required this.relationshipStatus,
    required this.favoriteTheme,
    this.activeQrToken,
    this.qrTokenExpiresAt,
  });

  bool get hasValidQrToken {
    if (activeQrToken == null || qrTokenExpiresAt == null) return false;
    return qrTokenExpiresAt!.isAfter(DateTime.now().add(const Duration(seconds: 60)));
  }

  CardEntity copyWith({
    String? displayName,
    String? photoUrl,
    String? genre,
    String? orientation,
    String? relationshipStatus,
    String? favoriteTheme,
    String? activeQrToken,
    DateTime? qrTokenExpiresAt,
  }) {
    return CardEntity(
      uid: uid,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      genre: genre ?? this.genre,
      orientation: orientation ?? this.orientation,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      favoriteTheme: favoriteTheme ?? this.favoriteTheme,
      activeQrToken: activeQrToken ?? this.activeQrToken,
      qrTokenExpiresAt: qrTokenExpiresAt ?? this.qrTokenExpiresAt,
    );
  }

  @override
  List<Object?> get props => [
        uid, displayName, photoUrl, genre,
        orientation, relationshipStatus, favoriteTheme,
        activeQrToken, qrTokenExpiresAt,
      ];
}
