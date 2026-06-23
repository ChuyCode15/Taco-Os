import '../../domain/entities/sale.dart';
import 'sale_item_model.dart';

/// Modelo de infraestructura para Sale con serialización JSON
///
/// Este modelo se utiliza para la comunicación con la API y la persistencia local,
/// proporcionando conversión bidireccional entre JSON y la entidad de dominio.
/// Maneja la serialización de enums (PaymentMethod, SaleStatus) y objetos anidados (SaleItem).
///
/// Validada por Requirement 13.1: Clean Architecture - Infrastructure layer
class SaleModel {
  final String id;
  final String sessionId;
  final String businessId;
  final String cashierId;
  final List<SaleItemModel> items;
  final double total;
  final String paymentMethod;
  final String status;
  final String timestamp;
  final bool isSynced;
  final String? syncError;
  final String? cancellationPhotoUrl;

  const SaleModel({
    required this.id,
    required this.sessionId,
    required this.businessId,
    required this.cashierId,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.timestamp,
    required this.isSynced,
    this.syncError,
    this.cancellationPhotoUrl,
  });

  /// Crea un modelo desde JSON (deserialización de API)
  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      businessId: json['businessId'] as String,
      cashierId: json['cashierId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => SaleItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      isSynced: json['isSynced'] as bool? ?? false,
      syncError: json['syncError'] as String?,
      cancellationPhotoUrl: json['cancellationPhotoUrl'] as String?,
    );
  }

  /// Convierte el modelo a JSON (serialización para API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'businessId': businessId,
      'cashierId': cashierId,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'paymentMethod': paymentMethod,
      'status': status,
      'timestamp': timestamp,
      'isSynced': isSynced,
      'syncError': syncError,
      'cancellationPhotoUrl': cancellationPhotoUrl,
    };
  }

  /// Convierte el modelo a entidad de dominio
  Sale toEntity() {
    return Sale(
      id: id,
      sessionId: sessionId,
      businessId: businessId,
      cashierId: cashierId,
      items: items.map((item) => item.toEntity()).toList(),
      total: total,
      paymentMethod: _parsePaymentMethod(paymentMethod),
      status: _parseSaleStatus(status),
      timestamp: DateTime.parse(timestamp),
      isSynced: isSynced,
      syncError: syncError,
      cancellationPhotoUrl: cancellationPhotoUrl,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory SaleModel.fromEntity(Sale entity) {
    return SaleModel(
      id: entity.id,
      sessionId: entity.sessionId,
      businessId: entity.businessId,
      cashierId: entity.cashierId,
      items: entity.items
          .map((item) => SaleItemModel.fromEntity(item))
          .toList(),
      total: entity.total,
      paymentMethod: _serializePaymentMethod(entity.paymentMethod),
      status: _serializeSaleStatus(entity.status),
      timestamp: entity.timestamp.toIso8601String(),
      isSynced: entity.isSynced,
      syncError: entity.syncError,
      cancellationPhotoUrl: entity.cancellationPhotoUrl,
    );
  }

  /// Convierte string a enum PaymentMethod
  static PaymentMethod _parsePaymentMethod(String value) {
    switch (value) {
      case 'cash':
        return PaymentMethod.cash;
      case 'card':
        return PaymentMethod.card;
      default:
        throw ArgumentError('Unknown payment method: $value');
    }
  }

  /// Convierte enum PaymentMethod a string
  static String _serializePaymentMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.card:
        return 'card';
    }
  }

  /// Convierte string a enum SaleStatus
  static SaleStatus _parseSaleStatus(String value) {
    switch (value) {
      case 'completed':
        return SaleStatus.completed;
      case 'cancelled':
        return SaleStatus.cancelled;
      default:
        throw ArgumentError('Unknown sale status: $value');
    }
  }

  /// Convierte enum SaleStatus a string
  static String _serializeSaleStatus(SaleStatus status) {
    switch (status) {
      case SaleStatus.completed:
        return 'completed';
      case SaleStatus.cancelled:
        return 'cancelled';
    }
  }
}
