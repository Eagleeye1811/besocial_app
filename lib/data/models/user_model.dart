import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../core/constants/app_keys.dart';

part 'user_model.g.dart';

/// Mirrors `UserResponse` (backend `src/models/user.py:109`), returned by
/// `GET /api/v1/auth/me`.
///
/// Hive-cached so we can show a logged-in user's identity offline (avatar in
/// the nav, name in greetings) without blocking on a `/me` refetch at boot.
@HiveType(typeId: HiveTypeIds.userModel)
@JsonSerializable(fieldRename: FieldRename.snake)
class UserModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? name;

  @HiveField(3)
  final String? pictureUrl;

  @HiveField(4)
  final String? instagramUsername;

  @HiveField(5)
  final bool hasCompletedOnboarding;

  UserModel({
    required this.userId,
    required this.email,
    this.name,
    this.pictureUrl,
    this.instagramUsername,
    required this.hasCompletedOnboarding,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
