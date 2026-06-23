import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:taco_os_app/domain/entities/user.dart';
import 'package:taco_os_app/domain/repositories/i_auth_repository.dart';
import 'package:taco_os_app/presentation/blocs/cajero/corte_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/corte_state.dart';

/// Pantalla de ticket digital después del Corte de Caja
///
/// Muestra el ticket completo con todos los detalles del turno cerrado:
/// - Nombre del negocio (obtenido del businessId)
/// - Nombre del Cajero (obtenido del userId)
/// - Fecha y hora de apertura y cierre
/// - Total ventas efectivo
/// - Total ventas tarjeta
/// - Total gastos
/// - Fondo de Cambio (opening balance)
/// - Efectivo contado
/// - Diferencia (sobrante/faltante)
///
/// **Flujo:**
/// 1. Recibe [CorteSuccess] del CorteBloc con sesión cerrada y resumen
/// 2. Obtiene información del usuario autenticado (nombre del cajero)
/// 3. Muestra el ticket digital completo
/// 4. Al completar: intenta redirigir a OpenSessionPage
/// 5. Si redirección falla: muestra botón "Iniciar nuevo turno"
///
/// **Validates: Requirements 9.5, 9.6, 9.7**
class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  User? _currentUser;
  bool _isLoadingUser = true;
  bool _navigationFailed = false;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _attemptNavigation();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  /// Carga la información del usuario autenticado
  ///
  /// **Validates: Requirement 9.5** - Mostrar nombre del Cajero
  Future<void> _loadUserInfo() async {
    final authRepository = context.read<IAuthRepository>();
    final result = await authRepository.getCurrentUser();

    result.fold(
      (failure) {
        setState(() {
          _isLoadingUser = false;
        });
      },
      (user) {
        setState(() {
          _currentUser = user;
          _isLoadingUser = false;
        });
      },
    );
  }

  /// Intenta redirigir automáticamente a OpenSessionPage después del Corte
  ///
  /// **Validates: Requirement 9.6** - Al completar Corte, redirigir a OpenSessionPage
  /// **Validates: Requirement 9.7** - Si redirección falla, mostrar botón "Iniciar nuevo turno"
  Future<void> _attemptNavigation() async {
    // Esperar 2 segundos para que el usuario pueda ver el ticket
    _navigationTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      try {
        // Intentar navegar a OpenSessionPage
        context.go('/cajero/open-session');
      } catch (e) {
        // Si la redirección falla, mostrar botón manual
        if (mounted) {
          setState(() {
            _navigationFailed = true;
          });
        }
      }
    });
  }

  /// Navega manualmente a OpenSessionPage
  ///
  /// **Validates: Requirement 9.7** - Botón "Iniciar nuevo turno" si redirección falla
  void _startNewSession() {
    context.go('/cajero/open-session');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket de Corte'),
        centerTitle: true,
        automaticallyImplyLeading: false, // No back button
      ),
      body: BlocBuilder<CorteBloc, CorteState>(
        builder: (context, state) {
          if (state is! CorteSuccess) {
            // Estado inválido — no debería llegar aquí
            return const Center(child: Text('Error: Ticket no disponible'));
          }

          final session = state.session;
          final summary = state.shiftSummary;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icono de ticket
                const Icon(Icons.receipt, size: 80, color: Colors.green),
                const SizedBox(height: 24),

                // Título
                const Text(
                  'Corte Completado',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtítulo
                const Text(
                  'Tu turno ha sido cerrado exitosamente',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Card del ticket digital
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Encabezado del ticket
                        _buildTicketHeader(session),
                        const Divider(thickness: 2, height: 32),

                        // Detalles del turno
                        _buildSectionTitle('Detalles del Turno'),
                        const SizedBox(height: 12),
                        _buildTicketRow(
                          'Fecha de Apertura',
                          _formatDateTime(session.openedAt),
                        ),
                        _buildTicketRow(
                          'Fecha de Cierre',
                          _formatDateTime(session.closedAt ?? DateTime.now()),
                        ),
                        _buildTicketRow(
                          'Duración',
                          _formatDuration(session.duration),
                        ),
                        const SizedBox(height: 16),

                        // Resumen de ventas
                        _buildSectionTitle('Resumen de Ventas'),
                        const SizedBox(height: 12),
                        _buildTicketRow(
                          'Transacciones',
                          '${summary.transactionCount}',
                        ),
                        _buildTicketRow(
                          'Total Ventas',
                          _formatCurrency(summary.totalSales),
                          bold: true,
                        ),
                        _buildTicketRow(
                          '  • Efectivo',
                          _formatCurrency(summary.totalCash),
                        ),
                        _buildTicketRow(
                          '  • Tarjeta',
                          _formatCurrency(summary.totalCard),
                        ),
                        const SizedBox(height: 16),

                        // Gastos
                        _buildSectionTitle('Gastos'),
                        const SizedBox(height: 12),
                        _buildTicketRow(
                          'Total Gastos',
                          _formatCurrency(summary.totalExpenses),
                          valueColor: Colors.red,
                        ),
                        const SizedBox(height: 16),

                        // Cálculo de efectivo
                        _buildSectionTitle('Cálculo de Efectivo'),
                        const SizedBox(height: 12),
                        _buildTicketRow(
                          'Fondo de Cambio',
                          _formatCurrency(session.initialCash),
                        ),
                        _buildTicketRow(
                          'Efectivo Esperado',
                          _formatCurrency(summary.expectedCash),
                        ),
                        _buildTicketRow(
                          'Efectivo Contado',
                          _formatCurrency(session.countedCash ?? 0.0),
                          bold: true,
                        ),
                        const Divider(thickness: 2, height: 24),

                        // Diferencia (destacada)
                        _buildDifferenceRow(session.difference ?? 0.0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Mensaje de redirección o botón manual
                if (_navigationFailed)
                  ElevatedButton(
                    onPressed: _startNewSession,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Iniciar Nuevo Turno',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Redirigiendo a apertura de caja...',
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
          );
        },
      ),
    );
  }

  /// Widget para el encabezado del ticket
  ///
  /// **Validates: Requirement 9.5** - Mostrar nombre del negocio y cajero
  Widget _buildTicketHeader(dynamic session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre del negocio (placeholder por ahora)
        // TODO: Obtener nombre del negocio desde businessId
        Text(
          'Negocio: ${session.businessId}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Nombre del cajero
        if (_isLoadingUser)
          const Text(
            'Cajero: Cargando...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          )
        else if (_currentUser != null)
          Text(
            'Cajero: ${_currentUser!.displayName}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          )
        else
          Text(
            'Cajero: ${session.userId}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),

        const SizedBox(height: 8),

        // ID del turno
        Text(
          'Turno ID: ${session.id.substring(0, 8)}...',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  /// Widget para títulos de sección
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /// Widget helper para mostrar fila de ticket
  Widget _buildTicketRow(
    String label,
    String value, {
    Color? valueColor,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
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

  /// Widget para mostrar la diferencia (sobrante/faltante)
  ///
  /// **Validates: Requirement 9.5** - Mostrar diferencia calculada
  Widget _buildDifferenceRow(double difference) {
    final isPositive = difference > 0;
    final isNegative = difference < 0;
    final differenceColor = isPositive
        ? Colors.green
        : isNegative
        ? Colors.red
        : Colors.grey;

    final differenceLabel = isPositive
        ? 'Sobrante'
        : isNegative
        ? 'Faltante'
        : 'Sin Diferencia';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: differenceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: differenceColor, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            differenceLabel,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: differenceColor,
            ),
          ),
          Text(
            _formatCurrency(difference.abs()),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: differenceColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Formatea una fecha/hora a formato legible
  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(dateTime);
  }

  /// Formatea una duración a formato legible
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  /// Formatea un monto a formato de moneda
  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
