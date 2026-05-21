// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionStatusModel _$SessionStatusModelFromJson(Map<String, dynamic> json) =>
    SessionStatusModel(
      status: $enumDecode(_$SessionStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$SessionStatusModelToJson(SessionStatusModel instance) =>
    <String, dynamic>{
      'status': _$SessionStatusEnumMap[instance.status]!,
    };

const _$SessionStatusEnumMap = {
  SessionStatus.processing: 'processing',
  SessionStatus.ready: 'ready',
  SessionStatus.failed: 'failed',
};
