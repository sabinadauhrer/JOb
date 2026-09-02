import 'package:freezed_annotation/freezed_annotation.dart';

part 'job.freezed.dart';
part 'job.g.dart';

@freezed
abstract class Job with _$Job {
  const factory Job({
    required String id,
    required String source,
    required String title,
    String? company,
    String? location,
    String? description,
    String? postedDate,
    String? applicationEmail,
    String? applicationUrl,
  }) = _Job;

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
}

@freezed
abstract class JobSearchResult with _$JobSearchResult {
  const factory JobSearchResult({
    required List<Job> jobs,
    required int page,
    required bool hasMore,
  }) = _JobSearchResult;

  factory JobSearchResult.fromJson(Map<String, dynamic> json) =>
      _$JobSearchResultFromJson(json);
}
