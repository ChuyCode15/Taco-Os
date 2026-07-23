import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taco_os_app/core/utils/validators.dart';
import 'package:taco_os_app/presentation/blocs/cajero/corte_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/corte_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/corte_state.dart';

/// Pantalla de ingreso de efectivo contado durante el Corte de Caja
///
/// Permite al cajero ingresar el efectivo contado al final del turno
/// (0.00–999,999.99). Valida el monto usando [CountedCashValidator]
/// y dispara [CashCountEntered] en el [CorteBloc].
///
/// **Flujo:**
/// 1. Cajero ingresa el efectivo contado en el campo numérico
/// 2. La validación ocurre en tiempo real y al confirmar
/// 3. Si válido: dispara [CashCountEntered]
/// 4. Si exitoso: navega a CorteSummaryPage
/// 5. Si falla validación: muestra error inline
///
/// **Validates: Requirements 9.1, 9.2**
class CashCountPage extends StatefulWidget {
  const CashCountPage({super.key});

  @override
  State<CashCountPage> createState() => _CashCountPageState();
}

class _CashCountPageState extends State<CashCountPage> {
  final _formKey = GlobalKey<FormState>();
  final _cashController = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  /// Valida el campo de efectivo contado en tiempo real
  void _validateInput(String value) {
    final result = CountedCashValidator.validate(value);
    setState(() {
      _validationError = result.isValid ? null : result.errorMessage;
    });
  }

  /// Dispara el evento [CashCountEntered] si la validación es exitosa
  ///
  /// **Validates: Requirements 9.1, 9.2**
  void _submitCashCount() {
    if (_formKey.currentState?.validate() ?? false) {
      final countedCash = double.parse(_cashController.text.trim());

      // Disparar evento al CorteBloc
      context.read<CorteBloc>().add(CashCountEntered(countedCash: countedCash));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contar Efectivo'), centerTitle: true),
      body: BlocConsumer<CorteBloc, CorteState>(
        listener: (context, state) {
          if (state is CorteSummaryView) {
            // AC 9.3: Navegar a la pantalla de resumen del corte
            // Requirement 9.3: Al confirmar conteo válido, mostrar resumen
            context.go('/cajero/corte/summary');
          } else if (state is CorteValidationError) {
            // AC 9.2: Mostrar error de validación
            // Requirement 9.2: Validar rango 0.00–999,999.99
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is CorteError) {
            // Error general del BLoC
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
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icono decorativo
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 24),

                  // Título
                  const Text(
                    'Contar Efectivo',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Descripción
                  const Text(
                    'Ingresa el total de efectivo contado en la caja',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 48),

                  // Campo de Efectivo Contado
                  TextFormField(
                    controller: _cashController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Efectivo Contado',
                      hintText: '0.00',
                      prefixText: '\$ ',
                      helperText:
                          'Ingresa un monto entre \$0.00 y \$999,999.99',
                      errorText: _validationError,
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    onChanged: _validateInput,
                    validator: (value) {
                      final result = CountedCashValidator.validate(value);
                      return result.isValid ? null : result.errorMessage;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Botón de confirmar
                  ElevatedButton(
                    onPressed: _submitCashCount,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Continuar'),
                  ),
                  const SizedBox(height: 16),

                  // Nota informativa
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.green[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'El efectivo contado puede ser \$0.00 si no hay efectivo en caja',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[900],
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
