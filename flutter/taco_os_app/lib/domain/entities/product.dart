/// Enumeración de categorías de productos
///
/// Validada por Requirement 5.1: Registro de Ventas
/// Validada por Requirement 11.3: Catálogo de Productos Offline
enum ProductCategory {
  /// Categoría de productos alimenticios principales
  comida,

  /// Categoría de bebidas
  bebidas,

  /// Categoría de postres
  postres,
}

/// Entidad de dominio que representa un producto del catálogo
///
/// Esta es una entidad inmutable que representa un producto disponible
/// para venta en el sistema, clasificado por categorías fijas.
///
/// Validada por Requirement 13.1: Arquitectura Clean Code
/// Validada por Requirement 15.1: Aislamiento Multi-Tenant
class Product {
  final String id;
  final String businessId;
  final String name;
  final double price;
  final ProductCategory category;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.businessId,
    required this.name,
    required this.price,
    required this.category,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Crea una copia de la entidad con campos actualizados
  Product copyWith({
    String? id,
    String? businessId,
    String? name,
    double? price,
    ProductCategory? category,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.id == id &&
        other.businessId == businessId &&
        other.name == name &&
        other.price == price &&
        other.category == category &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      businessId,
      name,
      price,
      category,
      isActive,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, businessId: $businessId, name: $name, price: $price, category: $category, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
