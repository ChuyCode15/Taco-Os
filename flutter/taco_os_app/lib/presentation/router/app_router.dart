import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_session_repository.dart';

// Import real page implementations
import '../pages/splash/splash_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/role_selection_page.dart';
import '../pages/cajero/qr_scan_page.dart';
import '../pages/cajero/open_session_page.dart';
import '../pages/cajero/cajero_home_page.dart';
import '../pages/cajero/ventas/sale_confirmation_page.dart';
import '../pages/cajero/ventas/sale_cancellation_camera_page.dart';
import '../pages/cajero/como_voy/shift_summary_page.dart';
import '../pages/cajero/corte/cash_count_page.dart';
import '../pages/cajero/corte/corte_summary_page.dart';
import '../pages/cajero/corte/ticket_page.dart';
import '../pages/patron/patron_dashboard_page.dart';
import '../pages/patron/ventas/patron_ventas_page.dart';
import '../pages/patron/reportes/reportes_page.dart';
import '../pages/patron/equipo/equipo_page.dart';
import '../pages/patron/configuracion/configuracion_page.dart';

/// Router central de la aplicación Taco'Os con guards de autenticación y rol
///
/// Configura todas las rutas de la app usando go_router con las siguientes protecciones:
/// - AuthGuard: Redirige a /login si no hay sesión activa
/// - TurnoGuard: Redirige a /cajero/open-session si no hay turno activo
/// - RoleGuard: Redirige según el rol del usuario (cajero vs patron)
///
/// Validado por Requirement 2.1: Selección de Rol y Vinculación
/// Validado por Requirement 3.5: Apertura de Caja requerida para Modo_Cajero
/// Validado por Requirement 4.1: Modo Cajero — Interfaz de 3 Botones
class AppRouter {
  final IAuthRepository authRepository;
  final ISessionRepository sessionRepository;

  AppRouter({required this.authRepository, required this.sessionRepository});

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash route
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),

      // Auth routes
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionPage(),
      ),
      GoRoute(
        path: '/qr-scan',
        builder: (context, state) => const QRScanPage(),
      ),

      // Cajero routes
      GoRoute(
        path: '/cajero/open-session',
        builder: (context, state) => const OpenSessionPage(),
      ),
      GoRoute(
        path: '/cajero/home',
        redirect: _turnoGuard,
        builder: (context, state) => const CajeroHomePage(),
      ),

      // Cajero - Ventas flow
      GoRoute(
        path: '/cajero/ventas/categories',
        redirect: _turnoGuard,
        builder: (context, state) => const CategorySelectionPage(),
      ),
      GoRoute(
        path: '/cajero/ventas/products/:category',
        redirect: _turnoGuard,
        builder: (context, state) {
          final category = state.pathParameters['category'] ?? '';
          return ProductListPage(category: category);
        },
      ),
      GoRoute(
        path: '/cajero/ventas/quantity',
        redirect: _turnoGuard,
        builder: (context, state) => const QuantityKeypadPage(),
      ),
      GoRoute(
        path: '/cajero/ventas/confirm',
        redirect: _turnoGuard,
        builder: (context, state) => const SaleConfirmationPage(),
      ),
      GoRoute(
        path: '/cajero/ventas/cancellation-camera',
        redirect: _turnoGuard,
        builder: (context, state) => const SaleCancellationCameraPage(),
      ),

      // Cajero - Como voy
      GoRoute(
        path: '/cajero/como-voy',
        redirect: _turnoGuard,
        builder: (context, state) => const ShiftSummaryPage(),
      ),

      // Cajero - Corte flow
      GoRoute(
        path: '/cajero/corte/count',
        redirect: _turnoGuard,
        builder: (context, state) => const CashCountPage(),
      ),
      GoRoute(
        path: '/cajero/corte/summary',
        redirect: _turnoGuard,
        builder: (context, state) => const CorteSummaryPage(),
      ),
      GoRoute(
        path: '/cajero/corte/ticket',
        redirect: _turnoGuard,
        builder: (context, state) => const TicketPage(),
      ),

      // Patron routes
      GoRoute(
        path: '/patron/dashboard',
        redirect: (context, state) =>
            _roleGuard(context, state, UserRole.patron),
        builder: (context, state) {
          final businessId = state.uri.queryParameters['businessId'] ?? '';
          return PatronDashboardPage(businessId: businessId);
        },
      ),
      GoRoute(
        path: '/patron/ventas',
        redirect: (context, state) =>
            _roleGuard(context, state, UserRole.patron),
        builder: (context, state) {
          final businessId = state.uri.queryParameters['businessId'] ?? '';
          return PatronVentasPage(businessId: businessId);
        },
      ),
      GoRoute(
        path: '/patron/reportes',
        redirect: (context, state) =>
            _roleGuard(context, state, UserRole.patron),
        builder: (context, state) {
          final businessId = state.uri.queryParameters['businessId'] ?? '';
          return ReportesPage(businessId: businessId);
        },
      ),
      GoRoute(
        path: '/patron/equipo',
        redirect: (context, state) =>
            _roleGuard(context, state, UserRole.patron),
        builder: (context, state) {
          final businessId = state.uri.queryParameters['businessId'] ?? '';
          return EquipoPage(businessId: businessId);
        },
      ),
      GoRoute(
        path: '/patron/configuracion',
        redirect: (context, state) =>
            _roleGuard(context, state, UserRole.patron),
        builder: (context, state) {
          final businessId = state.uri.queryParameters['businessId'] ?? '';
          return ConfiguracionPage(businessId: businessId);
        },
      ),
    ],
  );

  /// TurnoGuard — verifica que el cajero tenga un turno activo
  ///
  /// Validado por Requirement 3.5: Bloquear acceso sin turno activo
  Future<String?> _turnoGuard(BuildContext context, GoRouterState state) async {
    // First check authentication
    final userResult = await authRepository.getCurrentUser();

    return await userResult.fold((failure) async => '/login', (user) async {
      if (user == null) {
        return '/login';
      }

      if (user.businessId == null) {
        return '/role-selection';
      }

      // Check if cajero has active session
      if (user.role == UserRole.cajero) {
        final sessionResult = await sessionRepository.getActiveSession(
          user.businessId!,
        );

        return sessionResult.fold(
          (failure) => '/cajero/open-session',
          (session) => session == null ? '/cajero/open-session' : null,
        );
      }

      // Not a cajero (shouldn't happen for cajero routes)
      return '/patron/dashboard';
    });
  }

  /// RoleGuard — verifica que el usuario tenga el rol correcto
  ///
  /// Validado por Requirement 2.1: Redirigir según rol almacenado
  Future<String?> _roleGuard(
    BuildContext context,
    GoRouterState state,
    UserRole requiredRole,
  ) async {
    final userResult = await authRepository.getCurrentUser();

    return userResult.fold((failure) => '/login', (user) {
      if (user == null) {
        return '/login';
      }

      if (user.businessId == null) {
        return '/role-selection';
      }

      if (user.role != requiredRole) {
        // Redirect to appropriate home based on actual role
        return user.role == UserRole.cajero
            ? '/cajero/home'
            : '/patron/dashboard';
      }

      return null; // User has correct role
    });
  }
}

/// Placeholder: Category selection page for sales
class CategorySelectionPage extends StatelessWidget {
  const CategorySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar Categoría')),
      body: const Center(
        child: Text('CategorySelectionPage - TODO: Show categories'),
      ),
    );
  }
}

/// Placeholder: Product list page for a category
class ProductListPage extends StatelessWidget {
  final String category;

  const ProductListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Productos - $category')),
      body: Center(
        child: Text('ProductListPage - TODO: Show products for $category'),
      ),
    );
  }
}

/// Placeholder: Quantity keypad page
class QuantityKeypadPage extends StatelessWidget {
  const QuantityKeypadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingresar Cantidad')),
      body: const Center(
        child: Text('QuantityKeypadPage - TODO: Implement numeric keypad'),
      ),
    );
  }
}

// Removed placeholder - TicketPage is now implemented in its own file
// Removed placeholder - ConfiguracionPage is now implemented in its own file
