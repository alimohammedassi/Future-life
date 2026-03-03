import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

/// Dio HTTP client configuration for API communication
class ApiClient {
  static final Logger _logger = Logger();
  static Dio? _dio;

  /// Get singleton instance of Dio client
  static Dio get instance {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.backendBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      // Add logging interceptor
      _dio!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            _logger.i('→ ${options.method} ${options.uri}');
            _logger.i('Headers: ${options.headers}');
            if (options.data != null) {
              _logger.i('Body: ${options.data}');
            }
            return handler.next(options);
          },
          onResponse: (response, handler) {
            _logger.i('← ${response.statusCode} ${response.requestOptions.uri}');
            _logger.i('Response: ${response.data}');
            return handler.next(response);
          },
          onError: (DioException error, handler) {
            _logger.e('✗ ${error.response?.statusCode} ${error.requestOptions.uri}');
            _logger.e('Error: ${error.message}');
            if (error.response?.data != null) {
              _logger.e('Error Data: ${error.response?.data}');
            }
            return handler.next(error);
          },
        ),
      );
    }
    return _dio!;
  }

  /// Dispose of the Dio instance
  static void dispose() {
    _dio?.close();
    _dio = null;
  }
}