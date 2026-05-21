import 'package:json_annotation/json_annotation.dart';

part 'instagram_status_model.g.dart';

/// Mirrors `StatusResponse` from `GET /api/v1/instagram/status`.
///
/// `connected == false` ⇒ the other fields are all null; we still keep them
/// non-required so consumers can rebuild from a freshly-disconnected state
/// without juggling sentinel values.
@JsonSerializable(fieldRename: FieldRename.snake)
class InstagramStatusModel {
  final bool connected;
  final String? igUserId;
  final String? igUsername;
  final DateTime? connectedAt;

  const InstagramStatusModel({
    required this.connected,
    this.igUserId,
    this.igUsername,
    this.connectedAt,
  });

  factory InstagramStatusModel.fromJson(Map<String, dynamic> json) =>
      _$InstagramStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$InstagramStatusModelToJson(this);
}
