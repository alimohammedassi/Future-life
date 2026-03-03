import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import '../auth/auth_storage.dart';

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

      // ── Auth interceptor: auto-attach Bearer token to every request ──
      _dio!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Only add Authorization if not already set by the caller
            if (!options.headers.containsKey('Authorization')) {
              final token = await AuthStorage.getAccessToken();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            }
            _logger.i('→ ${options.method} ${options.uri}');
            _logger.i('Headers: ${options.headers}');
            if (options.data != null) {
              _logger.i('Body: ${options.data}');
            }
            return handler.next(options);
          },
          onResponse: (response, handler) {
            _logger
                .i('← ${response.statusCode} ${response.requestOptions.uri}');
            _logger.i('Response: ${response.data}');
            return handler.next(response);
          },
          onError: (DioException error, handler) async {
            _logger.e(
                '✗ ${error.response?.statusCode} ${error.requestOptions.uri}');
            _logger.e('Error: ${error.message}');
            if (error.response?.data != null) {
              _logger.e('Error Data: ${error.response?.data}');
            }
            // On 401 clear stored tokens so the app redirects to login
            if (error.response?.statusCode == 401) {
              await AuthStorage.clearAll();
            }
            return handler.next(error);
          },
        ),
      );
    }
    return _dio!;
  }

  /// Dispose of the Dio instance (call when resetting after logout)
  static void dispose() {
    _dio?.close();
    _dio = null;
  }
}
