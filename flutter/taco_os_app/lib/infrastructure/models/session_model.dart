import '../../domain/entities/cash_session.dart';

/// Modelo de infraestructura para CashSession con serialización JSON
///
/// Este modelo se utiliza para la comunicación con la API y la persistencia local,
/// proporcionando conversión bidireccional entre JSON y la entidad de dominio.
/// Maneja la serialización del enum SessionStatus y DateTime a formato ISO 8601.
///
/// Validada por Requirement 13.1: Clean Architecture - Infrastructure layer
class SessionModel {
  final String id;
  final String businessId;
  final String userId;
  final double initialCash;
  final String status;
  final String openedAt;
  final String? closedAt;
  final double? countedCash;
  final double? difference;

  const SessionModel({
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

  /// Crea un modelo desde JSON (deserialización de API)
  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      userId: json['userId'] as String,
      initialCash: (json['initialCash'] as num).toDouble(),
      status: json['status'] as String,
      openedAt: json['openedAt'] as String,
      closedAt: json['closedAt'] as String?,
      countedCash: json['countedCash'] != null
          ? (json['countedCash'] as num).toDouble()
          : null,
      difference: json['difference'] != null
          ? (json['difference'] as num).toDouble()
          : null,
    );
  }

  /// Convierte el modelo a JSON (serialización para API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'userId': userId,
      'initialCash': initialCash,
      'status': status,
      'openedAt': openedAt,
      'closedAt': closedAt,
      'countedCash': countedCash,
      'difference': difference,
    };
  }

  /// Convierte el modelo a entidad de dominio
  CashSession toEntity() {
    return CashSession(
      id: id,
      businessId: businessId,
      userId: userId,
      initialCash: initialCash,
      status: _parseSessionStatus(status),
      openedAt: DateTime.parse(openedAt),
      closedAt: closedAt != null ? DateTime.parse(closedAt!) : null,
      countedCash: countedCash,
      difference: difference,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory SessionModel.fromEntity(CashSession entity) {
    return SessionModel(
      id: entity.id,
      businessId: entity.businessId,
      userId: entity.userId,
      initialCash: entity.initialCash,
      status: _serializeSessionStatus(entity.status),
      openedAt: entity.openedAt.toIso8601String(),
      closedAt: entity.closedAt?.toIso8601String(),
      countedCash: entity.countedCash,
      difference: entity.difference,
    );
  }

  /// Convierte string a enum SessionStatus
  static SessionStatus _parseSessionStatus(String value) {
    switch (value) {
      case 'open':
        return SessionStatus.open;
      case 'closed':
        return SessionStatus.closed;
      default:
        throw ArgumentError('Unknown session status: $value');
    }
  }

  /// Convierte enum SessionStatus a string
  static String _serializeSessionStatus(SessionStatus status) {
    switch (status) {
      case SessionStatus.open:
        return 'open';
      case SessionStatus.closed:
        return 'closed';
    }
  }
}
