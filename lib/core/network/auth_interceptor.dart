import 'dart:async';
import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final Dio _refreshDio;
  final void Function()? onSessionExpired;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  static const String _refreshEndpointPath = '/api/v1/auth/token/refresh';
  static const String _isRetryKey = 'is_retry';

  AuthInterceptor({
    required SecureStorageService secureStorage,
    required Dio refreshDio,
    this.onSessionExpired,
  })  : _secureStorage = secureStorage,
        _refreshDio = refreshDio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Do not attach authorization header to refresh request
    if (!options.path.endsWith(_refreshEndpointPath)) {
      final token = await _secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final requestOptions = err.requestOptions;

    // Check if error is 401 Unauthorized
    if (response?.statusCode == 401) {
      // 1. Prevent recursion: Never attempt refresh if the refresh endpoint itself failed
      if (requestOptions.path.endsWith(_refreshEndpointPath)) {
        return handler.next(err);
      }

      // 2. Prevent infinite loops: Max 1 retry per request
      if (requestOptions.extra[_isRetryKey] == true) {
        return handler.next(err);
      }

      // 3. Single-flight token refresh locking
      if (_isRefreshing) {
        // A refresh is already in progress. Wait for it to finish.
        try {
          final refreshSuccess = await (_refreshCompleter?.future ?? Future.value(false));
          if (refreshSuccess) {
            final retriedResponse = await _retryRequest(requestOptions);
            return handler.resolve(retriedResponse);
          }
        } catch (_) {
          // Refresh failed for waiting request
        }
        return handler.next(err);
      }

      _isRefreshing = true;
      _refreshCompleter = Completer<bool>();

      try {
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          await _handleSessionExpired();
          _refreshCompleter?.complete(false);
          return handler.next(err);
        }

        // Call backend refresh token endpoint
        final refreshResponse = await _refreshDio.post(
          _refreshEndpointPath,
          data: {'refreshToken': refreshToken},
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

        if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
          final data = refreshResponse.data as Map<String, dynamic>;
          final newAccessToken = data['accessToken']?.toString();
          final newRefreshToken = data['refreshToken']?.toString();

          if (newAccessToken != null && newRefreshToken != null) {
            await _secureStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            _refreshCompleter?.complete(true);

            // Retry original failed request
            final retriedResponse = await _retryRequest(requestOptions);
            return handler.resolve(retriedResponse);
          }
        }

        // Failed to get new tokens
        await _handleSessionExpired();
        _refreshCompleter?.complete(false);
        return handler.next(err);
      } catch (e) {
        await _handleSessionExpired();
        _refreshCompleter?.complete(false);
        return handler.next(err);
      } finally {
        _isRefreshing = false;
        _refreshCompleter = null;
      }
    }

    handler.next(err);
  }

  Future<void> _handleSessionExpired() async {
    await _secureStorage.deleteTokens();
    onSessionExpired?.call();
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final newToken = await _secureStorage.getAccessToken();
    requestOptions.extra[_isRetryKey] = true;
    if (newToken != null && newToken.isNotEmpty) {
      requestOptions.headers['Authorization'] = 'Bearer $newToken';
    }

    final dio = Dio();
    return dio.fetch(requestOptions);
  }
}
