import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:taco_os_app/domain/entities/business.dart';
import 'package:taco_os_app/domain/entities/product.dart';
import 'package:taco_os_app/infrastructure/datasources/local/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

/// Página de Configuración del Patron
///
/// Permite al Patron gestionar la configuración del negocio:
/// - Editar nombre del negocio (máximo 60 caracteres)
/// - Visualizar y regenerar código QR de vinculación para Cajeros
/// - Crear, editar y eliminar productos del catálogo (organizados por categoría)
/// - Mostrar plan activo (Free / Premium / Business) con sus límites
///
/// Validado por Requirement 12.6: Acceso a sección Configuración
/// Validado por Requirement 14.3: Mostrar plan activo con límites
class ConfiguracionPage extends StatefulWidget {
  final String businessId;

  const ConfiguracionPage({super.key, required this.businessId});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  final _uuid = const Uuid();
  BusinessData? _business;
  List<ProductData> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
  }

  Future<void> _loadBusinessData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final database = context.read<AppDatabase>();

      // Load business data
      final business = await (database.select(
        database.businesses,
      )..where((b) => b.id.equals(widget.businessId))).getSingleOrNull();

      // Load all products for this business
      final products = await database.productDao.getAllProductsByBusiness(
        widget.businessId,
      );

      setState(() {
        _business = business;
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar configuración: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _buildContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Error desconocido',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBusinessData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_business == null) {
      return const Center(child: Text('No se encontró el negocio'));
    }

    return RefreshIndicator(
      onRefresh: _loadBusinessData,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Business name section
          _buildBusinessNameSection(),
          const SizedBox(height: 24),

          // QR Code section
          _buildQRCodeSection(),
          const SizedBox(height: 24),

          // Subscription plan section
          _buildSubscriptionPlanSection(),
          const SizedBox(height: 24),

          // Product catalog section
          _buildProductCatalogSection(),
        ],
      ),
    );
  }

  Widget _buildBusinessNameSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'Nombre del Negocio',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _business!.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _showEditBusinessNameDialog,
              icon: const Icon(Icons.edit),
              label: const Text('Editar Nombre'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeSection() {
    final qrData = _business!.qrCode ?? _generateQRCode();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.qr_code, color: Colors.purple),
                const SizedBox(width: 12),
                Text(
                  'Código QR de Vinculación',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Los cajeros deben escanear este código para vincularse al negocio',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _regenerateQRCode,
                icon: const Icon(Icons.refresh),
                label: const Text('Regenerar Código QR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlanSection() {
    final plan = _parseSubscriptionPlan(_business!.plan);
    final planName = _getPlanDisplayName(plan);
    final planColor = _getPlanColor(plan);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium, color: planColor),
                const SizedBox(width: 12),
                Text(
                  'Plan de Suscripción',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: planColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: planColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: planColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    planName,
                    style: TextStyle(
                      color: planColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildPlanLimitRow(
              icon: Icons.business,
              label: 'Negocios',
              limit: _getPlanBusinessLimit(plan),
            ),
            const SizedBox(height: 8),
            _buildPlanLimitRow(
              icon: Icons.people,
              label: 'Cajeros',
              limit: _getPlanCashierLimit(plan),
            ),
            if (plan == SubscriptionPlan.business) ...[
              const SizedBox(height: 8),
              _buildPlanFeatureRow(
                icon: Icons.auto_awesome,
                label: 'Módulos de Inteligencia Artificial',
                enabled: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanLimitRow({
    required IconData icon,
    required String label,
    required int limit,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text('$label: ', style: Theme.of(context).textTheme.bodyLarge),
        Text(
          limit.toString(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanFeatureRow({
    required IconData icon,
    required String label,
    required bool enabled,
  }) {
    return Row(
      children: [
        Icon(
          enabled ? Icons.check_circle : Icons.cancel,
          size: 20,
          color: enabled ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }

  Widget _buildProductCatalogSection() {
    // Group products by category
    final productsByCategory = <ProductCategory, List<ProductData>>{};
    for (final category in ProductCategory.values) {
      productsByCategory[category] = _products
          .where((p) => p.category == category.name)
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.restaurant_menu, color: Colors.orange),
            const SizedBox(width: 12),
            Text(
              'Catálogo de Productos',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Gestiona los productos de tu negocio organizados por categoría',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        ...ProductCategory.values.map((category) {
          final products = productsByCategory[category] ?? [];
          return _buildCategorySection(category, products);
        }),
      ],
    );
  }

  Widget _buildCategorySection(
    ProductCategory category,
    List<ProductData> products,
  ) {
    final categoryName = _getCategoryDisplayName(category);
    final categoryIcon = _getCategoryIcon(category);
    final categoryColor = _getCategoryColor(category);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(categoryIcon, color: categoryColor),
        title: Text(
          categoryName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${products.length} productos'),
        children: [
          if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No hay productos en esta categoría',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            ...products.map((product) => _buildProductTile(product)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () => _showAddProductDialog(category),
              icon: const Icon(Icons.add),
              label: const Text('Agregar Producto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: categoryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(ProductData product) {
    return ListTile(
      title: Text(product.name),
      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _showEditProductDialog(product),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDeleteProduct(product),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _generateQRCode() {
    // Generate QR code with business_id and timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'tacos_business:${widget.businessId}:$timestamp';
  }

  SubscriptionPlan _parseSubscriptionPlan(String plan) {
    switch (plan.toLowerCase()) {
      case 'free':
        return SubscriptionPlan.free;
      case 'premium':
        return SubscriptionPlan.premium;
      case 'business':
        return SubscriptionPlan.business;
      default:
        return SubscriptionPlan.free;
    }
  }

  String _getPlanDisplayName(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.premium:
        return 'Premium';
      case SubscriptionPlan.business:
        return 'Business';
    }
  }

  Color _getPlanColor(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return Colors.grey;
      case SubscriptionPlan.premium:
        return Colors.blue;
      case SubscriptionPlan.business:
        return Colors.purple;
    }
  }

  int _getPlanBusinessLimit(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 1;
      case SubscriptionPlan.premium:
        return 2;
      case SubscriptionPlan.business:
        return 5;
    }
  }

  int _getPlanCashierLimit(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 2;
      case SubscriptionPlan.premium:
        return 5;
      case SubscriptionPlan.business:
        return 25;
    }
  }

  String _getCategoryDisplayName(ProductCategory category) {
    switch (category) {
      case ProductCategory.comida:
        return 'Comida';
      case ProductCategory.bebidas:
        return 'Bebidas';
      case ProductCategory.postres:
        return 'Postres';
    }
  }

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

  // Dialog methods
  void _showEditBusinessNameDialog() {
    final controller = TextEditingController(text: _business!.name);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Nombre del Negocio'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nombre del Negocio',
              hintText: 'Ej: Taquería El Paisa',
              border: OutlineInputBorder(),
            ),
            maxLength: 60,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre no puede estar vacío';
              }
              if (value.trim().length > 60) {
                return 'El nombre no puede exceder 60 caracteres';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newName = controller.text.trim();
                await _updateBusinessName(newName);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateBusinessName(String newName) async {
    try {
      final database = context.read<AppDatabase>();
      await (database.update(database.businesses)
            ..where((b) => b.id.equals(widget.businessId)))
          .write(BusinessesCompanion(name: drift.Value(newName)));

      await _loadBusinessData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nombre actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar nombre: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _regenerateQRCode() async {
    try {
      final database = context.read<AppDatabase>();
      final newQRCode = _generateQRCode();

      await (database.update(database.businesses)
            ..where((b) => b.id.equals(widget.businessId)))
          .write(BusinessesCompanion(qrCode: drift.Value(newQRCode)));

      await _loadBusinessData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código QR regenerado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al regenerar código QR: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddProductDialog(ProductCategory category) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Producto - ${_getCategoryDisplayName(category)}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto',
                  hintText: 'Ej: Taco de Pastor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  hintText: 'Ej: 15.00',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El precio no puede estar vacío';
                  }
                  final price = double.tryParse(value.trim());
                  if (price == null || price <= 0) {
                    return 'Ingrese un precio válido mayor a 0';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final name = nameController.text.trim();
                final price = double.parse(priceController.text.trim());
                await _addProduct(name, price, category);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addProduct(
    String name,
    double price,
    ProductCategory category,
  ) async {
    try {
      final database = context.read<AppDatabase>();
      final productId = _uuid.v4();

      await database.productDao.insertProduct(
        ProductsCompanion(
          id: drift.Value(productId),
          businessId: drift.Value(widget.businessId),
          name: drift.Value(name),
          price: drift.Value(price),
          category: drift.Value(category.name),
          isActive: const drift.Value(true),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );

      await _loadBusinessData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto agregado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar producto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditProductDialog(ProductData product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(
      text: product.price.toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Producto'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El precio no puede estar vacío';
                  }
                  final price = double.tryParse(value.trim());
                  if (price == null || price <= 0) {
                    return 'Ingrese un precio válido mayor a 0';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final name = nameController.text.trim();
                final price = double.parse(priceController.text.trim());
                await _updateProduct(product.id, name, price);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProduct(
    String productId,
    String name,
    double price,
  ) async {
    try {
      final database = context.read<AppDatabase>();

      await database.productDao.updateProduct(
        productId,
        ProductsCompanion(
          name: drift.Value(name),
          price: drift.Value(price),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );

      await _loadBusinessData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar producto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDeleteProduct(ProductData product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${product.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _deleteProduct(product.id);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      final database = context.read<AppDatabase>();

      // Soft delete - mark as inactive
      await database.productDao.deactivateProduct(widget.businessId, productId);

      await _loadBusinessData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar producto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
