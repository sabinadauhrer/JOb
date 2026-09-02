import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../domain/models/cv_profile.dart';

class CvTailorResult {
  const CvTailorResult({required this.tailoredSummary, required this.coverLetter});

  final String tailoredSummary;
  final String coverLetter;

  factory CvTailorResult.fromJson(Map<String, dynamic> json) {
    return CvTailorResult(
      tailoredSummary: json['tailoredSummary'] as String? ?? '',
      coverLetter: json['coverLetter'] as String? ?? '',
    );
  }
}

class CvTailorRemoteDataSource {
  const CvTailorRemoteDataSource(this._dio);
  final Dio _dio;

  Future<CvTailorResult> tailor({
    required CvProfile profile,
    required String jobDescription,
    String? jobTitle,
    String? company,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/cv/tailor',
        data: {
          'profile': profile.toJson(),
          'jobDescription': jobDescription,
          if (jobTitle != null) 'jobTitle': jobTitle,
          if (company != null) 'company': company,
        },
      );
      return CvTailorResult.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
