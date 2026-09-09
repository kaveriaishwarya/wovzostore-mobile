import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/store_context_cubit.dart';
import '../bloc/store_context_state.dart';

class StoreSelectionScreen extends StatefulWidget {
  final String? redirect;

  const StoreSelectionScreen({super.key, this.redirect});

  @override
  State<StoreSelectionScreen> createState() => _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends State<StoreSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Start loading stores when this screen appears and is in initial state
    final cubit = context.read<StoreContextCubit>();
    if (cubit.state is StoreContextInitial) {
      cubit.loadStoresAndRestoreContext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Select Store'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          // Basic logout placeholder if they want to exit
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Contextually we do not trigger AuthCubit directly here to avoid tight coupling.
              // In production, the user could navigate back if allowed or have a dedicated settings route.
            },
            tooltip: 'Exit',
          )
        ],
      ),
      body: BlocBuilder<StoreContextCubit, StoreContextState>(
        builder: (context, state) {
          if (state is StoreContextInitial || state is StoreContextLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StoreContextError) {
            return _buildErrorState(state.message);
          } else if (state is StoreContextLoaded) {
            if (state.availableStores.isEmpty) {
              return const Center(
                child: Text('No stores available'),
              );
            }
            return _buildStoreList(state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<StoreContextCubit>().loadStoresAndRestoreContext();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreList(StoreContextLoaded state) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xFF1D4ED8);

    return ListView.separated(
      padding: const EdgeInsets.all(24.0),
      itemCount: state.availableStores.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final store = state.availableStores[index];
        final isActive = store.id == state.activeStoreId;

        return InkWell(
          onTap: () {
            context.read<StoreContextCubit>().setActiveStore(store.id);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? primaryColor : const Color(0xFFE2E8F0),
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isActive ? primaryColor.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                  radius: 24,
                  child: Text(
                    store.name.isNotEmpty ? store.name[0].toUpperCase() : 'S',
                    style: TextStyle(
                      color: isActive ? primaryColor : const Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Role: ${store.role}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  const Icon(
                    Icons.check_circle,
                    color: primaryColor,
                    size: 28,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
