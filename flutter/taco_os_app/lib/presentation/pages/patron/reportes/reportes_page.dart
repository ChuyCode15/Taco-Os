import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_bloc.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_event.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_state.dart';
import 'package:intl/intl.dart';

/// Página de Reportes del Patron
///
/// Muestra un reporte de ventas y gastos filtrable por rango de fechas
/// de hasta 365 días. Si no hay datos en el rango seleccionado, muestra
/// un estado vacío con el rango consultado.
///
/// Validado por Requirement 12.3: Reporte de ventas y gastos filtrable
/// por rango de fechas de hasta 365 días
class ReportesPage extends StatefulWidget {
  final String businessId;

  const ReportesPage({super.key, required this.businessId});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  final _currencyFormatter = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  final _dateFormatter = DateFormat('d MMM yyyy', 'es_ES');

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load initial report (last 7 days)
    _loadReport();
  }

  void _loadReport() {
    context.read<PatronBloc>().add(
      LoadReportsRequested(
        businessId: widget.businessId,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Validate max 365 days
      final daysDifference = picked.end.difference(picked.start).inDays;
      if (daysDifference > 365) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El rango de fechas no puede superar 365 días'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Seleccionar rango de fechas',
          ),
        ],
      ),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadReport,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is ReportsLoaded) {
            return _buildReportContent(state);
          }

          // Initial state
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildReportContent(ReportsLoaded state) {
    final hasData = state.transactionCount > 0;

    return RefreshIndicator(
      onRefresh: () async {
        _loadReport();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date range card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.blue),
                        const SizedBox(width: 12),
                        Text(
                          'Rango de Fechas',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_dateFormatter.format(state.startDate)} - ${_dateFormatter.format(state.endDate)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.endDate.difference(state.startDate).inDays + 1} días',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Empty state or data
            if (!hasData) ...[
              _buildEmptyState(state),
            ] else ...[
              // Transaction count
              _buildInfoCard(
                icon: Icons.receipt_long,
                title: 'Transacciones',
                value: state.transactionCount.toString(),
                color: Colors.blue,
              ),
              const SizedBox(height: 12),

              // Total sales
              _buildInfoCard(
                icon: Icons.trending_up,
                title: 'Total de Ventas',
                value: _currencyFormatter.format(state.totalSales),
                color: Colors.green,
              ),
              const SizedBox(height: 12),

              // Total expenses
              _buildInfoCard(
                icon: Icons.trending_down,
                title: 'Total de Gastos',
                value: _currencyFormatter.format(state.totalExpenses),
                color: Colors.red,
              ),
              const SizedBox(height: 16),

              // Net profit/loss
              _buildNetProfitCard(state.totalSales - state.totalExpenses),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ReportsLoaded state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay datos en este rango',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Rango consultado:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${_dateFormatter.format(state.startDate)} - ${_dateFormatter.format(state.endDate)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.date_range),
              label: const Text('Cambiar rango'),
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
                color: color.withOpacity(0.1),
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

  Widget _buildNetProfitCard(double netAmount) {
    final isProfit = netAmount >= 0;
    final color = isProfit ? Colors.green : Colors.red;
    final icon = isProfit ? Icons.arrow_upward : Icons.arrow_downward;
    final label = isProfit ? 'Ganancia Neta' : 'Pérdida Neta';

    return Card(
      elevation: 4,
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _currencyFormatter.format(netAmount.abs()),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
