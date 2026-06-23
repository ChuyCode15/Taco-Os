import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_state.dart';
import 'package:taco_os_app/presentation/blocs/cajero/gastos_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/gastos_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/gastos_state.dart';

/// Popup modal para registro rápido de gastos
///
/// Se muestra como modal sobre la CajeroHomePage cuando el Cajero presiona
/// el botón "Gastos". Permite registrar gastos con descripción y monto.
///
/// **Features:**
/// - Campo de descripción (máximo 100 caracteres, se trunca automáticamente)
/// - Campo de monto numérico (0.01–999,999.99)
/// - Validación en tiempo real con mensajes de error
/// - Integración con GastosBloc para registro en Local_DB
/// - Cierre automático del popup al éxito
/// - Snackbar de confirmación visible ≥ 2 segundos
///
/// **Validaciones (Requirements 7.3, 7.4, 7.5):**
/// - Descripción vacía → mensaje de error, sin escritura en DB
/// - Descripción > 100 caracteres → truncar a 100 automáticamente
/// - Monto vacío/cero/negativo → mensaje de error, sin escritura en DB
/// - Monto > 999,999.99 → mensaje de error, sin escritura en DB
///
/// **Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5, 7.6**
class ExpenseDialog extends StatefulWidget {
  const ExpenseDialog({super.key});

  @override
  State<ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<ExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// Envía el formulario de gasto al BLoC
  ///
  /// Obtiene los datos de la sesión activa del CajeroBloc y envía
  /// el evento ExpenseSubmitted al GastosBloc.
  void _submitExpense(BuildContext context) {
    final cajeroState = context.read<CajeroBloc>().state;

    if (cajeroState is TurnoActivo) {
      final session = cajeroState.session;

      context.read<GastosBloc>().add(
        ExpenseSubmitted(
          sessionId: session.id,
          businessId: session.businessId,
          cashierId: session.userId,
          description: _descriptionController.text,
          amountInput: _amountController.text,
        ),
      );
    } else {
      // No hay turno activo — no debería suceder si el guard funciona
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No hay turno activo'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GastosBloc, GastosState>(
      listener: (context, state) {
        if (state is GastosSuccess) {
          // Cerrar el popup
          Navigator.of(context).pop();

          // Mostrar snackbar de confirmación visible ≥ 2 segundos
          // **Validates: Requirement 7.6**
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gasto registrado: \$${state.expense.amount.toStringAsFixed(2)}',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is GastosValidationError) {
          // Mostrar mensaje de error de validación
          // **Validates: Requirements 7.3, 7.4, 7.5**
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is GastosError) {
          // Mostrar mensaje de error de DB
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.receipt_long, color: Colors.orange),
            SizedBox(width: 8),
            Text('Registrar Gasto'),
          ],
        ),
        content: BlocBuilder<GastosBloc, GastosState>(
          builder: (context, state) {
            final isLoading = state is GastosLoading;

            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Campo de descripción (máximo 100 caracteres)
                  // **Validates: Requirements 7.1, 7.4, 7.5**
                  TextFormField(
                    controller: _descriptionController,
                    enabled: !isLoading,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Ej: Compra de servilletas',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                      counterText: '', // Ocultar el contador de caracteres
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La descripción es requerida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de monto numérico (0.01–999,999.99)
                  // **Validates: Requirements 7.1, 7.2, 7.3**
                  TextFormField(
                    controller: _amountController,
                    enabled: !isLoading,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El monto es requerido';
                      }
                      final amount = double.tryParse(value.trim());
                      if (amount == null) {
                        return 'Ingresa un monto válido';
                      }
                      if (amount <= 0) {
                        return 'El monto debe ser mayor a cero';
                      }
                      if (amount > 999999.99) {
                        return 'El monto no puede exceder \$999,999.99';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          // Botón Cancelar
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),

          // Botón Guardar
          BlocBuilder<GastosBloc, GastosState>(
            builder: (context, state) {
              final isLoading = state is GastosLoading;

              return ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _submitExpense(context);
                        }
                      },
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(isLoading ? 'Guardando...' : 'Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
