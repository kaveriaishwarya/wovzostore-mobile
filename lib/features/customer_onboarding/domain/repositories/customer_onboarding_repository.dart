import 'package:wovzo_mobile/features/customer_onboarding/data/datasources/customer_remote_datasource.dart';

abstract class CustomerOnboardingRepository {
  Future<void> onboardCustomer();
}

class CustomerOnboardingRepositoryImpl implements CustomerOnboardingRepository {
  final CustomerRemoteDataSource _remoteDataSource;

  CustomerOnboardingRepositoryImpl({
    required CustomerRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<void> onboardCustomer() async {
    await _remoteDataSource.onboardCustomer();
  }
}
