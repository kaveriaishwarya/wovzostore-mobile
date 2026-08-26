import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';

void main() {
  group('ApiException Tests', () {
    test('maps connection timeout to ApiTimeoutException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final exception = ApiException.fromDioException(dioErr);
      expect(exception, isA<ApiTimeoutException>());
      expect(exception.message, contains('timed out'));
    });

    test('maps connection error to ApiNetworkException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      final exception = ApiException.fromDioException(dioErr);
      expect(exception, isA<ApiNetworkException>());
      expect(exception.message, contains('Unable to connect'));
    });

    test('maps 401 response to ApiUnauthorizedException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
          data: {'title': 'Unauthorized', 'detail': 'JWT token expired'},
        ),
      );

      final exception = ApiException.fromDioException(dioErr);
      expect(exception, isA<ApiUnauthorizedException>());
      expect(exception.statusCode, 401);
      expect(exception.message, 'JWT token expired');
    });

    test('maps 403 response to ApiForbiddenException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 403,
          data: {'detail': 'Access denied'},
        ),
      );

      final exception = ApiException.fromDioException(dioErr);
      expect(exception, isA<ApiForbiddenException>());
      expect(exception.statusCode, 403);
    });

    test('maps 404 response to ApiNotFoundException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
          data: {'detail': 'Resource not found'},
        ),
      );

      final exception = ApiException.fromDioException(dioErr);
      expect(exception, isA<ApiNotFoundException>());
      expect(exception.statusCode, 404);
    });

    test('maps 422 response to ApiValidationException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 422,
          data: {
            'title': 'Validation Error',
            'errors': {
              'Email': ['Email is required.']
            }
          },
        ),
      );

      final exception = ApiException.fromDioException(dioErr);
      expect(exception, isA<ApiValidationException>());
      expect(exception.message, 'Email is required.');
    });

    test('maps 500 response to ApiServerException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
          data: {'title': 'Internal Server Error'},
        ),
      );

      final exception = ApiException.fromDioException(dioErr);
      expect(exception, isA<ApiServerException>());
      expect(exception.statusCode, 500);
    });
  });
}
