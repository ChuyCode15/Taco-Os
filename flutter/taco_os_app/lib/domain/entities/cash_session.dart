/// Enumeración de estados de una sesión de caja
///
/// Validada por Requirement 3: Apertura de Caja (Inicio de Turno)
/// Validada por Requirement 9: Corte de Caja
enum SessionStatus {
  /// Sesión de caja abierta, el cajero puede registrar transacciones
  open,

  /// Sesión de caja cerrada, el cajero ha completado el corte
  closed,
}

/// Entidad de dominio que representa una sesión de caja (turno)
///
/// Esta es una entidad inmutable que representa el concepto de un turno
/// de trabajo, desde la apertura de caja hasta el corte final.
///
/// Validada por Requirement 13.1: Arquitectura Clean Code
/// Validada por Requirement 15.1: Aislamiento Multi-Tenant
class CashSession {
  final String id;
  final String businessId;
  final String userId;
  final double initialCash;
  final SessionStatus status;
  final DateTime openedAt;
  final DateTime? closedAt;
  final double? countedCash;
  final double? difference;

  const CashSession({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.initialCash,
    required this.status,
    required this.openedAt,
    this.closedAt,
    this.countedCash,
    this.difference,
  });

  /// Verifica si la sesión está activa (abierta)
  bool get isActive => status == SessionStatus.open;

  /// Verifica si la sesión está cerrada
  bool get isClosed => status == SessionStatus.closed;

  /// Calcula la duración de la sesión
  Duration get duration {
    final endTime = closedAt ?? DateTime.now();
    return endTime.difference(openedAt);
  }

  /// Crea una copia de la entidad con campos actualizados
  CashSession copyWith({
    String? id,
    String? businessId,
    String? userId,
    double? initialCash,
    SessionStatus? status,
    DateTime? openedAt,
    DateTime? closedAt,
    double? countedCash,
    double? difference,
  }) {
    return CashSession(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      userId: userId ?? this.userId,
      initialCash: initialCash ?? this.initialCash,
      status: status ?? this.status,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      countedCash: countedCash ?? this.countedCash,
      difference: difference ?? this.difference,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CashSession &&
        other.id == id &&
        other.businessId == businessId &&
        other.userId == userId &&
        other.initialCash == initialCash &&
        other.status == status &&
        other.openedAt == openedAt &&
        other.closedAt == closedAt &&
        other.countedCash == countedCash &&
        other.difference == difference;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      businessId,
      userId,
      initialCash,
      status,
      openedAt,
      closedAt,
      countedCash,
      difference,
    );
  }

  @override
  String toString() {
    return 'CashSession(id: $id, businessId: $businessId, userId: $userId, initialCash: $initialCash, status: $status, openedAt: $openedAt, closedAt: $closedAt, countedCash: $countedCash, difference: $difference)';
  }
}
