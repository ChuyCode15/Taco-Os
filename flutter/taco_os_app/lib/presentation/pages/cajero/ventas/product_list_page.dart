import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taco_os_app/domain/entities/product.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_state.dart';

/// Página de listado de productos de una categoría
///
/// Muestra los productos de la categoría seleccionada, cargados desde Local_DB
/// de forma offline-first. Al seleccionar un producto, navega a la página
/// de ingreso de cantidad ([QuantityKeypadPage]).
///
/// **Características:**
/// - Carga offline-first desde Local_DB
/// - Estados de carga, error y vacío con UX clara
/// - Botón de reintentar en caso de error
/// - Navegación a teclado de cantidad al seleccionar producto
///
/// **Validates: Requirements 5.2, 5.3, 11.1, 11.3, 11.4**
class ProductListPage extends StatelessWidget {
  final String categoryName;

  const ProductListPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getCategoryLabel(categoryName)),
        centerTitle: true,
      ),
      body: BlocConsumer<VentasBloc, VentasState>(
        listener: (context, state) {
          // No se requiere listener para esta página
        },
        builder: (context, state) {
          // Estado de carga
          if (state is VentasLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando productos...'),
                ],
              ),
            );
          }

          // Estado de error
          if (state is SaleError) {
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
                      'Error al cargar productos',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Volver a la selección de categorías para reintentar
                        context.pop();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Estado de lista de productos
          if (state is ProductListView) {
            // Lista vacía
            if (state.products.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay productos disponibles',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'El catálogo se cargará cuando se restaure la conexión',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Lista con productos
            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.products.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final product = state.products[index];
                return _ProductCard(product: product);
              },
            );
          }

          // Estado por defecto (no debería ocurrir)
          return const Center(child: Text('Estado desconocido'));
        },
      ),
    );
  }

  /// Obtiene la etiqueta en español de la categoría
  String _getCategoryLabel(String categoryName) {
    switch (categoryName) {
      case 'comida':
        return 'Comida';
      case 'bebidas':
        return 'Bebidas';
      case 'postres':
        return 'Postres';
      default:
        return categoryName;
    }
  }
}

/// Widget de tarjeta de producto
///
/// Muestra el nombre y precio del producto con diseño Material.
/// Al presionar, navega a la página de ingreso de cantidad.
class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navegar a la página de cantidad con el producto seleccionado
          context.push('/cajero/ventas/quantity', extra: product);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Ícono del producto
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getCategoryColor(product.category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(product.category),
                  size: 32,
                  color: _getCategoryColor(product.category),
                ),
              ),
              const SizedBox(width: 16),
              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              // Indicador de navegación
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  /// Obtiene el ícono de la categoría
  IconData _getCategoryIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.comida:
        return Icons.restaurant;
      case ProductCategory.bebidas:
        return Icons.local_drink;
      case ProductCategory.postres:
        return Icons.cake;
    }
  }

  /// Obtiene el color de la categoría
  Color _getCategoryColor(ProductCategory category) {
    switch (category) {
      case ProductCategory.comida:
        return Colors.orange;
      case ProductCategory.bebidas:
        return Colors.blue;
      case ProductCategory.postres:
        return Colors.pink;
    }
  }
}
