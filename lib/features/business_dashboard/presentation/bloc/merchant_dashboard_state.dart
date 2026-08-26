import 'package:equatable/equatable.dart';
import '../../../analytics/data/models/dashboard_summary_model.dart';

enum MerchantDashboardStatus { initial, loading, success, error }

class MerchantDashboardState extends Equatable {
  final MerchantDashboardStatus status;
  final DashboardSummaryModel? summary;
  final String? errorMessage;

  const MerchantDashboardState({
    this.status = MerchantDashboardStatus.initial,
    this.summary,
    this.errorMessage,
  });

  bool get isLoading => status == MerchantDashboardStatus.loading;
  bool get isSuccess => status == MerchantDashboardStatus.success;
  bool get isError => status == MerchantDashboardStatus.error;

  MerchantDashboardState copyWith({
    MerchantDashboardStatus? status,
    DashboardSummaryModel? summary,
    String? errorMessage,
  }) {
    return MerchantDashboardState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, summary, errorMessage];
}
