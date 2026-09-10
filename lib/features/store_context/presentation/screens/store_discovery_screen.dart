import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/store_context_cubit.dart';
import '../../domain/repositories/store_repository.dart';

class StoreDiscoveryScreen extends StatefulWidget {
  final String? initialSlug;
  const StoreDiscoveryScreen({super.key, this.initialSlug});

  @override
  State<StoreDiscoveryScreen> createState() => _StoreDiscoveryScreenState();
}

class _StoreDiscoveryScreenState extends State<StoreDiscoveryScreen> {
  final _slugController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialSlug != null) {
      _slugController.text = widget.initialSlug!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resolveStore();
      });
    }
  }

  Future<void> _resolveStore() async {
    final slug = _slugController.text.trim();
    if (slug.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = context.read<StoreRepository>();
      final store = await repository.getStoreBySlug(slug);
      
      if (mounted) {
        // Set active store
        context.read<StoreContextCubit>().setActiveStore(store.id);
        // Route to home
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Store not found. Please check the URL or slug.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Store'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter a Store Link or Slug',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _slugController,
              decoration: InputDecoration(
                hintText: 'e.g. my-awesome-store',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _resolveStore(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _resolveStore,
              child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Enter Store'),
            ),
            const SizedBox(height: 48),
            TextButton(
              onPressed: () {
                context.go('/business-onboarding');
              },
              child: const Text('Are you a merchant? Create a store'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _slugController.dispose();
    super.dispose();
  }
}
