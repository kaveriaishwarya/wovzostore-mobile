import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../features/analytics/data/datasources/analytics_remote_datasource.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';

final GetIt sl = GetIt.instance;

void setupAnalyticsInjection({Dio? dioInstance}) {
  // Register Dio if not already registered
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
      () =>
          dioInstance ??
          Dio(
            BaseOptions(
              baseUrl: 'https://localhost:7291',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          ),
    );
  }

  // Register Analytics Remote Data Source
  if (!sl.isRegistered<AnalyticsRemoteDataSource>()) {
    sl.registerLazySingleton<AnalyticsRemoteDataSource>(
      () => AnalyticsRemoteDataSourceImpl(dio: sl<Dio>()),
    );
  }

  // Register Analytics Repository
  if (!sl.isRegistered<AnalyticsRepository>()) {
    sl.registerLazySingleton<AnalyticsRepository>(
      () => AnalyticsRepositoryImpl(
        remoteDataSource: sl<AnalyticsRemoteDataSource>(),
      ),
    );
  }
}
