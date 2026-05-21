import 'package:json_annotation/json_annotation.dart';

part 'generation_job_model.g.dart';

/// Lifecycle of a generation job, returned by
/// `GET /api/v1/generation/{job_id}`. Only `completed` and `failed` are
/// terminal — [Poller] runs until one of those.
enum GenerationJobStatus {
  pending,
  analyzing,
  planning,
  rendering,
  completed,
  failed,
}

/// One rendered slide inside a completed generation.
@JsonSerializable(fieldRename: FieldRename.snake)
class GenerationSlideModel {
  final int slideIndex;
  final String imageUrl;
  final String slideText;
  final String caption;

  const GenerationSlideModel({
    required this.slideIndex,
    required this.imageUrl,
    required this.slideText,
    required this.caption,
  });

  factory GenerationSlideModel.fromJson(Map<String, dynamic> json) =>
      _$GenerationSlideModelFromJson(json);

  Map<String, dynamic> toJson() => _$GenerationSlideModelToJson(this);
}

/// Full generation-job snapshot. `slides` is empty until the job reaches
/// `completed`; `errorMessage`/`errorCode` are non-null on `failed`.
@JsonSerializable(fieldRename: FieldRename.snake)
class GenerationJobModel {
  final String jobId;
  final GenerationJobStatus status;
  final List<GenerationSlideModel> slides;
  final String? errorMessage;
  final String? errorCode;

  const GenerationJobModel({
    required this.jobId,
    required this.status,
    required this.slides,
    this.errorMessage,
    this.errorCode,
  });

  bool get isTerminal =>
      status == GenerationJobStatus.completed ||
      status == GenerationJobStatus.failed;

  factory GenerationJobModel.fromJson(Map<String, dynamic> json) =>
      _$GenerationJobModelFromJson(json);

  Map<String, dynamic> toJson() => _$GenerationJobModelToJson(this);
}
