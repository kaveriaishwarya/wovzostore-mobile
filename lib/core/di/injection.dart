import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../features/analytics/data/datasources/analytics_remote_datasource.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/presentation/bloc/sales_cubit.dart';
import '../../features/analytics/presentation/bloc/product_performance_cubit.dart';
import '../../features/analytics/presentation/bloc/category_brand_cubit.dart';
import '../../features/analytics/presentation/bloc/customer_analytics_cubit.dart';
import '../../features/analytics/presentation/bloc/inventory_report_cubit.dart';

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

  // Register Analytics Cubits
  if (!sl.isRegistered<SalesCubit>()) {
    sl.registerFactory<SalesCubit>(
      () => SalesCubit(repository: sl<AnalyticsRepository>()),
    );
  }

  if (!sl.isRegistered<ProductPerformanceCubit>()) {
    sl.registerFactory<ProductPerformanceCubit>(
      () => ProductPerformanceCubit(repository: sl<AnalyticsRepository>()),
    );
  }

  if (!sl.isRegistered<CategoryBrandCubit>()) {
    sl.registerFactory<CategoryBrandCubit>(
      () => CategoryBrandCubit(repository: sl<AnalyticsRepository>()),
    );
  }

  if (!sl.isRegistered<CustomerAnalyticsCubit>()) {
    sl.registerFactory<CustomerAnalyticsCubit>(
      () => CustomerAnalyticsCubit(repository: sl<AnalyticsRepository>()),
    );
  }

  if (!sl.isRegistered<InventoryReportCubit>()) {
    sl.registerFactory<InventoryReportCubit>(
      () => InventoryReportCubit(repository: sl<AnalyticsRepository>()),
    );
  }
}
