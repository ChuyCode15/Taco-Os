import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'widgets/login_carousel.dart';

/// Pantalla de inicio de sesión con diseño moderno
///
/// Presenta dos opciones principales:
/// - "Quiero ser cliente" (REGISTRO) - botón primario azul
/// - "Soy cliente" (LOGIN) - botón secundario blanco/gris
///
/// Ambos botones ejecutan Google Sign-In con diferentes flags:
/// - Registro envía isRegistration: true
/// - Login envía isRegistration: false
///
/// **Validates: Requirements 1.1, 1.3, 1.4, 1.5**
///
/// **Subtask 13.1.1:** Actualizar LoginPage con diseño moderno y flujo
/// de registro/login con dos botones diferenciados.
///
/// Diseño visual:
/// - Fondo degradado azul/turquesa (#00BCD4 a #0097A7)
/// - Logo "Taco'Os" en la parte superior
/// - Sección de contenido visual (ilustración o placeholder)
/// - Dos botones principales con estilos diferenciados
/// - Opción "Explorar sin registrarme" opcional al final
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // AC 1.2: Redirigir a selección de rol tras autenticación exitosa
          if (state is Authenticated) {
            context.go('/role-selection');
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Fondo: carrusel fullscreen
              const Positioned.fill(child: LoginCarousel()),
              // Overlay con degradado para contraste
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ),
              // Header arriba
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Center(child: _buildHeader()),
              ),
              // Botones y estados abajo
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionButtons(context, state),
                      const SizedBox(height: 16),
                      _buildExploreLinkOption(context),
                      const SizedBox(height: 16),
                      if (state is AuthError) _buildErrorMessage(state),
                      if (state is AuthLoading) _buildLoadingIndicator(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Construye el header con el logo "Taco'Os"
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo con tipografía moderna y redondeada
        Text(
          'Taco\'Os',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gestión inteligente para tu taquería',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  /// Construye los botones de acción principales
  ///
  /// **Validates: Requirements 1.1, 1.5**
  ///
  /// Los botones se deshabilitan durante:
  /// - Carga (AuthLoading)
  /// - Bloqueo de 30 segundos tras 3 intentos fallidos
  Widget _buildActionButtons(BuildContext context, AuthState state) {
    final bool isDisabled =
        state is AuthLoading || (state is AuthError && state.isBlocked);

    return Column(
      children: [
        // Botón "Quiero ser cliente" (REGISTRO) - Primario azul
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isDisabled
                ? null
                : () {
                    // Disparar evento con flag isRegistration: true
                    context.read<AuthBloc>().add(
                      const SignInRequested(isRegistration: true),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2), // Azul más oscuro
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Text(
              isDisabled && state is AuthError && state.isBlocked
                  ? 'Bloqueado (${state.blockedSecondsRemaining}s)'
                  : 'Quiero ser cliente',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Botón "Soy cliente" (LOGIN) - Secundario blanco/gris
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: isDisabled
                ? null
                : () {
                    // Disparar evento con flag isRegistration: false
                    context.read<AuthBloc>().add(
                      const SignInRequested(isRegistration: false),
                    );
                  },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              foregroundColor: const Color(0xFF1976D2),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isDisabled && state is AuthError && state.isBlocked
                  ? 'Bloqueado (${state.blockedSecondsRemaining}s)'
                  : 'Soy cliente',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  /// Construye la opción "Explorar sin registrarme" (opcional)
  Widget _buildExploreLinkOption(BuildContext context) {
    return TextButton(
      onPressed: () {
        // Navegar a modo demo o ignorar
        // Por ahora, solo mostramos el botón sin funcionalidad
      },
      child: Text(
        'Tienes algun error, Contactanos',
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.8),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  /// Construye el mensaje de error descriptivo
  ///
  /// **Validates: Requirements 1.3, 1.5**
  ///
  /// Muestra:
  /// - Mensaje de error descriptivo según el tipo de fallo
  /// - Contador de intentos (1/3, 2/3)
  /// - Cuenta regresiva durante el bloqueo de 30 segundos
  Widget _buildErrorMessage(AuthError state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(
            state.isBlocked ? Icons.lock_clock : Icons.error_outline,
            color: Colors.red.shade700,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el indicador de carga
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          SizedBox(width: 16),
          Text(
            'Iniciando sesión...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
