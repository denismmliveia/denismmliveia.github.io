// lib/features/auth/data/models/user_model.dart
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.phone,
    super.email,
    super.hasCard,
  });

  factory UserModel.fromFirebaseUser(fb.User user, {bool hasCard = false}) {
    return UserModel(
      uid: user.uid,
      phone: user.phoneNumber,
      email: user.email,
      hasCard: hasCard,
    );
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      hasCard: map['hasCard'] as bool? ?? false,
    );
  }
}
