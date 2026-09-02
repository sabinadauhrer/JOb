import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class ApplicationSendRemoteDataSource {
  const ApplicationSendRemoteDataSource(this._dio);
  final Dio _dio;

  Future<void> send({
    required String to,
    required String subject,
    required String body,
    required String cvPdfBase64,
    String? cvFileName,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/applications/send',
        data: {
          'to': to,
          'subject': subject,
          'body': body,
          'cvPdfBase64': cvPdfBase64,
          if (cvFileName != null) 'cvFileName': cvFileName,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
