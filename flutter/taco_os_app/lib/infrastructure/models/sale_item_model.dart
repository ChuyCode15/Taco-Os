import '../../domain/entities/sale_item.dart';

/// Modelo de infraestructura para SaleItem con serialización JSON
///
/// Este modelo se utiliza para la comunicación con la API y la persistencia local,
/// proporcionando conversión bidireccional entre JSON y la entidad de dominio.
///
/// Validada por Requirement 13.1: Clean Architecture - Infrastructure layer
class SaleItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const SaleItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  /// Crea un modelo desde JSON (deserialización de API)
  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  /// Convierte el modelo a JSON (serialización para API)
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
    };
  }

  /// Convierte el modelo a entidad de dominio
  SaleItem toEntity() {
    return SaleItem(
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory SaleItemModel.fromEntity(SaleItem entity) {
    return SaleItemModel(
      productId: entity.productId,
      productName: entity.productName,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      subtotal: entity.subtotal,
    );
  }
}
