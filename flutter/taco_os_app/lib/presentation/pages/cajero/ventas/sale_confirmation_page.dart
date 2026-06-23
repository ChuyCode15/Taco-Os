import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taco_os_app/domain/entities/sale.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_state.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_state.dart';

/// Página de confirmación de venta con resumen y método de pago
///
/// Muestra un resumen completo de los productos en el carrito, el total a cobrar,
/// y permite seleccionar el método de pago (efectivo o tarjeta) antes de confirmar
/// la venta. Maneja los estados de loading, éxito y error según el resultado de
/// la operación en VentasBloc.
///
/// **Características:**
/// - Resumen de productos con cantidad, precio unitario y subtotal
/// - Total prominente en la parte superior
/// - Selección de método de pago con botones grandes
/// - Botón de confirmación que dispara SaleConfirmed en VentasBloc
/// - En error: mantiene productos en pantalla para reintento
/// - En éxito: muestra pantalla de confirmación y botón para regresar
/// - Navegación a CajeroHomePage en < 500ms
///
/// **Validates: Requirements 5.6, 5.7, 5.9, 5.10**
class SaleConfirmationPage extends StatefulWidget {
  const SaleConfirmationPage({super.key});

  @override
  State<SaleConfirmationPage> createState() => _SaleConfirmationPageState();
}

class _SaleConfirmationPageState extends State<SaleConfirmationPage> {
  PaymentMethod? _selectedPaymentMethod;

  /// Maneja la selección del método de pago
  ///
  /// Dispara el evento PaymentMethodSelected en VentasBloc
  ///
  /// **Validates: Requirement 5.6**
  void _onPaymentMethodSelected(PaymentMethod method) {
    setState(() {
      _selectedPaymentMethod = method;
    });

    context.read<VentasBloc>().add(
      PaymentMethodSelected(paymentMethod: method),
    );
  }

  /// Maneja la confirmación de la venta
  ///
  /// Obtiene los IDs de sesión, negocio y cajero desde CajeroBloc
  /// y dispara el evento SaleConfirmed en VentasBloc
  ///
  /// **Validates: Requirements 5.6, 5.9**
  void _onConfirmSale() {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un método de pago antes de confirmar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final cajeroState = context.read<CajeroBloc>().state;
    if (cajeroState is! TurnoActivo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay turno activo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final session = cajeroState.session;

    context.read<VentasBloc>().add(
      SaleConfirmed(
        sessionId: session.id,
        businessId: session.businessId,
        cashierId: session.userId,
      ),
    );
  }

  /// Navega de regreso al CajeroHomePage en < 500ms
  ///
  /// **Validates: Requirement 5.10**
  void _navigateToHome() {
    context.go('/cajero/home');
  }

  /// Solicita la cancelación de una venta
  ///
  /// Verifica que la venta esté dentro de la ventana anti-fraude y
  /// dispara el evento SaleCancellationRequested en VentasBloc.
  ///
  /// **Validates: Requirements 6.1, 6.2**
  void _requestCancellation(Sale sale) {
    // Verificar nuevamente que la venta sea cancelable (race condition guard)
    if (!sale.isCancellable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La ventana de cancelación ha expirado (5 minutos)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar diálogo de confirmación
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Cancelación'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta venta? '
          'Deberás tomar una foto del producto devuelto como evidencia.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        // Disparar evento de cancelación
        context.read<VentasBloc>().add(
          SaleCancellationRequested(
            saleId: sale.id,
            saleTimestamp: sale.timestamp,
          ),
        );
        // Navegar a la página de captura de foto
        context.push('/cajero/ventas/cancellation-camera');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VentasBloc, VentasState>(
      listener: (context, state) {
        // Manejo de errores: mostrar mensaje sin limpiar el carrito
        if (state is SaleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Reintentar',
                textColor: Colors.white,
                onPressed: _onConfirmSale,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        // Estado de éxito: mostrar pantalla de confirmación
        if (state is SaleSuccess) {
          return _buildSuccessScreen(state.sale);
        }

        // Estado de loading: mostrar indicador de progreso
        if (state is VentasLoading) {
          return _buildLoadingScreen();
        }

        // Estados de carrito: CartView o PaymentView
        final cartItems = switch (state) {
          CartView() => state.cartItems,
          PaymentView() => state.cartItems,
          _ => <dynamic>[],
        };

        final total = switch (state) {
          CartView() => state.total,
          PaymentView() => state.total,
          _ => 0.0,
        };

        // Si no hay productos en el carrito, regresar a inicio
        if (cartItems.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/cajero/ventas/categories');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return _buildConfirmationScreen(cartItems, total);
      },
    );
  }

  /// Construye la pantalla de confirmación con resumen y pago
  Widget _buildConfirmationScreen(List<dynamic> cartItems, double total) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Venta'), centerTitle: true),
      body: Column(
        children: [
          // Sección de total prominente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              border: const Border(
                bottom: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Total a Cobrar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // Lista de productos
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: cartItems.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return _buildProductItem(item);
              },
            ),
          ),

          // Sección de método de pago
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Método de Pago',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Botones de método de pago
                Row(
                  children: [
                    // Botón Efectivo
                    Expanded(
                      child: _buildPaymentMethodButton(
                        method: PaymentMethod.cash,
                        icon: Icons.attach_money,
                        label: 'Efectivo',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Botón Tarjeta
                    Expanded(
                      child: _buildPaymentMethodButton(
                        method: PaymentMethod.card,
                        icon: Icons.credit_card,
                        label: 'Tarjeta',
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Botón de confirmar venta
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _onConfirmSale,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedPaymentMethod != null
                          ? Colors.green
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirmar Venta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un item de producto en la lista
  Widget _buildProductItem(dynamic item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cantidad con badge circular
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Nombre y precio unitario
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${item.unitPrice.toStringAsFixed(2)} c/u',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Subtotal
        Text(
          '\$${item.subtotal.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  /// Construye un botón de método de pago
  Widget _buildPaymentMethodButton({
    required PaymentMethod method,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedPaymentMethod == method;

    return OutlinedButton(
      onPressed: () => _onPaymentMethodSelected(method),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? color.withValues(alpha: 0.1)
            : Colors.white,
        foregroundColor: isSelected ? color : Colors.grey[700],
        side: BorderSide(
          color: isSelected ? color : Colors.grey[300]!,
          width: isSelected ? 3 : 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Construye la pantalla de loading
  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrando Venta'), centerTitle: true),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 24),
            Text(
              'Registrando venta...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la pantalla de éxito con ticket y opción de cancelación
  ///
  /// Muestra la opción de cancelar la venta solo si está dentro de la
  /// ventana anti-fraude (< 5 minutos desde el timestamp de la venta).
  ///
  /// **Validates: Requirements 5.9, 5.10, 6.1, 6.2**
  Widget _buildSuccessScreen(Sale sale) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venta Registrada'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Sin botón de regreso
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de éxito
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),

              // Mensaje de éxito
              const Text(
                '¡Venta Registrada!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              const Text(
                'La venta se ha registrado exitosamente',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Resumen de la venta
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      label: 'Total',
                      value: '\$${sale.total.toStringAsFixed(2)}',
                      isBold: true,
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      label: 'Método de Pago',
                      value: sale.paymentMethod == PaymentMethod.cash
                          ? 'Efectivo'
                          : 'Tarjeta',
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      label: 'Productos',
                      value: '${sale.items.length}',
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      label: 'Hora',
                      value:
                          '${sale.timestamp.hour.toString().padLeft(2, '0')}:${sale.timestamp.minute.toString().padLeft(2, '0')}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Mostrar opción de cancelar solo si está dentro de la ventana anti-fraude
              // **Validates: Requirements 6.1, 6.2**
              if (sale.isCancellable) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.orange[700],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Puedes cancelar esta venta dentro de los próximos 5 minutos',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Botón de cancelar venta
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => _requestCancellation(sale),
                    icon: const Icon(Icons.cancel, size: 24),
                    label: const Text(
                      'Cancelar Venta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Botón para regresar a Modo Cajero
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _navigateToHome,
                  icon: const Icon(Icons.home, size: 24),
                  label: const Text(
                    'Regresar a Modo Cajero',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye una fila de resumen con label y value
  Widget _buildSummaryRow({
    required String label,
    required String value,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 20 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }
}
