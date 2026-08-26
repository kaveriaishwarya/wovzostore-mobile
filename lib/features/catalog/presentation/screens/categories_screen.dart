import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/catalog_cubit.dart';
import '../bloc/catalog_state.dart';

class CategoriesScreen extends StatelessWidget {
  final void Function(String categoryId, String categoryName)? onCategoryTap;

  const CategoriesScreen({super.key, this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Categories'),
        centerTitle: true,
      ),
      body: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) {
          if (state.isLoading && state.categoryTree.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.isError && state.categoryTree.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage ?? 'Failed to load categories'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<CatalogCubit>().loadCatalog(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.categoryTree.isEmpty) {
            return const Center(child: Text('No categories found'));
          }

          return ListView.builder(
            itemCount: state.categoryTree.length,
            itemBuilder: (context, index) {
              final cat = state.categoryTree[index];
              if (cat.children.isNotEmpty) {
                return ExpansionTile(
                  leading: const Icon(Icons.category_outlined),
                  title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: cat.children.map((child) {
                    return ListTile(
                      contentPadding: const EdgeInsets.only(left: 32, right: 16),
                      title: Text(child.name),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => onCategoryTap?.call(child.id, child.name),
                    );
                  }).toList(),
                );
              }

              return ListTile(
                leading: const Icon(Icons.category_outlined),
                title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => onCategoryTap?.call(cat.id, cat.name),
              );
            },
          );
        },
      ),
    );
  }
}
