import 'package:dio/dio.dart';
import 'problem_details.dart';

abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ProblemDetails? problemDetails;

  const ApiException({
    required this.message,
    this.statusCode,
    this.problemDetails,
  });

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiTimeoutException(
          message: 'The connection timed out. Please try again.',
        );

      case DioExceptionType.connectionError:
        return const ApiNetworkException(
          message: 'Unable to connect to the server. Check your network connection.',
        );

      case DioExceptionType.badResponse:
        final response = error.response;
        final statusCode = response?.statusCode;
        ProblemDetails? problem;

        if (response?.data != null && response?.data is Map<String, dynamic>) {
          try {
            problem = ProblemDetails.fromJson(response!.data as Map<String, dynamic>);
          } catch (_) {
            problem = null;
          }
        }

        final errorMessage = problem?.displayMessage ??
            response?.statusMessage ??
            'HTTP Error $statusCode';

        if (statusCode == 401) {
          return ApiUnauthorizedException(
            message: errorMessage,
            statusCode: statusCode,
            problemDetails: problem,
          );
        } else if (statusCode == 403) {
          return ApiForbiddenException(
            message: errorMessage,
            statusCode: statusCode,
            problemDetails: problem,
          );
        } else if (statusCode == 404) {
          return ApiNotFoundException(
            message: errorMessage,
            statusCode: statusCode,
            problemDetails: problem,
          );
        } else if (statusCode == 400 || statusCode == 422) {
          return ApiValidationException(
            message: errorMessage,
            statusCode: statusCode,
            problemDetails: problem,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return ApiServerException(
            message: errorMessage,
            statusCode: statusCode,
            problemDetails: problem,
          );
        }

        return ApiUnknownException(
          message: errorMessage,
          statusCode: statusCode,
          problemDetails: problem,
        );

      case DioExceptionType.cancel:
        return const ApiUnknownException(message: 'Request was cancelled.');

      default:
        return ApiUnknownException(
          message: error.message ?? 'An unexpected network error occurred.',
        );
    }
  }

  @override
  String toString() => message;
}

class ApiNetworkException extends ApiException {
  const ApiNetworkException({required super.message});
}

class ApiTimeoutException extends ApiException {
  const ApiTimeoutException({required super.message});
}

class ApiUnauthorizedException extends ApiException {
  const ApiUnauthorizedException({
    required super.message,
    super.statusCode = 401,
    super.problemDetails,
  });
}

class ApiForbiddenException extends ApiException {
  const ApiForbiddenException({
    required super.message,
    super.statusCode = 403,
    super.problemDetails,
  });
}

class ApiNotFoundException extends ApiException {
  const ApiNotFoundException({
    required super.message,
    super.statusCode = 404,
    super.problemDetails,
  });
}

class ApiValidationException extends ApiException {
  const ApiValidationException({
    required super.message,
    super.statusCode,
    super.problemDetails,
  });
}

class ApiServerException extends ApiException {
  const ApiServerException({
    required super.message,
    super.statusCode,
    super.problemDetails,
  });
}

class ApiUnknownException extends ApiException {
  const ApiUnknownException({
    required super.message,
    super.statusCode,
    super.problemDetails,
  });
}
