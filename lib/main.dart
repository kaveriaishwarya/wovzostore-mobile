import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wovzo_mobile/core/di/injection.dart';
import 'package:wovzo_mobile/core/router/app_router.dart';
import 'package:wovzo_mobile/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:wovzo_mobile/features/auth/presentation/bloc/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize DI Infrastructure
  setupInjection();

  // Restore session foundation
  final authCubit = sl<AuthCubit>();
  authCubit.restoreSession();

  runApp(MyApp(authCubit: authCubit));
}

class MyApp extends StatelessWidget {
  final AuthCubit? authCubit;

  const MyApp({super.key, this.authCubit});

  @override
  Widget build(BuildContext context) {
    final activeCubit = authCubit ?? (sl.isRegistered<AuthCubit>() ? sl<AuthCubit>() : null);

    if (activeCubit == null) {
      return MaterialApp.router(
        title: 'Wovzo Store',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.createRouter(),
      );
    }

    return BlocProvider<AuthCubit>.value(
      value: activeCubit,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state.isCheckingSession || state.status == AuthStatus.initial) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          return MaterialApp.router(
            title: 'Wovzo Store',
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.createRouter(authCubit: activeCubit),
          );
        },
      ),
    );
  }
}
