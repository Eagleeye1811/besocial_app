// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drafts_feed_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DraftsFeedResponseDto _$DraftsFeedResponseDtoFromJson(
        Map<String, dynamic> json) =>
    DraftsFeedResponseDto(
      drafts: (json['drafts'] as List<dynamic>)
          .map((e) => DraftModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
      totalInView: (json['total_in_view'] as num).toInt(),
    );
