import 'sale_item.dart';

/// Enumeración de métodos de pago disponibles
///
/// Validada por Requirement 5.6: Registro de Ventas con método de pago
enum PaymentMethod {
  /// Pago en efectivo
  cash,

  /// Pago con tarjeta
  card,
}

/// Enumeración de estados de una venta
///
/// Validada por Requirement 6.4: Cancelación de ventas con marca de estado
enum SaleStatus {
  /// Venta completada exitosamente
  completed,

  /// Venta cancelada dentro de la ventana anti-fraude
  cancelled,
}

/// Entidad de dominio que representa una venta
///
/// Esta es una entidad inmutable que representa una transacción de venta
/// realizada durante un turno, incluyendo método de pago y estado.
///
/// Validada por Requirement 5.6: Registro de Ventas
/// Validada por Requirement 6.4: Cancelación de Ventas con foto obligatoria
/// Validada por Requirement 8.1: Vista "¿Cómo voy?" incluye ventas
/// Validada por Requirement 9.5: Corte de Caja incluye totales de ventas
/// Validada por Requirement 13.1: Arquitectura Clean Code
/// Validada por Requirement 15.1: Aislamiento Multi-Tenant
class Sale {
  final String id;
  final String sessionId;
  final String businessId;
  final String cashierId;
  final List<SaleItem> items;
  final double total;
  final PaymentMethod paymentMethod;
  final SaleStatus status;
  final DateTime timestamp;
  final bool isSynced;
  final String? syncError;
  final String? cancellationPhotoUrl;

  const Sale({
    required this.id,
    required this.sessionId,
    required this.businessId,
    required this.cashierId,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.timestamp,
    this.isSynced = false,
    this.syncError,
    this.cancellationPhotoUrl,
  });

  /// Verifica si la venta está completada
  bool get isCompleted => status == SaleStatus.completed;

  /// Verifica si la venta está cancelada
  bool get isCancelled => status == SaleStatus.cancelled;

  /// Verifica si el pago fue en efectivo
  bool get isCash => paymentMethod == PaymentMethod.cash;

  /// Verifica si el pago fue con tarjeta
  bool get isCard => paymentMethod == PaymentMethod.card;

  /// Verifica si la venta está dentro de la ventana anti-fraude (5 minutos)
  bool get isCancellable {
    final elapsed = DateTime.now().difference(timestamp);
    return elapsed.inMinutes < 5 && isCompleted;
  }

  /// Crea una copia de la entidad con campos actualizados
  Sale copyWith({
    String? id,
    String? sessionId,
    String? businessId,
    String? cashierId,
    List<SaleItem>? items,
    double? total,
    PaymentMethod? paymentMethod,
    SaleStatus? status,
    DateTime? timestamp,
    bool? isSynced,
    String? syncError,
    String? cancellationPhotoUrl,
  }) {
    return Sale(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      businessId: businessId ?? this.businessId,
      cashierId: cashierId ?? this.cashierId,
      items: items ?? this.items,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
      syncError: syncError ?? this.syncError,
      cancellationPhotoUrl: cancellationPhotoUrl ?? this.cancellationPhotoUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sale &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.businessId == businessId &&
        other.cashierId == cashierId &&
        _listEquals(other.items, items) &&
        other.total == total &&
        other.paymentMethod == paymentMethod &&
        other.status == status &&
        other.timestamp == timestamp &&
        other.isSynced == isSynced &&
        other.syncError == syncError &&
        other.cancellationPhotoUrl == cancellationPhotoUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      sessionId,
      businessId,
      cashierId,
      Object.hashAll(items),
      total,
      paymentMethod,
      status,
      timestamp,
      isSynced,
      syncError,
      cancellationPhotoUrl,
    );
  }

  @override
  String toString() {
    return 'Sale(id: $id, sessionId: $sessionId, businessId: $businessId, cashierId: $cashierId, items: $items, total: $total, paymentMethod: $paymentMethod, status: $status, timestamp: $timestamp, isSynced: $isSynced, syncError: $syncError, cancellationPhotoUrl: $cancellationPhotoUrl)';
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
