import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/customer_onboarding/data/datasources/customer_remote_datasource.dart';

class MockDio extends Fake implements Dio {
  int postCallCount = 0;
  String? lastPath;

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    postCallCount++;
    lastPath = path;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
    );
  }
}

void main() {
  group('CustomerRemoteDataSourceImpl', () {
    late MockDio mockDio;
    late CustomerRemoteDataSourceImpl dataSource;

    setUp(() {
      mockDio = MockDio();
      dataSource = CustomerRemoteDataSourceImpl(dio: mockDio);
    });

    test('onboardCustomer calls POST /api/v1/customers/onboard', () async {
      await dataSource.onboardCustomer();
      expect(mockDio.postCallCount, 1);
      expect(mockDio.lastPath, '/api/v1/customers/onboard');
    });
  });
}
