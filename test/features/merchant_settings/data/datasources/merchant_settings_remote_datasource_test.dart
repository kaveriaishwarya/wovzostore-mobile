import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/merchant_settings/data/datasources/merchant_settings_remote_datasource.dart';
import 'package:wovzo_mobile/features/merchant_settings/data/models/store_settings_model.dart';

class MockDio implements Dio {
  bool shouldFail = false;
  final tStoreSettingsModel = StoreSettingsModel(
    storeName: 'Wovzo Store',
    codEnabled: true,
    minOrderAmountForCod: 0,
    defaultCurrency: 'INR',
    flatDeliveryCharge: 0,
    estimatedDeliveryDays: 0,
    returnWindowDays: 0,
    replaceWindowDays: 0,
    returnAllowed: true,
    createdAt: DateTime.now(),
  );

  @override
  Future<Response<T>> get<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, void Function(int, int)? onReceiveProgress}) async {
    if (shouldFail) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        response: Response(requestOptions: RequestOptions(path: path), statusCode: 404),
      );
    }
    return Response(
      requestOptions: RequestOptions(path: path),
      data: (tStoreSettingsModel.toJson()..addAll({'createdAt': '2024-01-01T00:00:00Z'})) as T,
      statusCode: 200,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MerchantSettingsRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = MerchantSettingsRemoteDataSourceImpl(dio: mockDio);
  });

  group('getStoreSettings', () {
    test('should return StoreSettingsModel when response code is 200', () async {
      final result = await dataSource.getStoreSettings();
      expect(result.storeName, equals(mockDio.tStoreSettingsModel.storeName));
    });

    test('should throw ApiException when DioException occurs', () async {
      mockDio.shouldFail = true;
      expect(() => dataSource.getStoreSettings(), throwsA(isA<ApiException>()));
    });
  });
}
