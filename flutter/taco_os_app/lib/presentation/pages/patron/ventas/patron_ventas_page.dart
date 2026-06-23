import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_bloc.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_event.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_state.dart';
import 'package:intl/intl.dart';

/// Página de Ventas del Patron
///
/// Muestra el resumen de ventas del día actual:
/// - Número de transacciones
/// - Total de ventas del día
/// - Desglose por método de pago (efectivo y tarjeta)
///
/// Si no hay ventas en el día, muestra todos los valores en cero con un
/// mensaje de estado vacío.
///
/// Validado por Requirement 12.2: Acceso a sección Ventas con resumen del día
class PatronVentasPage extends StatefulWidget {
  final String businessId;

  const PatronVentasPage({super.key, required this.businessId});

  @override
  State<PatronVentasPage> createState() => _PatronVentasPageState();
}

class _PatronVentasPageState extends State<PatronVentasPage> {
  final _currencyFormatter = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    // Load today's sales on init
    context.read<PatronBloc>().add(LoadTodaySalesRequested(widget.businessId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ventas del Día')),
      body: BlocBuilder<PatronBloc, PatronState>(
        builder: (context, state) {
          if (state is PatronLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PatronError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PatronBloc>().add(
                        LoadTodaySalesRequested(widget.businessId),
                      );
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is TodaySalesLoaded) {
            // Show sales data
            return _buildSalesContent(state);
          }

          // Initial state
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSalesContent(TodaySalesLoaded state) {
    final hasData = state.transactionCount > 0;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PatronBloc>().add(
          LoadTodaySalesRequested(widget.businessId),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat(
                        'EEEE, d MMMM yyyy',
                        'es_ES',
                      ).format(DateTime.now()),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Empty state or data
            if (!hasData) ...[
              _buildEmptyState(),
            ] else ...[
              // Transaction count card
              _buildInfoCard(
                icon: Icons.receipt_long,
                title: 'Transacciones',
                value: state.transactionCount.toString(),
                color: Colors.blue,
              ),
              const SizedBox(height: 12),

              // Total sales card
              _buildInfoCard(
                icon: Icons.attach_money,
                title: 'Total de Ventas',
                value: _currencyFormatter.format(state.totalSales),
                color: Colors.green,
              ),
              const SizedBox(height: 16),

              // Payment method breakdown
              Text(
                'Desglose por Método de Pago',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Cash sales
              _buildPaymentMethodCard(
                icon: Icons.money,
                title: 'Efectivo',
                amount: state.cashSales,
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 12),

              // Card sales
              _buildPaymentMethodCard(
                icon: Icons.credit_card,
                title: 'Tarjeta',
                amount: state.cardSales,
                color: Colors.blue.shade700,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay ventas registradas hoy',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Las ventas aparecerán aquí cuando los cajeros registren transacciones',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Show zeros
            _buildInfoCard(
              icon: Icons.receipt_long,
              title: 'Transacciones',
              value: '0',
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.attach_money,
              title: 'Total de Ventas',
              value: _currencyFormatter.format(0),
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required double amount,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    _currencyFormatter.format(amount),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
