// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instagram_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstagramStatusModel _$InstagramStatusModelFromJson(
        Map<String, dynamic> json) =>
    InstagramStatusModel(
      connected: json['connected'] as bool,
      igUserId: json['ig_user_id'] as String?,
      igUsername: json['ig_username'] as String?,
      connectedAt: json['connected_at'] == null
          ? null
          : DateTime.parse(json['connected_at'] as String),
    );

Map<String, dynamic> _$InstagramStatusModelToJson(
        InstagramStatusModel instance) =>
    <String, dynamic>{
      'connected': instance.connected,
      'ig_user_id': instance.igUserId,
      'ig_username': instance.igUsername,
      'connected_at': instance.connectedAt?.toIso8601String(),
    };
