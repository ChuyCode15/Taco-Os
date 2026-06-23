import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taco_os_app/domain/entities/product.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_state.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_event.dart';

/// Página de selección de categorías de productos
///
/// Muestra las 3 categorías fijas del catálogo: Comida, Bebidas y Postres.
/// Al seleccionar una categoría, dispara el evento [CategorySelected] en el
/// [VentasBloc] y navega a [ProductListPage].
///
/// **Características:**
/// - Diseño Material con botones grandes y claros para toque rápido
/// - Navegación automática al seleccionar categoría
/// - Integración con [VentasBloc] para flujo de ventas
///
/// **Validates: Requirements 5.1, 5.2, 11.1**
class CategorySelectionPage extends StatelessWidget {
  const CategorySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona una Categoría'),
        centerTitle: true,
      ),
      body: BlocBuilder<CajeroBloc, CajeroState>(
        builder: (context, cajeroState) {
          // Verificar que hay una sesión activa
          if (cajeroState is! TurnoActivo) {
            return const Center(child: Text('No hay una sesión activa'));
          }

          final businessId = cajeroState.session.businessId;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CategoryButton(
                  category: ProductCategory.comida,
                  label: 'Comida',
                  icon: Icons.restaurant,
                  color: Colors.orange,
                  businessId: businessId,
                ),
                const SizedBox(height: 16),
                _CategoryButton(
                  category: ProductCategory.bebidas,
                  label: 'Bebidas',
                  icon: Icons.local_drink,
                  color: Colors.blue,
                  businessId: businessId,
                ),
                const SizedBox(height: 16),
                _CategoryButton(
                  category: ProductCategory.postres,
                  label: 'Postres',
                  icon: Icons.cake,
                  color: Colors.pink,
                  businessId: businessId,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Widget de botón de categoría con diseño Material
///
/// Muestra un botón grande con ícono, etiqueta y color distintivo.
/// Al presionar, dispara [CategorySelected] y navega a la lista de productos.
class _CategoryButton extends StatelessWidget {
  final ProductCategory category;
  final String label;
  final IconData icon;
  final Color color;
  final String businessId;

  const _CategoryButton({
    required this.category,
    required this.label,
    required this.icon,
    required this.color,
    required this.businessId,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Disparar evento para cargar productos de la categoría
        context.read<VentasBloc>().add(
          CategorySelected(businessId: businessId, category: category),
        );

        // Navegar a la lista de productos
        context.push('/cajero/ventas/products/${category.name}');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
