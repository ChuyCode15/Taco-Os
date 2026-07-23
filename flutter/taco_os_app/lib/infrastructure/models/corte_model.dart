import '../../domain/entities/corte.dart';

/// Modelo de infraestructura para Corte con serialización JSON
///
/// Este modelo se utiliza para la comunicación con la API y la persistencia local,
/// proporcionando conversión bidireccional entre JSON y la entidad de dominio.
/// Maneja la serialización de DateTime a formato ISO 8601.
///
/// Validada por Requirement 13.1: Clean Architecture - Infrastructure layer
class CorteModel {
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
  final String closedAt;
  final bool isSynced;
  final String? syncError;

  const CorteModel({
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
    required this.isSynced,
    this.syncError,
  });

  /// Crea un modelo desde JSON (deserialización de API)
  factory CorteModel.fromJson(Map<String, dynamic> json) {
    return CorteModel(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      businessId: json['businessId'] as String,
      cashierId: json['cashierId'] as String,
      totalCashSales: (json['totalCashSales'] as num).toDouble(),
      totalCardSales: (json['totalCardSales'] as num).toDouble(),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      openingBalance: (json['openingBalance'] as num).toDouble(),
      countedCash: (json['countedCash'] as num).toDouble(),
      difference: (json['difference'] as num).toDouble(),
      closedAt: json['closedAt'] as String,
      isSynced: json['isSynced'] as bool? ?? false,
      syncError: json['syncError'] as String?,
    );
  }

  /// Convierte el modelo a JSON (serialización para API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'businessId': businessId,
      'cashierId': cashierId,
      'totalCashSales': totalCashSales,
      'totalCardSales': totalCardSales,
      'totalExpenses': totalExpenses,
      'openingBalance': openingBalance,
      'countedCash': countedCash,
      'difference': difference,
      'closedAt': closedAt,
      'isSynced': isSynced,
      'syncError': syncError,
    };
  }

  /// Convierte el modelo a entidad de dominio
  Corte toEntity() {
    return Corte(
      id: id,
      sessionId: sessionId,
      businessId: businessId,
      cashierId: cashierId,
      totalCashSales: totalCashSales,
      totalCardSales: totalCardSales,
      totalExpenses: totalExpenses,
      openingBalance: openingBalance,
      countedCash: countedCash,
      difference: difference,
      closedAt: DateTime.parse(closedAt),
      isSynced: isSynced,
      syncError: syncError,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory CorteModel.fromEntity(Corte entity) {
    return CorteModel(
      id: entity.id,
      sessionId: entity.sessionId,
      businessId: entity.businessId,
      cashierId: entity.cashierId,
      totalCashSales: entity.totalCashSales,
      totalCardSales: entity.totalCardSales,
      totalExpenses: entity.totalExpenses,
      openingBalance: entity.openingBalance,
      countedCash: entity.countedCash,
      difference: entity.difference,
      closedAt: entity.closedAt.toIso8601String(),
      isSynced: entity.isSynced,
      syncError: entity.syncError,
    );
  }
}
