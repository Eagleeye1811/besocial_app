import 'package:json_annotation/json_annotation.dart';

part 'api_envelope.g.dart';

/// Wire-format wrapper for every response returned by the BeSocial backend.
///
/// Mirrors `src/api/responses.py` in `../besocial/backend` — `success_response`
/// and the exception handlers both emit this exact shape, so unwrapping it
/// once at the HTTP layer means feature code only ever sees the inner `T`.
///
/// `T` is decoded via [genericArgumentFactories] so call sites must pass the
/// inner type's `fromJson`:
///
///     ApiEnvelope<UserModel>.fromJson(json, UserModel.fromJson as ...)
@JsonSerializable(genericArgumentFactories: true)
class ApiEnvelope<T> {
  final bool success;
  final T? data;
  final ApiError? error;

  const ApiEnvelope({
    required this.success,
    this.data,
    this.error,
  });

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiEnvelopeFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiEnvelopeToJson(this, toJsonT);
}

/// Error payload nested inside [ApiEnvelope] when `success == false`.
///
/// `code` is one of the machine-readable strings enumerated in the backend
/// (e.g. `INVALID_TOKEN`, `INVITE_CODE_INVALID`, `JOB_NOT_FOUND`). User-facing
/// copy is resolved client-side from `core/constants/error_messages.dart`.
@JsonSerializable()
class ApiError {
  final String message;
  final String code;

  const ApiError({
    required this.message,
    required this.code,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);
}
