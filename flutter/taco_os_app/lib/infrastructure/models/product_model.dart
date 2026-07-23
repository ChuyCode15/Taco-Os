import '../../domain/entities/product.dart';

/// Modelo de infraestructura para Product con serialización JSON
///
/// Este modelo se utiliza para la comunicación con la API y la persistencia local,
/// proporcionando conversión bidireccional entre JSON y la entidad de dominio.
/// Maneja la serialización del enum ProductCategory y DateTime a formato ISO 8601.
///
/// Validada por Requirement 13.1: Clean Architecture - Infrastructure layer
class ProductModel {
  final String id;
  final String businessId;
  final String name;
  final double price;
  final String category;
  final bool isActive;
  final String createdAt;
  final String? updatedAt;

  const ProductModel({
    required this.id,
    required this.businessId,
    required this.name,
    required this.price,
    required this.category,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  /// Crea un modelo desde JSON (deserialización de API)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// Convierte el modelo a JSON (serialización para API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'name': name,
      'price': price,
      'category': category,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Convierte el modelo a entidad de dominio
  Product toEntity() {
    return Product(
      id: id,
      businessId: businessId,
      name: name,
      price: price,
      category: _parseProductCategory(category),
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      businessId: entity.businessId,
      name: entity.name,
      price: entity.price,
      category: _serializeProductCategory(entity.category),
      isActive: entity.isActive,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }

  /// Convierte string a enum ProductCategory
  static ProductCategory _parseProductCategory(String value) {
    switch (value) {
      case 'comida':
        return ProductCategory.comida;
      case 'bebidas':
        return ProductCategory.bebidas;
      case 'postres':
        return ProductCategory.postres;
      default:
        throw ArgumentError('Unknown product category: $value');
    }
  }

  /// Convierte enum ProductCategory a string
  static String _serializeProductCategory(ProductCategory category) {
    switch (category) {
      case ProductCategory.comida:
        return 'comida';
      case ProductCategory.bebidas:
        return 'bebidas';
      case ProductCategory.postres:
        return 'postres';
    }
  }
}
