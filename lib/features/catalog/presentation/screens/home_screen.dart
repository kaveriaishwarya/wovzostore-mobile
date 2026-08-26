import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/catalog_cubit.dart';
import '../bloc/catalog_state.dart';
import '../widgets/banner_carousel.dart';

class HomeScreen extends StatefulWidget {
  final void Function(String categoryId)? onCategoryTap;
  final VoidCallback? onSearchTap;
  final void Function(String productId)? onProductTap;

  const HomeScreen({
    super.key,
    this.onCategoryTap,
    this.onSearchTap,
    this.onProductTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<CatalogCubit>();
    if (cubit.state.status == CatalogStatus.initial) {
      cubit.loadCatalog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WOVZO STORE',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: widget.onSearchTap,
          ),
        ],
      ),
      body: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) {
          if (state.isLoading && state.banners.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.isError && state.banners.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'Failed to load catalog.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.read<CatalogCubit>().loadCatalog(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<CatalogCubit>().refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banners
                  if (state.banners.isNotEmpty) ...[
                    BannerCarousel(banners: state.banners),
                    const SizedBox(height: 16),
                  ],

                  // Category Header & List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Categories',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (state.categoryTree.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('No categories available'),
                    )
                  else
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: state.categoryTree.length,
                        itemBuilder: (context, index) {
                          final cat = state.categoryTree[index];
                          return GestureDetector(
                            onTap: () => widget.onCategoryTap?.call(cat.id),
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                                    child: Icon(
                                      Icons.category_outlined,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    cat.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Brands Section
                  if (state.brands.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Featured Brands',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: state.brands.length,
                        itemBuilder: (context, index) {
                          final brand = state.brands[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Chip(
                              label: Text(brand.name),
                              avatar: const Icon(Icons.branding_watermark_outlined, size: 16),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
