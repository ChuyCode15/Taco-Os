import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taco_os_app/presentation/blocs/cajero/corte_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/corte_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/corte_state.dart';

/// Pantalla de resumen del Corte de Caja con diferencia calculada
///
/// Muestra el resumen financiero del turno con la diferencia entre efectivo
/// esperado y efectivo contado. Requiere confirmación explícita del Cajero
/// antes de finalizar el corte.
///
/// **Flujo:**
/// 1. Recibe [CorteSummaryView] del CorteBloc con todos los datos financieros
/// 2. Si turno vacío: muestra diálogo de confirmación adicional
/// 3. Muestra diferencia calculada (sobrante/faltante) destacada visualmente
/// 4. Presenta botones "Confirmar Corte" y "Cancelar"
/// 5. On confirmar: dispara [CorteConfirmed] → navega a ticket
/// 6. On cancelar: dispara [CorteRejected] → navega a CajeroHomePage
///
/// **Validates: Requirements 9.3, 9.8, 9.9**
class CorteSummaryPage extends StatefulWidget {
  const CorteSummaryPage({super.key});

  @override
  State<CorteSummaryPage> createState() => _CorteSummaryPageState();
}

class _CorteSummaryPageState extends State<CorteSummaryPage> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    // Reset dialog flag on init
    _dialogShown = false;
  }

  /// Muestra diálogo de confirmación para turno sin transacciones
  ///
  /// **Validates: Requirement 9.8**
  Future<bool> _showNoTransactionsDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Turno sin Transacciones'),
        content: const Text(
          'No hay transacciones en este turno. ¿Deseas continuar con el Corte?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sí, continuar'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Confirma el corte y dispara [CorteConfirmed]
  ///
  /// **Validates: Requirements 9.3, 9.4**
  void _confirmCorte(CorteSummaryView state) {
    context.read<CorteBloc>().add(
      CorteConfirmed(countedCash: state.countedCash),
    );
  }

  /// Rechaza el corte y regresa a CajeroHomePage
  ///
  /// **Validates: Requirement 9.9**
  void _rejectCorte() {
    context.read<CorteBloc>().add(const CorteRejected());
    context.go('/cajero/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de Corte'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Evitar back button
      ),
      body: BlocConsumer<CorteBloc, CorteState>(
        listener: (context, state) {
          if (state is CorteSummaryView) {
            // AC 9.8: Si turno sin transacciones, mostrar confirmación
            if (state.hasNoTransactions && !_dialogShown) {
              _dialogShown = true;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                final confirmed = await _showNoTransactionsDialog();
                if (!mounted) return;

                if (!confirmed) {
                  // AC 9.9: Cajero rechaza → regresar sin escribir datos
                  _rejectCorte();
                }
              });
            }
          } else if (state is CorteSuccess) {
            // AC 9.5: Navegar a ticket digital
            // Requirement 9.5: Generar y mostrar ticket digital
            context.go('/cajero/corte/ticket');
          } else if (state is CorteError) {
            // Error al cerrar la sesión
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Reintentar',
                  textColor: Colors.white,
                  onPressed: () {
                    // El estado anterior se mantiene, solo reintentar
                    final currentState = context.read<CorteBloc>().state;
                    if (currentState is CorteSummaryView) {
                      _confirmCorte(currentState);
                    }
                  },
                ),
              ),
            );
          } else if (state is CorteInitial) {
            // AC 9.9: Corte rechazado, ya navegó a CajeroHomePage
            // No action needed here (navigation already done in _rejectCorte)
          }
        },
        builder: (context, state) {
          if (state is! CorteSummaryView) {
            // Estado inválido — no debería llegar aquí
            return const Center(
              child: Text('Error: Estado inválido para resumen de corte'),
            );
          }

          final summary = state.shiftSummary;
          final difference = state.difference;
          final countedCash = state.countedCash;
          final expectedCash = state.expectedCash;

          // Determinar color de diferencia
          final differenceColor = difference > 0
              ? Colors
                    .green // Sobrante
              : difference < 0
              ? Colors
                    .red // Faltante
              : Colors.grey; // Sin diferencia

          final differenceLabel = difference > 0
              ? 'Sobrante'
              : difference < 0
              ? 'Faltante'
              : 'Sin diferencia';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icono de corte
                const Icon(Icons.receipt_long, size: 80, color: Colors.blue),
                const SizedBox(height: 24),

                // Título
                const Text(
                  'Resumen de Corte de Caja',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Descripción
                const Text(
                  'Revisa los totales antes de confirmar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Card de resumen
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detalles del Turno',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildSummaryRow(
                          'Transacciones',
                          '${summary.transactionCount}',
                        ),
                        _buildSummaryRow(
                          'Ventas Totales',
                          '\$${summary.totalSales.toStringAsFixed(2)}',
                        ),
                        _buildSummaryRow(
                          'Efectivo',
                          '\$${summary.totalCash.toStringAsFixed(2)}',
                        ),
                        _buildSummaryRow(
                          'Tarjeta',
                          '\$${summary.totalCard.toStringAsFixed(2)}',
                        ),
                        _buildSummaryRow(
                          'Gastos',
                          '\$${summary.totalExpenses.toStringAsFixed(2)}',
                          valueColor: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card de cálculo de diferencia
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cálculo de Diferencia',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildSummaryRow(
                          'Efectivo Esperado',
                          '\$${expectedCash.toStringAsFixed(2)}',
                        ),
                        _buildSummaryRow(
                          'Efectivo Contado',
                          '\$${countedCash.toStringAsFixed(2)}',
                        ),
                        const Divider(thickness: 2),
                        _buildSummaryRow(
                          differenceLabel,
                          '\$${difference.abs().toStringAsFixed(2)}',
                          labelColor: differenceColor,
                          valueColor: differenceColor,
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Mensaje de advertencia si hay turno vacío
                if (state.hasNoTransactions)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Este turno no tiene transacciones registradas',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (state.hasNoTransactions) const SizedBox(height: 24),

                // Botón de confirmar corte
                ElevatedButton(
                  onPressed: () => _confirmCorte(state),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Confirmar Corte',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón de cancelar
                OutlinedButton(
                  onPressed: _rejectCorte,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Widget helper para mostrar fila de resumen
  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? labelColor,
    Color? valueColor,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: labelColor ?? Colors.black87,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: valueColor ?? Colors.black,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
