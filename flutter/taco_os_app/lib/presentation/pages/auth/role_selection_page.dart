import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../../domain/entities/user.dart';

/// Pantalla de selección de rol para usuarios nuevos
///
/// Se muestra cuando el backend indica que el usuario no existe (UserNotFound).
/// El usuario elige su rol y se registra en el backend:
/// - **Cajero**: se registra con rol 'cajero' → escaneo QR para vincularse
/// - **Propietario**: se registra con rol 'dueño' → dashboard de gestión
///
/// Flujo:
/// 1. Login ve UserNotFound → navega aquí con datos de Google en el state
/// 2. Usuario selecciona rol
/// 3. Se dispatcha RegisterUserRequested con el rol
/// 4. BLoC llama POST /auth/registrar → emite Authenticated
/// 5. Login detecta Authenticated → navega al dashboard
///
/// **Validates: Requirements 2.1, 2.6**
class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Registro completado → navegar según rol
            if (state.user.role == UserRole.dueno) {
              context.go('/patron/dashboard');
            } else {
              context.go('/qr-scan');
            }
          }
        },
        builder: (context, state) {
          // Obtener datos de Google del estado UserNotFound
          String idGoogle = '';
          String email = '';
          String displayName = '';

          if (state is UserNotFound) {
            idGoogle = state.idGoogle;
            email = state.email;
            displayName = state.displayName;
          }

          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                    isLoading: isLoading,
                    onTap: () {
                      context.read<AuthBloc>().add(RegisterUserRequested(
                        idGoogle: idGoogle,
                        nickname: displayName,
                        email: email,
                        role: 'cajero',
                      ));
                    },
                  ),

                  const SizedBox(height: 24),

                  // Opción Propietario
                  _buildRoleCard(
                    context: context,
                    icon: Icons.business_center,
                    iconColor: Colors.orange,
                    title: 'Propietario',
                    description: 'Gestiona tu negocio, equipo, productos y reportes',
                    isLoading: isLoading,
                    onTap: () {
                      context.read<AuthBloc>().add(RegisterUserRequested(
                        idGoogle: idGoogle,
                        nickname: displayName,
                        email: email,
                        role: 'dueño',
                      ));
                    },
                  ),

                  const SizedBox(height: 48),

                  TextButton(
                    onPressed: isLoading ? null : () => context.go('/login'),
                    child: const Text(
                      'Usar otra cuenta',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: iconColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
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
