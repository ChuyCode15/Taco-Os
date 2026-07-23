/// Entidad de dominio que representa un corte de caja
///
/// Esta entidad representa el cierre formal de un turno con el conteo
/// de efectivo físico y el cálculo de diferencias (sobrante/faltante).
///
/// Validada por Requirement 9.4: Registro de cierre de turno
/// Validada por Requirement 9.5: Cálculo de diferencia entre efectivo esperado y contado
/// Validada por Requirement 13.1: Arquitectura Clean Code
/// Validada por Requirement 15.1: Aislamiento Multi-Tenant
class Corte {
  final String id;
  final String sessionId;
  final String businessId;
  final String cashierId;
  final double totalCashSales;
  final double totalCardSales;
  final double totalExpenses;
  final double openingBalance;
  final double countedCash;
  final double difference;
  final DateTime closedAt;
  final bool isSynced;
  final String? syncError;

  const Corte({
    required this.id,
    required this.sessionId,
    required this.businessId,
    required this.cashierId,
    required this.totalCashSales,
    required this.totalCardSales,
    required this.totalExpenses,
    required this.openingBalance,
    required this.countedCash,
    required this.difference,
    required this.closedAt,
    this.isSynced = false,
    this.syncError,
  });

  /// Verifica si el corte tiene un sobrante de efectivo
  bool get hasSurplus => difference > 0;

  /// Verifica si el corte tiene un faltante de efectivo
  bool get hasShortage => difference < 0;

  /// Verifica si el corte está cuadrado (sin diferencia)
  bool get isBalanced => difference == 0;

  /// Crea una copia de la entidad con campos actualizados
  Corte copyWith({
    String? id,
    String? sessionId,
    String? businessId,
    String? cashierId,
    double? totalCashSales,
    double? totalCardSales,
    double? totalExpenses,
    double? openingBalance,
    double? countedCash,
    double? difference,
    DateTime? closedAt,
    bool? isSynced,
    String? syncError,
  }) {
    return Corte(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      businessId: businessId ?? this.businessId,
      cashierId: cashierId ?? this.cashierId,
      totalCashSales: totalCashSales ?? this.totalCashSales,
      totalCardSales: totalCardSales ?? this.totalCardSales,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      openingBalance: openingBalance ?? this.openingBalance,
      countedCash: countedCash ?? this.countedCash,
      difference: difference ?? this.difference,
      closedAt: closedAt ?? this.closedAt,
      isSynced: isSynced ?? this.isSynced,
      syncError: syncError ?? this.syncError,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Corte &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.businessId == businessId &&
        other.cashierId == cashierId &&
        other.totalCashSales == totalCashSales &&
        other.totalCardSales == totalCardSales &&
        other.totalExpenses == totalExpenses &&
        other.openingBalance == openingBalance &&
        other.countedCash == countedCash &&
        other.difference == difference &&
        other.closedAt == closedAt &&
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
      totalCashSales,
      totalCardSales,
      totalExpenses,
      openingBalance,
      countedCash,
      difference,
      closedAt,
      isSynced,
      syncError,
    );
  }

  @override
  String toString() {
    return 'Corte(id: $id, sessionId: $sessionId, businessId: $businessId, cashierId: $cashierId, totalCashSales: $totalCashSales, totalCardSales: $totalCardSales, totalExpenses: $totalExpenses, openingBalance: $openingBalance, countedCash: $countedCash, difference: $difference, closedAt: $closedAt, isSynced: $isSynced, syncError: $syncError)';
  }
}
