/// Entidad de dominio que representa el resumen de un turno activo
///
/// Esta es una entidad inmutable que representa el estado actual de un turno
/// incluyendo totales de ventas, gastos y efectivo esperado, utilizada
/// principalmente en la vista "¿Cómo voy?".
///
/// Validada por Requirement 8.1: Vista "¿Cómo voy?" — Resumen del Turno
/// Validada por Requirement 9.5: Corte de Caja usa cálculo de efectivo esperado
/// Validada por Requirement 13.1: Arquitectura Clean Code
class ShiftSummary {
  final int transactionCount;
  final double totalSales;
  final double totalCash;
  final double totalCard;
  final double totalExpenses;
  final double expectedCash;

  const ShiftSummary({
    required this.transactionCount,
    required this.totalSales,
    required this.totalCash,
    required this.totalCard,
    required this.totalExpenses,
    required this.expectedCash,
  });

  /// Verifica si el turno tiene transacciones registradas
  bool get hasTransactions => transactionCount > 0;

  /// Verifica si el resumen está vacío
  bool get isEmpty => transactionCount == 0;

  /// Crea una copia de la entidad con campos actualizados
  ShiftSummary copyWith({
    int? transactionCount,
    double? totalSales,
    double? totalCash,
    double? totalCard,
    double? totalExpenses,
    double? expectedCash,
  }) {
    return ShiftSummary(
      transactionCount: transactionCount ?? this.transactionCount,
      totalSales: totalSales ?? this.totalSales,
      totalCash: totalCash ?? this.totalCash,
      totalCard: totalCard ?? this.totalCard,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      expectedCash: expectedCash ?? this.expectedCash,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShiftSummary &&
        other.transactionCount == transactionCount &&
        other.totalSales == totalSales &&
        other.totalCash == totalCash &&
        other.totalCard == totalCard &&
        other.totalExpenses == totalExpenses &&
        other.expectedCash == expectedCash;
  }

  @override
  int get hashCode {
    return Object.hash(
      transactionCount,
      totalSales,
      totalCash,
      totalCard,
      totalExpenses,
      expectedCash,
    );
  }

  @override
  String toString() {
    return 'ShiftSummary(transactionCount: $transactionCount, totalSales: $totalSales, totalCash: $totalCash, totalCard: $totalCard, totalExpenses: $totalExpenses, expectedCash: $expectedCash)';
  }
}
