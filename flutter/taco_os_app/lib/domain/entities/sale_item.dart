/// Entidad de dominio que representa un ítem dentro de una venta
///
/// Esta es una entidad inmutable que representa un producto individual
/// dentro de una transacción de venta, con cantidad y precios.
///
/// Validada por Requirement 5.6: Registro de Ventas con múltiples productos
/// Validada por Requirement 13.1: Arquitectura Clean Code
class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  /// Crea una copia de la entidad con campos actualizados
  SaleItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? subtotal,
  }) {
    return SaleItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaleItem &&
        other.productId == productId &&
        other.productName == productName &&
        other.quantity == quantity &&
        other.unitPrice == unitPrice &&
        other.subtotal == subtotal;
  }

  @override
  int get hashCode {
    return Object.hash(productId, productName, quantity, unitPrice, subtotal);
  }

  @override
  String toString() {
    return 'SaleItem(productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, subtotal: $subtotal)';
  }
}
