// lib/features/auth/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String? phone;
  final String? email;
  final bool hasCard;

  const UserEntity({
    required this.uid,
    this.phone,
    this.email,
    this.hasCard = false,
  });

  @override
  List<Object?> get props => [uid, phone, email, hasCard];
}
