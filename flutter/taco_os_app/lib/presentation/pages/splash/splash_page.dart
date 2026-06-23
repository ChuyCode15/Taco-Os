import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de presentación inicial de la aplicación Taco'Os
///
/// Muestra el logo "Taco'Os" durante 2-3 segundos y luego navega
/// automáticamente a la pantalla de login.
///
/// **Logo:**
/// - Si existe `assets/images/logo.png`, lo muestra como imagen
/// - Si no existe, usa un Text widget estilizado como fallback
///
/// Validado por Requirement 13.1: Configuración de estructura inicial
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  /// Espera 2.5 segundos y navega automáticamente a /login
  void _navigateToLogin() {
    _navigationTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B7FFF), // Azul del diseño de referencia
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Intentar cargar logo.png, si no existe usar Text widget como fallback
            _buildLogo(),
            const SizedBox(height: 16),
            // Subtítulo opcional
            Text(
              'Inteligencia financiera para tu negocio',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el logo: intenta cargar imagen, si no existe usa Text widget
  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      width: 200,
      height: 200,
      errorBuilder: (context, error, stackTrace) {
        // Fallback: Text widget con tipografía blanca, redondeada y moderna
        return Text(
          "Taco'Os",
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                offset: const Offset(0, 4),
                blurRadius: 8,
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ],
          ),
        );
      },
    );
  }
}
