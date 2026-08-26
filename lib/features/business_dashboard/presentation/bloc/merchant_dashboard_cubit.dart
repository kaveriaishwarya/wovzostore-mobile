import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../../analytics/domain/repositories/analytics_repository.dart';
import 'merchant_dashboard_state.dart';

class MerchantDashboardCubit extends Cubit<MerchantDashboardState> {
  final AnalyticsRepository _repository;

  MerchantDashboardCubit({required AnalyticsRepository repository})
      : _repository = repository,
        super(const MerchantDashboardState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: MerchantDashboardStatus.loading));

    try {
      final summary = await _repository.getDashboardSummary();
      emit(state.copyWith(
        status: MerchantDashboardStatus.success,
        summary: summary,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: MerchantDashboardStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantDashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
