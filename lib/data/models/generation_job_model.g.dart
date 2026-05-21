// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generation_job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenerationSlideModel _$GenerationSlideModelFromJson(
        Map<String, dynamic> json) =>
    GenerationSlideModel(
      slideIndex: (json['slide_index'] as num).toInt(),
      imageUrl: json['image_url'] as String,
      slideText: json['slide_text'] as String,
      caption: json['caption'] as String,
    );

Map<String, dynamic> _$GenerationSlideModelToJson(
        GenerationSlideModel instance) =>
    <String, dynamic>{
      'slide_index': instance.slideIndex,
      'image_url': instance.imageUrl,
      'slide_text': instance.slideText,
      'caption': instance.caption,
    };

GenerationJobModel _$GenerationJobModelFromJson(Map<String, dynamic> json) =>
    GenerationJobModel(
      jobId: json['job_id'] as String,
      status: $enumDecode(_$GenerationJobStatusEnumMap, json['status']),
      slides: (json['slides'] as List<dynamic>)
          .map((e) => GenerationSlideModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      errorMessage: json['error_message'] as String?,
      errorCode: json['error_code'] as String?,
    );

Map<String, dynamic> _$GenerationJobModelToJson(GenerationJobModel instance) =>
    <String, dynamic>{
      'job_id': instance.jobId,
      'status': _$GenerationJobStatusEnumMap[instance.status]!,
      'slides': instance.slides,
      'error_message': instance.errorMessage,
      'error_code': instance.errorCode,
    };

const _$GenerationJobStatusEnumMap = {
  GenerationJobStatus.pending: 'pending',
  GenerationJobStatus.analyzing: 'analyzing',
  GenerationJobStatus.planning: 'planning',
  GenerationJobStatus.rendering: 'rendering',
  GenerationJobStatus.completed: 'completed',
  GenerationJobStatus.failed: 'failed',
};
