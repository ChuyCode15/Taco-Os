/// Enumeración de tipos de notificaciones del sistema
///
/// Validada por Requirement 6.4: Notificación de cancelaciones
/// Validada por Requirement 9.5: Notificación de sobrantes y faltantes en corte
enum NotificationType {
  /// Notificación de cancelación de venta
  cancellation,

  /// Notificación de sobrante de efectivo en corte
  surplus,

  /// Notificación de faltante de efectivo en corte
  shortage,

  /// Notificación de cierre automático de turno
  autoClose,
}

/// Entidad de dominio que representa una notificación del sistema
///
/// Esta es una entidad inmutable que representa alertas y notificaciones
/// dirigidas al Patrón sobre eventos importantes del sistema.
///
/// Validada por Requirement 6.4: Cancelación de Ventas genera notificación
/// Validada por Requirement 9.5: Corte de Caja genera notificación de diferencias
/// Validada por Requirement 13.1: Arquitectura Clean Code
/// Validada por Requirement 15.1: Aislamiento Multi-Tenant
class Notification {
  final String id;
  final String businessId;
  final NotificationType type;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const Notification({
    required this.id,
    required this.businessId,
    required this.type,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  /// Verifica si la notificación ha sido leída
  bool get isUnread => !isRead;

  /// Crea una copia de la entidad con campos actualizados
  Notification copyWith({
    String? id,
    String? businessId,
    NotificationType? type,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      type: type ?? this.type,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification &&
        other.id == id &&
        other.businessId == businessId &&
        other.type == type &&
        other.message == message &&
        other.isRead == isRead &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, businessId, type, message, isRead, createdAt);
  }

  @override
  String toString() {
    return 'Notification(id: $id, businessId: $businessId, type: $type, message: $message, isRead: $isRead, createdAt: $createdAt)';
  }
}
