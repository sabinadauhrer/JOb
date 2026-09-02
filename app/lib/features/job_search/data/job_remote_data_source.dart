import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../domain/models/job.dart';

class JobRemoteDataSource {
  const JobRemoteDataSource(this._dio);
  final Dio _dio;

  Future<JobSearchResult> search({
    required String query,
    String? location,
    int? radius,
    int page = 1,
    int size = 25,
  }) async {
    try {
      final normalizedLocation = (location != null && location.isNotEmpty) ? location : null;
      final response = await _dio.get<Map<String, dynamic>>(
        '/jobs/search',
        queryParameters: {
          'query': query,
          'location': ?normalizedLocation,
          if (radius != null) 'radius': radius,
          'page': page,
          'size': size,
        },
      );
      return JobSearchResult.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Job> getDetail({required String source, required String id}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/jobs/$source/${Uri.encodeComponent(id)}',
      );
      return Job.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
