import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taco_os_app/injection_container.dart' as di;
import 'package:taco_os_app/presentation/blocs/cajero/sync_status_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/sync_status_state.dart';
import 'package:taco_os_app/presentation/blocs/cajero/sync_status_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_state.dart';
import 'package:taco_os_app/presentation/blocs/cajero/gastos_bloc.dart';
import 'package:taco_os_app/presentation/pages/cajero/gastos/expense_dialog.dart';

/// Pantalla principal del Modo Cajero con 3 botones fijos en el footer
///
/// Interfaz radical simplificada para operación rápida durante el turno:
/// - Botón "Ventas": Navega a `/cajero/ventas/categories`
/// - Botón "Gastos": Muestra modal ExpenseDialog sobre la home
/// - Botón "¿Cómo voy?": Navega a `/cajero/como-voy`
///
/// **Features:**
/// - Pantalla completa sin navegación secundaria ni menús adicionales
/// - Indicador visual de SyncStatusBloc en el header
/// - Back desde sub-flujos regresa aquí sin acciones adicionales
/// - Renderiza en < 300ms después de apertura de caja
///
/// **Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 10.10**
class CajeroHomePage extends StatefulWidget {
  const CajeroHomePage({super.key});

  @override
  State<CajeroHomePage> createState() => _CajeroHomePageState();
}

class _CajeroHomePageState extends State<CajeroHomePage> {
  @override
  void initState() {
    super.initState();
    // Iniciar la verificación del estado de sincronización con el sessionId del turno activo
    _checkSyncStatus();
  }

  /// Dispara CheckSyncStatus cuando tenemos el sessionId del turno activo
  void _checkSyncStatus() {
    final cajeroState = context.read<CajeroBloc>().state;
    if (cajeroState is TurnoActivo) {
      context.read<SyncStatusBloc>().add(
        CheckSyncStatus(sessionId: cajeroState.session.id),
      );
    }
  }

  /// Muestra el ExpenseDialog como modal sobre la home
  ///
  /// **Validates: Requirement 4.4**
  void _showExpenseDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (_) => di.sl<GastosBloc>(),
        child: const ExpenseDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Cajero'),
        centerTitle: true,
        // Indicador visual de SyncStatusBloc en el header
        // **Validates: Requirement 10.10**
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BlocBuilder<SyncStatusBloc, SyncStatusState>(
              builder: (context, state) {
                return _buildSyncIndicator(state);
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono decorativo principal
              const Icon(Icons.point_of_sale, size: 120, color: Colors.blue),
              const SizedBox(height: 24),

              // Título de bienvenida
              const Text(
                '¡Bienvenido!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Subtítulo
              const Text(
                'Selecciona una opción para continuar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      // Footer con exactamente 3 botones fijos
      // **Validates: Requirements 4.1, 4.2**
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón 1: Ventas
              // **Validates: Requirement 4.3**
              Expanded(
                child: _buildFooterButton(
                  icon: Icons.shopping_cart,
                  label: 'Ventas',
                  color: Colors.green,
                  onPressed: () => context.go('/cajero/ventas/categories'),
                ),
              ),
              const SizedBox(width: 12),

              // Botón 2: Gastos
              // **Validates: Requirement 4.4**
              Expanded(
                child: _buildFooterButton(
                  icon: Icons.receipt_long,
                  label: 'Gastos',
                  color: Colors.orange,
                  onPressed: _showExpenseDialog,
                ),
              ),
              const SizedBox(width: 12),

              // Botón 3: ¿Cómo voy?
              // **Validates: Requirement 4.5**
              Expanded(
                child: _buildFooterButton(
                  icon: Icons.analytics,
                  label: '¿Cómo voy?',
                  color: Colors.blue,
                  onPressed: () => context.go('/cajero/como-voy'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye un botón del footer con icono, label y color
  Widget _buildFooterButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Construye el indicador visual de estado de sincronización
  ///
  /// Estados:
  /// - ✅ Sincronizado (verde): Todos los registros con is_synced = true
  /// - 🔄 Pendiente (naranja): Al menos uno con is_synced = false y hay conectividad
  /// - 📴 Sin conexión (rojo): Sin conectividad de red
  ///
  /// **Validates: Requirement 10.10**
  Widget _buildSyncIndicator(SyncStatusState state) {
    final IconData icon;
    final Color color;
    final String tooltip;

    switch (state) {
      case SyncSynced():
        icon = Icons.check_circle;
        color = Colors.green;
        tooltip = 'Sincronizado';
        break;
      case SyncPending():
        icon = Icons.sync;
        color = Colors.orange;
        tooltip = 'Pendiente (${state.pendingCount})';
        break;
      case SyncOffline():
        icon = Icons.cloud_off;
        color = Colors.red;
        tooltip = 'Sin conexión';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 4),
          Text(
            tooltip.split(' ').first, // Solo primera palabra
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
