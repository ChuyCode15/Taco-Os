import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taco_os_app/core/utils/validators.dart';
import 'package:taco_os_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:taco_os_app/presentation/blocs/auth/auth_state.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_state.dart';

/// Pantalla de apertura de caja (inicio de turno)
///
/// Permite al cajero registrar el Fondo_de_Cambio (0.00–999,999.99) para
/// iniciar un nuevo turno. Valida el monto usando [FondoDeCambioValidator]
/// y dispara [OpenSessionRequested] en el [CajeroBloc].
///
/// **Flujo:**
/// 1. Cajero ingresa el monto en el campo numérico
/// 2. La validación ocurre en tiempo real y al confirmar
/// 3. Si válido: dispara [OpenSessionRequested]
/// 4. Si exitoso: navega al Modo_Cajero
/// 5. Si falla: muestra error y permite reintentar
///
/// **Validates: Requirements 3.1, 3.2, 3.3, 3.6, 3.7**
class OpenSessionPage extends StatefulWidget {
  const OpenSessionPage({super.key});

  @override
  State<OpenSessionPage> createState() => _OpenSessionPageState();
}

class _OpenSessionPageState extends State<OpenSessionPage> {
  final _formKey = GlobalKey<FormState>();
  final _fondoController = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _fondoController.dispose();
    super.dispose();
  }

  /// Valida el campo de Fondo_de_Cambio en tiempo real
  void _validateInput(String value) {
    final result = FondoDeCambioValidator.validate(value);
    setState(() {
      _validationError = result.isValid ? null : result.errorMessage;
    });
  }

  /// Dispara el evento [OpenSessionRequested] si la validación es exitosa
  ///
  /// **Validates: Requirements 3.2, 3.6, 3.7**
  void _openSession() {
    if (_formKey.currentState?.validate() ?? false) {
      final initialCash = double.parse(_fondoController.text.trim());

      // Obtener businessId y userId desde el AuthBloc
      final authState = context.read<AuthBloc>().state;

      if (authState is! Authenticated) {
        // Si el usuario no está autenticado, mostrar error y redirigir a login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sesión inválida. Por favor, inicia sesión nuevamente.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        context.go('/login');
        return;
      }

      final user = authState.user;

      if (user.businessId == null) {
        // Si el usuario no tiene businessId, redirigir a selección de rol
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes vincular tu cuenta a un negocio primero.'),
            backgroundColor: Colors.orange,
          ),
        );
        context.go('/role-selection');
        return;
      }

      context.read<CajeroBloc>().add(
        OpenSessionRequested(
          businessId: user.businessId!,
          userId: user.id,
          initialCash: initialCash,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apertura de Caja'), centerTitle: true),
      body: BlocConsumer<CajeroBloc, CajeroState>(
        listener: (context, state) {
          if (state is TurnoActivo) {
            // AC 3.2: Turno iniciado exitosamente
            // Navegar al Modo_Cajero (CajeroHomePage)
            // Requirement 3.2: Al confirmar apertura exitosa, navegar al Modo_Cajero
            context.go('/cajero/home');
          } else if (state is CajeroError) {
            // AC 3.3: Si escritura en DB falla, mostrar error y no navegar
            // Mostrar error sin navegar al Modo_Cajero
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CajeroLoading;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icono decorativo
                  const Icon(Icons.point_of_sale, size: 80, color: Colors.blue),
                  const SizedBox(height: 24),

                  // Título
                  const Text(
                    'Iniciar Turno',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Descripción
                  const Text(
                    'Ingresa el fondo de cambio para comenzar tu turno',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 48),

                  // Campo de Fondo de Cambio
                  TextFormField(
                    controller: _fondoController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: 'Fondo de Cambio',
                      hintText: '0.00',
                      prefixText: '\$ ',
                      helperText:
                          'Ingresa un monto entre \$0.00 y \$999,999.99',
                      errorText: _validationError,
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: isLoading
                          ? Colors.grey[200]
                          : Colors.transparent,
                    ),
                    onChanged: _validateInput,
                    validator: (value) {
                      final result = FondoDeCambioValidator.validate(value);
                      return result.isValid ? null : result.errorMessage;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Botón de confirmar
                  ElevatedButton(
                    onPressed: isLoading ? null : _openSession,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Abrir Caja'),
                  ),
                  const SizedBox(height: 16),

                  // Nota informativa
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'El fondo de cambio puede ser \$0.00 si no tienes efectivo inicial',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
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
}
