import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de selección de rol (Cajero o Patrón)
///
/// Permite al usuario autenticado seleccionar su rol en el sistema:
/// - **Cajero**: Usuario operativo que registra ventas, gastos y realiza cortes
/// - **Patrón**: Usuario administrativo (dueño) que gestiona el negocio
///
/// Según el rol seleccionado, redirige al flujo correspondiente:
/// - Cajero → escaneo de código QR para vincularse al negocio
/// - Patrón → dashboard de gestión
///
/// **Validates: Requirements 2.1, 2.6**
///
/// **Subtask 13.2:** Crear `RoleSelectionPage` con opciones "Cajero" y "Patrón",
/// navegando a `/qr-scan` o `/patron/dashboard` según la selección.
class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado
              const Text(
                '¿Cuál es tu rol?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Selecciona tu rol para continuar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // Opción Cajero
              _buildRoleCard(
                context: context,
                icon: Icons.point_of_sale,
                iconColor: Colors.blue,
                title: 'Cajero',
                description: 'Registra ventas, gastos y realiza cortes de caja',
                onTap: () {
                  // AC 2.1, 2.2: Al seleccionar Cajero, navegar a escaneo QR
                  context.go('/qr-scan');
                },
              ),

              const SizedBox(height: 24),

              // Opción Patrón
              _buildRoleCard(
                context: context,
                icon: Icons.business_center,
                iconColor: Colors.orange,
                title: 'Propietario',
                description:
                    'Gestiona tu negocio, equipo, productos y reportes',
                onTap: () {
                  // AC 2.6: Al seleccionar Propietario, navegar a dashboard
                  context.go('/patron/dashboard');
                },
              ),

              const SizedBox(height: 48),

              // Botón para cerrar sesión (opcional)
              TextButton(
                onPressed: () {
                  // Regresar a login (el usuario puede cambiar de cuenta)
                  context.go('/login');
                },
                child: const Text(
                  'Usar otra cuenta',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye una tarjeta de selección de rol
  ///
  /// **Parameters:**
  /// - context: BuildContext para navegación
  /// - icon: Ícono representativo del rol
  /// - iconColor: Color del ícono
  /// - title: Nombre del rol
  /// - description: Descripción breve del rol
  /// - onTap: Callback al presionar la tarjeta
  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Ícono
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: iconColor),
              ),
              const SizedBox(height: 16),

              // Título
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Descripción
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
