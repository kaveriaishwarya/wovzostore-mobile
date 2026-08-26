import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/problem_details.dart';

void main() {
  group('ProblemDetails Model Tests', () {
    test('parses standard RFC7807 ProblemDetails JSON', () {
      final json = {
        'type': 'https://tools.ietf.org/html/rfc7231#section-6.5.1',
        'title': 'One or more validation errors occurred.',
        'status': 400,
        'detail': 'Invalid request parameters.',
        'instance': '/api/v1/auth/otp/verify',
      };

      final problem = ProblemDetails.fromJson(json);

      expect(problem.type, 'https://tools.ietf.org/html/rfc7231#section-6.5.1');
      expect(problem.title, 'One or more validation errors occurred.');
      expect(problem.status, 400);
      expect(problem.detail, 'Invalid request parameters.');
      expect(problem.instance, '/api/v1/auth/otp/verify');
      expect(problem.displayMessage, 'Invalid request parameters.');
    });

    test('parses ASP.NET Core ValidationProblemDetails with errors dictionary', () {
      final json = {
        'title': 'Validation Error',
        'status': 422,
        'errors': {
          'Phone': ['Phone number must be a valid 10-digit Indian mobile number.'],
          'Otp': ['OTP must be 6 digits.']
        }
      };

      final problem = ProblemDetails.fromJson(json);

      expect(problem.status, 422);
      expect(problem.errors, isNotNull);
      expect(problem.errors!['Phone']?.first, 'Phone number must be a valid 10-digit Indian mobile number.');
      expect(problem.displayMessage, 'Phone number must be a valid 10-digit Indian mobile number.');
    });

    test('handles missing or partial fields gracefully', () {
      final json = <String, dynamic>{};
      final problem = ProblemDetails.fromJson(json);

      expect(problem.status, isNull);
      expect(problem.title, isNull);
      expect(problem.detail, isNull);
      expect(problem.displayMessage, 'An unexpected server error occurred.');
    });
  });
}
