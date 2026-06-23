import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taco_os_app/domain/usecases/cajero/get_shift_summary_use_case.dart';
import 'package:taco_os_app/domain/entities/shift_summary.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_state.dart';
import 'package:taco_os_app/injection_container.dart' as di;

/// Pantalla "¿Cómo voy?" - Resumen del Turno Activo
///
/// Muestra el resumen del turno calculado exclusivamente desde Local_DB:
/// - Total de ventas
/// - Número de transacciones
/// - Total de gastos
/// - Total en efectivo
/// - Total con tarjeta
/// - Efectivo esperado (inicial + efectivo - gastos)
///
/// **Features:**
/// - Cálculo offline desde SQLite (no requiere conectividad)
/// - Incluye transacciones con is_synced = false
/// - Vista read-only (no modifica el turno activo)
/// - Muestra estado vacío cuando no hay transacciones
/// - Formato de moneda apropiado ($XX,XXX.XX)
///
/// **Validates: Requirements 8.1, 8.2, 8.3, 8.4, 8.5**
class ShiftSummaryPage extends StatelessWidget {
  const ShiftSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('¿Cómo voy?'), centerTitle: true),
      body: BlocBuilder<CajeroBloc, CajeroState>(
        builder: (context, cajeroState) {
          if (cajeroState is! TurnoActivo) {
            // Shouldn't happen due to TurnoGuard, but handle gracefully
            return const Center(child: Text('No hay turno activo'));
          }

          // Get the active session ID
          final sessionId = cajeroState.session.id;

          return FutureBuilder<ShiftSummary?>(
            future: _fetchShiftSummary(sessionId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar el resumen',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final summary = snapshot.data;
              if (summary == null) {
                return const Center(
                  child: Text('No se pudo obtener el resumen'),
                );
              }

              return _buildSummaryContent(context, summary);
            },
          );
        },
      ),
    );
  }

  /// Obtiene el resumen del turno usando GetShiftSummaryUseCase
  Future<ShiftSummary?> _fetchShiftSummary(String sessionId) async {
    final useCase = di.sl<GetShiftSummaryUseCase>();
    final result = await useCase(GetShiftSummaryParams(sessionId: sessionId));

    return result.fold(
      (failure) => throw Exception(failure.message),
      (summary) => summary,
    );
  }

  /// Construye el contenido del resumen del turno
  Widget _buildSummaryContent(BuildContext context, ShiftSummary summary) {
    // Si no hay transacciones, mostrar estado vacío
    // **Validates: Requirement 8.4**
    if (summary.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Sin transacciones',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aún no hay ventas ni gastos registrados en este turno',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Mostrar totales en cero
              _buildZeroTotals(context),
            ],
          ),
        ),
      );
    }

    // Mostrar resumen con datos
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tarjeta de resumen general
          _buildSummaryCard(
            context,
            title: 'Resumen del Turno',
            icon: Icons.assessment,
            color: Colors.blue,
            children: [
              _buildSummaryRow(
                context,
                label: 'Número de transacciones',
                value: summary.transactionCount.toString(),
                isHighlighted: true,
              ),
              const Divider(height: 24),
              _buildSummaryRow(
                context,
                label: 'Total de ventas',
                value: _formatCurrency(summary.totalSales),
                valueColor: Colors.green[700],
                isBold: true,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tarjeta de métodos de pago
          _buildSummaryCard(
            context,
            title: 'Métodos de Pago',
            icon: Icons.payment,
            color: Colors.purple,
            children: [
              _buildSummaryRow(
                context,
                label: 'Efectivo',
                value: _formatCurrency(summary.totalCash),
                icon: Icons.money,
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                context,
                label: 'Tarjeta',
                value: _formatCurrency(summary.totalCard),
                icon: Icons.credit_card,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tarjeta de gastos y efectivo esperado
          _buildSummaryCard(
            context,
            title: 'Gastos y Efectivo',
            icon: Icons.account_balance_wallet,
            color: Colors.orange,
            children: [
              _buildSummaryRow(
                context,
                label: 'Total de gastos',
                value: _formatCurrency(summary.totalExpenses),
                valueColor: Colors.red[700],
                icon: Icons.receipt_long,
              ),
              const Divider(height: 24),
              _buildSummaryRow(
                context,
                label: 'Efectivo esperado',
                value: _formatCurrency(summary.expectedCash),
                valueColor: Colors.green[700],
                isBold: true,
                icon: Icons.savings,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Nota informativa
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Los cálculos incluyen todas las transacciones, incluso las no sincronizadas',
                    style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta de resumen con título y contenido
  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Construye una fila de resumen con label y valor
  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
    bool isHighlighted = false,
    IconData? icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: valueColor ?? Colors.black87,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 18 : 16,
          ),
        ),
      ],
    );
  }

  /// Construye la vista de totales en cero para estado vacío
  Widget _buildZeroTotals(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow(context, label: 'Transacciones', value: '0'),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              label: 'Total de ventas',
              value: _formatCurrency(0),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              label: 'Total de gastos',
              value: _formatCurrency(0),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              label: 'Efectivo',
              value: _formatCurrency(0),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              label: 'Tarjeta',
              value: _formatCurrency(0),
            ),
          ],
        ),
      ),
    );
  }

  /// Formatea un valor numérico como moneda mexicana
  ///
  /// **Validates: Requirement 8.1** (formato apropiado)
  String _formatCurrency(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final intPart = absAmount.floor();
    final decimalPart = ((absAmount - intPart) * 100).round();

    // Formatear la parte entera con separadores de miles
    final intString = intPart.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    final formatted = '\$$intString.${decimalPart.toString().padLeft(2, '0')}';
    return isNegative ? '-$formatted' : formatted;
  }
}
