import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wovzo_mobile/features/customer_onboarding/presentation/bloc/customer_onboarding_cubit.dart';
import 'package:wovzo_mobile/features/customer_onboarding/presentation/bloc/customer_onboarding_state.dart';
import 'package:wovzo_mobile/features/store_context/presentation/bloc/store_context_cubit.dart';
import 'package:wovzo_mobile/features/store_context/presentation/bloc/store_context_state.dart';

class CustomerOnboardingGate extends StatefulWidget {
  final Widget child;

  const CustomerOnboardingGate({super.key, required this.child});

  @override
  State<CustomerOnboardingGate> createState() => _CustomerOnboardingGateState();
}

class _CustomerOnboardingGateState extends State<CustomerOnboardingGate> {
  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  @override
  void didUpdateWidget(CustomerOnboardingGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkOnboarding();
  }

  void _checkOnboarding() {
    final storeState = context.read<StoreContextCubit>().state;
    if (storeState is StoreContextLoaded && storeState.activeStoreId != null) {
      final activeStoreId = storeState.activeStoreId!;
      final onboardingState = context.read<CustomerOnboardingCubit>().state;
      
      if (onboardingState.onboardedStoreId != activeStoreId && 
          onboardingState.status != CustomerOnboardingStatus.loading) {
        context.read<CustomerOnboardingCubit>().verifyAndOnboard(activeStoreId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoreContextCubit, StoreContextState>(
      listener: (context, storeState) {
        if (storeState is StoreContextLoaded && storeState.activeStoreId != null) {
           final activeStoreId = storeState.activeStoreId!;
           final onboardingState = context.read<CustomerOnboardingCubit>().state;
           if (onboardingState.onboardedStoreId != activeStoreId && 
               onboardingState.status != CustomerOnboardingStatus.loading) {
             context.read<CustomerOnboardingCubit>().verifyAndOnboard(activeStoreId);
           }
        }
      },
      builder: (context, storeState) {
        if (storeState is! StoreContextLoaded || storeState.activeStoreId == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return BlocBuilder<CustomerOnboardingCubit, CustomerOnboardingState>(
          builder: (context, onboardingState) {
            if (onboardingState.status == CustomerOnboardingStatus.loading ||
                onboardingState.status == CustomerOnboardingStatus.initial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (onboardingState.status == CustomerOnboardingStatus.error) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          onboardingState.errorMessage ?? 'Failed to access store.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                             if (storeState.activeStoreId != null) {
                               context.read<CustomerOnboardingCubit>().verifyAndOnboard(storeState.activeStoreId!);
                             }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Success: render the actual screen
            return widget.child;
          },
        );
      },
    );
  }
}
