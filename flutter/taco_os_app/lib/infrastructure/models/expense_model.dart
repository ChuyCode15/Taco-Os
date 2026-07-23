import '../../domain/entities/expense.dart';

/// Modelo de infraestructura para Expense con serialización JSON
///
/// Este modelo se utiliza para la comunicación con la API y la persistencia local,
/// proporcionando conversión bidireccional entre JSON y la entidad de dominio.
/// Maneja la serialización de DateTime a formato ISO 8601.
///
/// Validada por Requirement 13.1: Clean Architecture - Infrastructure layer
class ExpenseModel {
  final String id;
  final String sessionId;
  final String businessId;
  final String cashierId;
  final String description;
  final double amount;
  final String timestamp;
  final bool isSynced;
  final String? syncError;

  const ExpenseModel({
    required this.id,
    required this.sessionId,
    required this.businessId,
    required this.cashierId,
    required this.description,
    required this.amount,
    required this.timestamp,
    required this.isSynced,
    this.syncError,
  });

  /// Crea un modelo desde JSON (deserialización de API)
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      businessId: json['businessId'] as String,
      cashierId: json['cashierId'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: json['timestamp'] as String,
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
      'description': description,
      'amount': amount,
      'timestamp': timestamp,
      'isSynced': isSynced,
      'syncError': syncError,
    };
  }

  /// Convierte el modelo a entidad de dominio
  Expense toEntity() {
    return Expense(
      id: id,
      sessionId: sessionId,
      businessId: businessId,
      cashierId: cashierId,
      description: description,
      amount: amount,
      timestamp: DateTime.parse(timestamp),
      isSynced: isSynced,
      syncError: syncError,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory ExpenseModel.fromEntity(Expense entity) {
    return ExpenseModel(
      id: entity.id,
      sessionId: entity.sessionId,
      businessId: entity.businessId,
      cashierId: entity.cashierId,
      description: entity.description,
      amount: entity.amount,
      timestamp: entity.timestamp.toIso8601String(),
      isSynced: entity.isSynced,
      syncError: entity.syncError,
    );
  }
}
