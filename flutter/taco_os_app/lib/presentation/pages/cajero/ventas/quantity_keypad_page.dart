import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taco_os_app/domain/entities/product.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_state.dart';

/// Página de teclado numérico para ingreso de cantidad
///
/// Permite al cajero ingresar la cantidad del producto seleccionado usando
/// un teclado numérico personalizado. Valida el rango 1–999,999,999 y muestra
/// el subtotal en tiempo real.
///
/// **Características:**
/// - Teclado numérico 0-9 con botones grandes para toque rápido
/// - Validación en tiempo real de cantidad (0, negativo, decimal, no numérico)
/// - Cálculo y visualización del subtotal (cantidad × precio)
/// - Permite agregar múltiples productos antes de confirmar
/// - Navegación automática después de agregar producto
///
/// **Validates: Requirements 5.4, 5.5, 5.8, 11.1, 11.3**
class QuantityKeypadPage extends StatefulWidget {
  final Product product;

  const QuantityKeypadPage({super.key, required this.product});

  @override
  State<QuantityKeypadPage> createState() => _QuantityKeypadPageState();
}

class _QuantityKeypadPageState extends State<QuantityKeypadPage> {
  String _quantityInput = '';
  String? _validationError;

  /// Valida la cantidad ingresada
  ///
  /// Retorna null si es válida, o un mensaje de error si no cumple:
  /// - Rango: 1–999,999,999
  /// - No puede ser cero, negativo, decimal o no numérico
  ///
  /// **Validates: Requirement 5.8**
  String? _validateQuantity(String input) {
    if (input.isEmpty) {
      return 'Ingresa una cantidad';
    }

    // Validar que sea numérico
    final quantity = int.tryParse(input);
    if (quantity == null) {
      return 'La cantidad debe ser un número entero';
    }

    // Validar que no sea cero
    if (quantity == 0) {
      return 'La cantidad no puede ser cero';
    }

    // Validar que no sea negativo
    if (quantity < 0) {
      return 'La cantidad no puede ser negativa';
    }

    // Validar rango máximo
    if (quantity > 999999999) {
      return 'La cantidad no puede superar 999,999,999';
    }

    return null;
  }

  /// Calcula el subtotal (cantidad × precio)
  double _calculateSubtotal() {
    final quantity = int.tryParse(_quantityInput);
    if (quantity == null) return 0.0;
    return quantity * widget.product.price;
  }

  /// Maneja el input del teclado numérico
  void _onNumberPressed(String number) {
    setState(() {
      // Prevenir números que excedan el límite
      if (_quantityInput.length >= 9) return;

      _quantityInput += number;
      _validationError = _validateQuantity(_quantityInput);
    });
  }

  /// Maneja el botón de borrar
  void _onBackspacePressed() {
    setState(() {
      if (_quantityInput.isNotEmpty) {
        _quantityInput = _quantityInput.substring(0, _quantityInput.length - 1);
        _validationError = _validateQuantity(_quantityInput);
      }
    });
  }

  /// Maneja el botón de limpiar
  void _onClearPressed() {
    setState(() {
      _quantityInput = '';
      _validationError = null;
    });
  }

  /// Maneja el botón de confirmar
  void _onConfirmPressed() {
    final error = _validateQuantity(_quantityInput);

    if (error != null) {
      setState(() {
        _validationError = error;
      });
      return;
    }

    final quantity = int.parse(_quantityInput);

    // Agregar producto al carrito con [ProductAdded] event
    context.read<VentasBloc>().add(
      ProductAdded(product: widget.product, quantity: quantity),
    );

    // Regresar a la lista de productos para agregar más productos
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _calculateSubtotal();

    return Scaffold(
      appBar: AppBar(title: const Text('Cantidad'), centerTitle: true),
      body: BlocListener<VentasBloc, VentasState>(
        listener: (context, state) {
          // Escuchar errores del BLoC
          if (state is SaleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          // Navegar al carrito cuando se agrega el producto
          if (state is CartView) {
            // El pop() ya se ejecutó en _onConfirmPressed
            // Mostrar confirmación
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Producto agregado al carrito'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: Column(
          children: [
            // Sección de información del producto
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nombre del producto
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Precio unitario
                    Text(
                      'Precio: \$${widget.product.price.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 24),
                    // Display de cantidad
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _validationError != null
                              ? Colors.red
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _quantityInput.isEmpty ? '0' : _quantityInput,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _validationError != null
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                          if (_validationError != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _validationError!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subtotal
                    Text(
                      'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Teclado numérico
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Fila 1: 1, 2, 3
                    Expanded(
                      child: Row(
                        children: [
                          _NumberButton(
                            number: '1',
                            onPressed: () => _onNumberPressed('1'),
                          ),
                          const SizedBox(width: 8),
                          _NumberButton(
                            number: '2',
                            onPressed: () => _onNumberPressed('2'),
                          ),
                          const SizedBox(width: 8),
                          _NumberButton(
                            number: '3',
                            onPressed: () => _onNumberPressed('3'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Fila 2: 4, 5, 6
                    Expanded(
                      child: Row(
                        children: [
                          _NumberButton(
                            number: '4',
                            onPressed: () => _onNumberPressed('4'),
                          ),
                          const SizedBox(width: 8),
                          _NumberButton(
                            number: '5',
                            onPressed: () => _onNumberPressed('5'),
                          ),
                          const SizedBox(width: 8),
                          _NumberButton(
                            number: '6',
                            onPressed: () => _onNumberPressed('6'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Fila 3: 7, 8, 9
                    Expanded(
                      child: Row(
                        children: [
                          _NumberButton(
                            number: '7',
                            onPressed: () => _onNumberPressed('7'),
                          ),
                          const SizedBox(width: 8),
                          _NumberButton(
                            number: '8',
                            onPressed: () => _onNumberPressed('8'),
                          ),
                          const SizedBox(width: 8),
                          _NumberButton(
                            number: '9',
                            onPressed: () => _onNumberPressed('9'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Fila 4: C, 0, ⌫
                    Expanded(
                      child: Row(
                        children: [
                          _ActionButton(
                            label: 'C',
                            icon: Icons.clear,
                            onPressed: _onClearPressed,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          _NumberButton(
                            number: '0',
                            onPressed: () => _onNumberPressed('0'),
                          ),
                          const SizedBox(width: 8),
                          _ActionButton(
                            label: '⌫',
                            icon: Icons.backspace_outlined,
                            onPressed: _onBackspacePressed,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Botón de confirmar
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _onConfirmPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Agregar al Carrito',
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
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de botón numérico del teclado
class _NumberButton extends StatelessWidget {
  final String number;
  final VoidCallback onPressed;

  const _NumberButton({required this.number, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          number,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Widget de botón de acción del teclado (limpiar, borrar)
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Icon(icon, size: 32),
      ),
    );
  }
}
