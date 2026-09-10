import 'package:equatable/equatable.dart';

enum CustomerOnboardingStatus { initial, loading, success, error }

class CustomerOnboardingState extends Equatable {
  final CustomerOnboardingStatus status;
  final String? errorMessage;
  final String? onboardedStoreId;

  const CustomerOnboardingState({
    this.status = CustomerOnboardingStatus.initial,
    this.errorMessage,
    this.onboardedStoreId,
  });

  CustomerOnboardingState copyWith({
    CustomerOnboardingStatus? status,
    String? errorMessage,
    String? onboardedStoreId,
  }) {
    return CustomerOnboardingState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      onboardedStoreId: onboardedStoreId ?? this.onboardedStoreId,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, onboardedStoreId];
}
