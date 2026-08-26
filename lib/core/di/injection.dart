import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get_it/get_it.dart';

import '../config/api_config.dart';
import '../network/auth_interceptor.dart';
import '../storage/secure_storage_service.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';

import '../../features/analytics/data/datasources/analytics_remote_datasource.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/data/services/analytics_csv_export_service.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/presentation/bloc/sales_cubit.dart';
import '../../features/analytics/presentation/bloc/product_performance_cubit.dart';
import '../../features/analytics/presentation/bloc/category_brand_cubit.dart';
import '../../features/analytics/presentation/bloc/customer_analytics_cubit.dart';
import '../../features/analytics/presentation/bloc/inventory_report_cubit.dart';
import '../../features/catalog/data/datasources/catalog_remote_datasource.dart';
import '../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/presentation/bloc/catalog_cubit.dart';
import '../../features/catalog/presentation/bloc/product_details_cubit.dart';
import '../../features/catalog/presentation/bloc/product_list_cubit.dart';

final GetIt sl = GetIt.instance;

void setupCoreInjection({
  ApiConfig? config,
  SecureStorageService? storageService,
  Dio? dioInstance,
  void Function()? onSessionExpired,
}) {
  // 1. Register ApiConfig
  if (!sl.isRegistered<ApiConfig>()) {
    sl.registerLazySingleton<ApiConfig>(() => config ?? const ApiConfig());
  }

  // 2. Register SecureStorageService
  if (!sl.isRegistered<SecureStorageService>()) {
    sl.registerLazySingleton<SecureStorageService>(
      () => storageService ?? SecureStorageServiceImpl(),
    );
  }

  // 3. Register Dio Core Client
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() {
      if (dioInstance != null) return dioInstance;

      final apiConfig = sl<ApiConfig>();
      final dio = Dio(
        BaseOptions(
          baseUrl: apiConfig.baseUrl,
          connectTimeout: apiConfig.connectTimeout,
          receiveTimeout: apiConfig.receiveTimeout,
          sendTimeout: apiConfig.sendTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Dedicated refresh Dio instance without interceptor to prevent recursion
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: apiConfig.baseUrl,
          connectTimeout: apiConfig.connectTimeout,
          receiveTimeout: apiConfig.receiveTimeout,
          sendTimeout: apiConfig.sendTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Development self-signed SSL certificate bypass
      if (apiConfig.allowSelfSignedCertificate) {
        final adapter = IOHttpClientAdapter(
          createHttpClient: () {
            final client = HttpClient();
            client.badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;
            return client;
          },
        );
        dio.httpClientAdapter = adapter;
        refreshDio.httpClientAdapter = adapter;
      }

      // Add AuthInterceptor to primary Dio client
      dio.interceptors.add(
        AuthInterceptor(
          secureStorage: sl<SecureStorageService>(),
          refreshDio: refreshDio,
          onSessionExpired: onSessionExpired,
        ),
      );

      return dio;
    });
  }
}

void setupAnalyticsInjection({Dio? dioInstance}) {
  // Ensure core injection is initialized first
  setupCoreInjection(dioInstance: dioInstance);

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

  // Register Analytics CSV Export Service
  if (!sl.isRegistered<AnalyticsCsvExportService>()) {
    sl.registerLazySingleton<AnalyticsCsvExportService>(
      () => AnalyticsCsvExportServiceImpl(),
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

void setupAuthInjection({Dio? dioInstance}) {
  setupCoreInjection(dioInstance: dioInstance);

  if (!sl.isRegistered<AuthRemoteDataSource>()) {
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(dio: sl<Dio>()),
    );
  }

  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl<AuthRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<AuthCubit>()) {
    sl.registerLazySingleton<AuthCubit>(
      () => AuthCubit(
        repository: sl<AuthRepository>(),
        secureStorage: sl<SecureStorageService>(),
      ),
    );
  }
}

void setupCatalogInjection({Dio? dioInstance}) {
  setupCoreInjection(dioInstance: dioInstance);

  if (!sl.isRegistered<CatalogRemoteDataSource>()) {
    sl.registerLazySingleton<CatalogRemoteDataSource>(
      () => CatalogRemoteDataSourceImpl(dio: sl<Dio>()),
    );
  }

  if (!sl.isRegistered<CatalogRepository>()) {
    sl.registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(
        remoteDataSource: sl<CatalogRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<CatalogCubit>()) {
    sl.registerFactory<CatalogCubit>(
      () => CatalogCubit(repository: sl<CatalogRepository>()),
    );
  }

  if (!sl.isRegistered<ProductListCubit>()) {
    sl.registerFactory<ProductListCubit>(
      () => ProductListCubit(repository: sl<CatalogRepository>()),
    );
  }

  if (!sl.isRegistered<ProductDetailsCubit>()) {
    sl.registerFactory<ProductDetailsCubit>(
      () => ProductDetailsCubit(repository: sl<CatalogRepository>()),
    );
  }
}

/// Root DI setup method calling core and feature setup.
void setupInjection({
  ApiConfig? config,
  SecureStorageService? storageService,
  Dio? dioInstance,
  void Function()? onSessionExpired,
}) {
  setupCoreInjection(
    config: config,
    storageService: storageService,
    dioInstance: dioInstance,
    onSessionExpired: onSessionExpired,
  );
  setupAnalyticsInjection(dioInstance: dioInstance);
  setupAuthInjection(dioInstance: dioInstance);
  setupCatalogInjection(dioInstance: dioInstance);
}
