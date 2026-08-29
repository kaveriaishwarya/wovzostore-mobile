import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/stock_movement_model.dart';
import '../bloc/stock_movement_cubit.dart';
import '../bloc/stock_movement_state.dart';

class StockMovementListScreen extends StatefulWidget {
  final StockMovementCubit? cubit;

  const StockMovementListScreen({
    super.key,
    this.cubit,
  });

  @override
  State<StockMovementListScreen> createState() => _StockMovementListScreenState();
}

class _StockMovementListScreenState extends State<StockMovementListScreen> {
  late final StockMovementCubit _cubit;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? sl<StockMovementCubit>();
    _cubit.loadStockMovements();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _cubit.loadMoreStockMovements();
    }
  }

  Color _getMovementTypeColor(StockMovementType type) {
    switch (type) {
      case StockMovementType.purchase:
        return Colors.green;
      case StockMovementType.sale:
        return Colors.blue;
      case StockMovementType.adjustment:
        return Colors.purple;
      case StockMovementType.returnType:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stock Movement Audit Log'),
        ),
        body: BlocBuilder<StockMovementCubit, StockMovementState>(
          builder: (context, state) {
            if (state is StockMovementLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is StockMovementError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _cubit.loadStockMovements(refresh: true),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is StockMovementLoaded) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('All Types'),
                            selected: state.movementTypeFilter == null,
                            onSelected: (_) {
                              _cubit.loadStockMovements(
                                variantId: state.variantIdFilter,
                                movementType: null,
                                refresh: true,
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                          ...StockMovementType.values.map((type) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: FilterChip(
                                label: Text(type.displayName),
                                selected: state.movementTypeFilter == type,
                                onSelected: (_) {
                                  _cubit.loadStockMovements(
                                    variantId: state.variantIdFilter,
                                    movementType: type,
                                    refresh: true,
                                  );
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: state.movements.isEmpty
                        ? const Center(child: Text('No stock movement logs found.'))
                        : RefreshIndicator(
                            onRefresh: () => _cubit.loadStockMovements(
                              variantId: state.variantIdFilter,
                              movementType: state.movementTypeFilter,
                              refresh: true,
                            ),
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(12),
                              itemCount: state.movements.length + (state.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= state.movements.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }

                                final item = state.movements[index];
                                final typeColor = _getMovementTypeColor(item.movementType);
                                final isPositive = item.quantityChange >= 0;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.variantName,
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Chip(
                                              label: Text(
                                                item.movementTypeName,
                                                style: const TextStyle(fontSize: 10, color: Colors.white),
                                              ),
                                              backgroundColor: typeColor,
                                              visualDensity: VisualDensity.compact,
                                            ),
                                          ],
                                        ),
                                        Text('SKU: ${item.sku}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Change: ${isPositive ? '+' : ''}${item.quantityChange}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isPositive ? Colors.green[800] : Colors.red[800],
                                              ),
                                            ),
                                            Text('Stock: ${item.previousQuantity} → ${item.newQuantity}'),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (item.referenceId != null)
                                              Text('Ref: ${item.referenceId}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                            Text(
                                              item.createdAt.toLocal().toString().split('.')[0],
                                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        if (item.notes != null && item.notes!.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text('Notes: ${item.notes}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
