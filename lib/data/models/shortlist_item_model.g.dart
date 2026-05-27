// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shortlist_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShortlistItemModelAdapter extends TypeAdapter<ShortlistItemModel> {
  @override
  final int typeId = 40;

  @override
  ShortlistItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShortlistItemModel(
      postId: fields[0] as String,
      authorHandle: fields[1] as String,
      thumbnailUrl: fields[2] as String?,
      images: (fields[3] as List).cast<String>(),
      caption: fields[4] as String,
      likeCount: fields[5] as int,
      format: fields[6] as String,
      slideCount: fields[7] as int,
      generationStatus: fields[8] as ShortlistGenerationStatus,
      generationJobId: fields[9] as String?,
      shortlistedAt: fields[10] as DateTime,
      extractionStatus: fields[11] as String?,
      extractedSlideTexts: (fields[12] as List?)?.cast<String>(),
      generationError: fields[13] as String?,
      generationErrorCode: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ShortlistItemModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.postId)
      ..writeByte(1)
      ..write(obj.authorHandle)
      ..writeByte(2)
      ..write(obj.thumbnailUrl)
      ..writeByte(3)
      ..write(obj.images)
      ..writeByte(4)
      ..write(obj.caption)
      ..writeByte(5)
      ..write(obj.likeCount)
      ..writeByte(6)
      ..write(obj.format)
      ..writeByte(7)
      ..write(obj.slideCount)
      ..writeByte(8)
      ..write(obj.generationStatus)
      ..writeByte(9)
      ..write(obj.generationJobId)
      ..writeByte(10)
      ..write(obj.shortlistedAt)
      ..writeByte(11)
      ..write(obj.extractionStatus)
      ..writeByte(12)
      ..write(obj.extractedSlideTexts)
      ..writeByte(13)
      ..write(obj.generationError)
      ..writeByte(14)
      ..write(obj.generationErrorCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShortlistItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShortlistGenerationStatusAdapter
    extends TypeAdapter<ShortlistGenerationStatus> {
  @override
  final int typeId = 44;

  @override
  ShortlistGenerationStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ShortlistGenerationStatus.ready;
      case 1:
        return ShortlistGenerationStatus.generating;
      case 2:
        return ShortlistGenerationStatus.generated;
      case 3:
        return ShortlistGenerationStatus.failed;
      default:
        return ShortlistGenerationStatus.ready;
    }
  }

  @override
  void write(BinaryWriter writer, ShortlistGenerationStatus obj) {
    switch (obj) {
      case ShortlistGenerationStatus.ready:
        writer.writeByte(0);
        break;
      case ShortlistGenerationStatus.generating:
        writer.writeByte(1);
        break;
      case ShortlistGenerationStatus.generated:
        writer.writeByte(2);
        break;
      case ShortlistGenerationStatus.failed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShortlistGenerationStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShortlistItemModel _$ShortlistItemModelFromJson(Map<String, dynamic> json) =>
    ShortlistItemModel(
      postId: json['post_id'] as String,
      authorHandle: json['author_handle'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      caption: json['caption'] as String,
      likeCount: (json['like_count'] as num).toInt(),
      format: json['format'] as String,
      slideCount: (json['slide_count'] as num).toInt(),
      generationStatus: $enumDecode(
          _$ShortlistGenerationStatusEnumMap, json['generation_status'],
          unknownValue: ShortlistGenerationStatus.generating),
      generationJobId: json['generation_job_id'] as String?,
      shortlistedAt: DateTime.parse(json['shortlisted_at'] as String),
      extractionStatus: json['extraction_status'] as String?,
      extractedSlideTexts: (json['extracted_slide_texts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      generationError: json['generation_error'] as String?,
      generationErrorCode: json['generation_error_code'] as String?,
    );

Map<String, dynamic> _$ShortlistItemModelToJson(ShortlistItemModel instance) =>
    <String, dynamic>{
      'post_id': instance.postId,
      'author_handle': instance.authorHandle,
      'thumbnail_url': instance.thumbnailUrl,
      'images': instance.images,
      'caption': instance.caption,
      'like_count': instance.likeCount,
      'format': instance.format,
      'slide_count': instance.slideCount,
      'generation_status':
          _$ShortlistGenerationStatusEnumMap[instance.generationStatus]!,
      'generation_job_id': instance.generationJobId,
      'shortlisted_at': instance.shortlistedAt.toIso8601String(),
      'extraction_status': instance.extractionStatus,
      'extracted_slide_texts': instance.extractedSlideTexts,
      'generation_error': instance.generationError,
      'generation_error_code': instance.generationErrorCode,
    };

const _$ShortlistGenerationStatusEnumMap = {
  ShortlistGenerationStatus.ready: 'ready',
  ShortlistGenerationStatus.generating: 'generating',
  ShortlistGenerationStatus.generated: 'generated',
  ShortlistGenerationStatus.failed: 'failed',
};
