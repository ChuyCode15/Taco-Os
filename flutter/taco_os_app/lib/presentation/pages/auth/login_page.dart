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
/// Flujo de "Soy cliente":
/// 1. Google Sign-In → obtiene idGoogle
/// 2. GET /auth/verificar/{idGoogle}
/// 3. Si existe → va a /patron/dashboard
/// 4. Si no existe → va a /role-selection
///
/// Flujo de "Quiero ser cliente":
/// 1. Google Sign-In → obtiene idGoogle
/// 2. POST /auth/registrar con rol 'dueño'
/// 3. Almacena JWT → va a /patron/dashboard
///
/// **Validates: Requirements 1.1, 1.3, 1.4, 1.5**
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: _onStateChanged,
        builder: (context, state) {
          return Stack(
            children: [
              const Positioned.fill(child: LoginCarousel()),
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
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Center(child: _buildHeader()),
              ),
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

  /// Maneja los cambios de estado del AuthBloc
  ///
  /// Flujo de "Soy cliente":
  /// GoogleAuthenticated → dispara VerifyUserRequested → UserVerified o UserNotFound
  void _onStateChanged(BuildContext context, AuthState state) {
    if (state is Authenticated) {
      // Autenticación exitosa (ya sea login o registro) → dashboard
      context.go('/patron/dashboard');
    } else if (state is GoogleAuthenticated) {
      // Google Sign-In completado → verificar si usuario existe en backend
      context.read<AuthBloc>().add(VerifyUserRequested(
        idGoogle: state.idGoogle,
        email: state.email,
        displayName: state.displayName,
      ));
    } else if (state is UserNotFound) {
      // Usuario nuevo → ir a selección de rol para completar registro
      context.go('/role-selection');
    }
  }

  Widget _buildHeader() {
    return Column(
      children: [
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
  /// "Soy cliente": Google → verificar → dashboard si existe, registro si no
  /// "Quiero ser cliente": Google → registrar como dueño → dashboard
  Widget _buildActionButtons(BuildContext context, AuthState state) {
    final bool isDisabled =
        state is AuthLoading || (state is AuthError && state.isBlocked);

    return Column(
      children: [
        // "Quiero ser cliente" (REGISTRO) — flujo completo: Google → registrar
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isDisabled
                ? null
                : () {
                    // Flujo legacy: Google → registrar → JWT
                    context.read<AuthBloc>().add(
                      const SignInRequested(isRegistration: true),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
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

        // "Soy cliente" (LOGIN) — flujo 2 pasos: Google → verificar
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: isDisabled
                ? null
                : () {
                    // PASO 1: Solo Google Sign-In (sin backend)
                    context.read<AuthBloc>().add(
                      const GoogleSignInRequested(),
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

  Widget _buildExploreLinkOption(BuildContext context) {
    return TextButton(
      onPressed: () {},
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
