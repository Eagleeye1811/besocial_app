// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      userId: fields[0] as String,
      email: fields[1] as String,
      name: fields[2] as String?,
      pictureUrl: fields[3] as String?,
      instagramUsername: fields[4] as String?,
      hasCompletedOnboarding: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.pictureUrl)
      ..writeByte(4)
      ..write(obj.instagramUsername)
      ..writeByte(5)
      ..write(obj.hasCompletedOnboarding);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      pictureUrl: json['picture_url'] as String?,
      instagramUsername: json['instagram_username'] as String?,
      hasCompletedOnboarding: json['has_completed_onboarding'] as bool,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'user_id': instance.userId,
      'email': instance.email,
      'name': instance.name,
      'picture_url': instance.pictureUrl,
      'instagram_username': instance.instagramUsername,
      'has_completed_onboarding': instance.hasCompletedOnboarding,
    };
