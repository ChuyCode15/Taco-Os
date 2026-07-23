/// Entidad de dominio que representa un gasto del turno
///
/// Esta es una entidad inmutable que representa un gasto operativo
/// registrado durante una sesión de caja (compra de insumos, servicios, etc.).
///
/// Validada por Requirement 7.2: Registro Rápido de Gastos con validaciones
/// Validada por Requirement 8.1: Vista "¿Cómo voy?" incluye gastos
/// Validada por Requirement 9.5: Corte de Caja incluye total de gastos
/// Validada por Requirement 13.1: Arquitectura Clean Code
/// Validada por Requirement 15.1: Aislamiento Multi-Tenant
class Expense {
  final String id;
  final String sessionId;
  final String businessId;
  final String cashierId;
  final String description;
  final double amount;
  final DateTime timestamp;
  final bool isSynced;
  final String? syncError;

  const Expense({
    required this.id,
    required this.sessionId,
    required this.businessId,
    required this.cashierId,
    required this.description,
    required this.amount,
    required this.timestamp,
    this.isSynced = false,
    this.syncError,
  });

  /// Crea una copia de la entidad con campos actualizados
  Expense copyWith({
    String? id,
    String? sessionId,
    String? businessId,
    String? cashierId,
    String? description,
    double? amount,
    DateTime? timestamp,
    bool? isSynced,
    String? syncError,
  }) {
    return Expense(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      businessId: businessId ?? this.businessId,
      cashierId: cashierId ?? this.cashierId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
      syncError: syncError ?? this.syncError,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.businessId == businessId &&
        other.cashierId == cashierId &&
        other.description == description &&
        other.amount == amount &&
        other.timestamp == timestamp &&
        other.isSynced == isSynced &&
        other.syncError == syncError;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      sessionId,
      businessId,
      cashierId,
      description,
      amount,
      timestamp,
      isSynced,
      syncError,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, sessionId: $sessionId, businessId: $businessId, cashierId: $cashierId, description: $description, amount: $amount, timestamp: $timestamp, isSynced: $isSynced, syncError: $syncError)';
  }
}
