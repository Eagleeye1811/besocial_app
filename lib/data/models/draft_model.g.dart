// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DraftModelAdapter extends TypeAdapter<DraftModel> {
  @override
  final int typeId = 41;

  @override
  DraftModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DraftModel(
      jobId: fields[0] as String,
      thumbnailUrl: fields[1] as String,
      captionPreview: fields[2] as String,
      slideCount: fields[3] as int,
      generatedAt: fields[4] as DateTime,
      generatedAgoLabel: fields[5] as String,
      sourcePostId: fields[6] as String?,
      sourceAuthorHandle: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DraftModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.jobId)
      ..writeByte(1)
      ..write(obj.thumbnailUrl)
      ..writeByte(2)
      ..write(obj.captionPreview)
      ..writeByte(3)
      ..write(obj.slideCount)
      ..writeByte(4)
      ..write(obj.generatedAt)
      ..writeByte(5)
      ..write(obj.generatedAgoLabel)
      ..writeByte(6)
      ..write(obj.sourcePostId)
      ..writeByte(7)
      ..write(obj.sourceAuthorHandle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DraftModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DraftModel _$DraftModelFromJson(Map<String, dynamic> json) => DraftModel(
      jobId: json['job_id'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      captionPreview: json['caption_preview'] as String,
      slideCount: (json['slide_count'] as num).toInt(),
      generatedAt: DateTime.parse(json['generated_at'] as String),
      generatedAgoLabel: json['generated_ago_label'] as String,
      sourcePostId: json['source_post_id'] as String?,
      sourceAuthorHandle: json['source_author_handle'] as String,
    );

Map<String, dynamic> _$DraftModelToJson(DraftModel instance) =>
    <String, dynamic>{
      'job_id': instance.jobId,
      'thumbnail_url': instance.thumbnailUrl,
      'caption_preview': instance.captionPreview,
      'slide_count': instance.slideCount,
      'generated_at': instance.generatedAt.toIso8601String(),
      'generated_ago_label': instance.generatedAgoLabel,
      'source_post_id': instance.sourcePostId,
      'source_author_handle': instance.sourceAuthorHandle,
    };
