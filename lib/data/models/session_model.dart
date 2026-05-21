import 'package:json_annotation/json_annotation.dart';

part 'session_model.g.dart';

/// Terminal-status set emitted by `GET /api/v1/onboarding/session`.
/// `processing` is the only non-terminal value; the [Poller] runs until
/// `ready` or `failed`.
enum SessionStatus {
  processing,
  ready,
  failed,
}

/// Flattened `GET /api/v1/onboarding/session` response (`SessionStatus`
/// is flattened to a top-level `status` field in the route).
@JsonSerializable(fieldRename: FieldRename.snake)
class SessionStatusModel {
  final SessionStatus status;

  const SessionStatusModel({required this.status});

  bool get isTerminal =>
      status == SessionStatus.ready || status == SessionStatus.failed;

  factory SessionStatusModel.fromJson(Map<String, dynamic> json) =>
      _$SessionStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionStatusModelToJson(this);
}
