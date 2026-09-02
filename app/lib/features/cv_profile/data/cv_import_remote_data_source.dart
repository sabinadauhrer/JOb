import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class CvImportRemoteDataSource {
  const CvImportRemoteDataSource(this._dio);
  final Dio _dio;

  /// Returns the raw extracted profile JSON. Callers must assign ids to
  /// experience/education entries themselves - the backend has none to give,
  /// since they don't exist yet as local CV-profile entries.
  Future<Map<String, dynamic>> importFromPdfBase64(String pdfBase64) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/cv/import',
        data: {'pdfBase64': pdfBase64},
      );
      return response.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
