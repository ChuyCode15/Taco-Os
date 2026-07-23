import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../injection_container.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/cajero/cajero_bloc_exports.dart';
import 'blocs/cajero/gastos_bloc.dart';
import 'blocs/patron/patron_bloc.dart';
import 'router/app_router.dart';

/// Root application widget for Taco'Os App.
///
/// Provides all necessary BLoCs to the widget tree and configures
/// MaterialApp.router with the centralized AppRouter instance.
///
/// **Validates: Requirement 13.1** - Clean Architecture with proper DI
/// **Validates: Requirement 13.5** - Dependency injection via service locator
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Get router from service locator
    final router = sl<AppRouter>().router;

    return MultiBlocProvider(
      providers: [
        // Auth BLoC - Manages authentication lifecycle
        // Requirements 1.1, 1.3, 1.5, 1.6, 1.7, 1.9
        BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),

        // Cajero BLoC - Manages cash session lifecycle
        // Requirements 3.1, 3.2, 3.5
        BlocProvider<CajeroBloc>(create: (context) => sl<CajeroBloc>()),

        // Sync Status BLoC - Visual sync indicator for Modo_Cajero
        // Requirement 10.10
        BlocProvider<SyncStatusBloc>(create: (context) => sl<SyncStatusBloc>()),

        // Gastos BLoC - Manages expense registration
        // Requirements 7.1, 7.2, 7.3, 7.4, 7.5, 7.6
        BlocProvider<GastosBloc>(create: (context) => sl<GastosBloc>()),

        // Patron BLoC - Manages patron dashboard
        // Requirements 12.1, 12.2, 12.3, 12.4, 12.5
        BlocProvider<PatronBloc>(create: (context) => sl<PatronBloc>()),

        // TODO: Additional BLoCs to be added when implemented
        // VentasBloc - Requirements 5.1-5.10, 6.1-6.7
        // CorteBloc - Requirements 9.1-9.9
      ],
      child: MaterialApp.router(
        title: 'Taco\'Os',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: true,
          // Theme customization can be added here
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
