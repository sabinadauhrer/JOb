// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Job _$JobFromJson(Map<String, dynamic> json) => _Job(
  id: json['id'] as String,
  source: json['source'] as String,
  title: json['title'] as String,
  company: json['company'] as String?,
  location: json['location'] as String?,
  description: json['description'] as String?,
  postedDate: json['postedDate'] as String?,
  applicationEmail: json['applicationEmail'] as String?,
  applicationUrl: json['applicationUrl'] as String?,
);

Map<String, dynamic> _$JobToJson(_Job instance) => <String, dynamic>{
  'id': instance.id,
  'source': instance.source,
  'title': instance.title,
  'company': instance.company,
  'location': instance.location,
  'description': instance.description,
  'postedDate': instance.postedDate,
  'applicationEmail': instance.applicationEmail,
  'applicationUrl': instance.applicationUrl,
};

_JobSearchResult _$JobSearchResultFromJson(Map<String, dynamic> json) =>
    _JobSearchResult(
      jobs: (json['jobs'] as List<dynamic>)
          .map((e) => Job.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num).toInt(),
      hasMore: json['hasMore'] as bool,
    );

Map<String, dynamic> _$JobSearchResultToJson(_JobSearchResult instance) =>
    <String, dynamic>{
      'jobs': instance.jobs,
      'page': instance.page,
      'hasMore': instance.hasMore,
    };
