/// Enumeración de planes de suscripción disponibles
///
/// Validada por Requirement 14: Planes de Suscripción y Límites de Uso
/// Validada por Requirement 15.1: Seguridad y Aislamiento Multi-Tenant
enum SubscriptionPlan {
  /// Plan gratuito: 1 negocio, 2 cajeros
  free,

  /// Plan premium: 2 negocios, 5 cajeros
  premium,

  /// Plan business: 5 negocios, 25 cajeros, módulos de IA
  business,
}

/// Entidad de dominio que representa un negocio (taquería)
///
/// Esta es una entidad inmutable que encapsula el concepto de negocio
/// del sistema, incluyendo su plan de suscripción y límites asociados.
///
/// Validada por Requirement 13.1: Arquitectura Clean Code
/// Validada por Requirement 15.1: Aislamiento Multi-Tenant
class Business {
  final String id;
  final String name;
  final String ownerId;
  final SubscriptionPlan subscriptionPlan;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Business({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.subscriptionPlan,
    required this.createdAt,
    this.updatedAt,
  });

  /// Obtiene el límite de negocios según el plan de suscripción
  int get businessLimit {
    switch (subscriptionPlan) {
      case SubscriptionPlan.free:
        return 1;
      case SubscriptionPlan.premium:
        return 2;
      case SubscriptionPlan.business:
        return 5;
    }
  }

  /// Obtiene el límite de cajeros según el plan de suscripción
  int get cajeroLimit {
    switch (subscriptionPlan) {
      case SubscriptionPlan.free:
        return 2;
      case SubscriptionPlan.premium:
        return 5;
      case SubscriptionPlan.business:
        return 25;
    }
  }

  /// Indica si el plan incluye módulos de inteligencia artificial
  bool get hasAiModules => subscriptionPlan == SubscriptionPlan.business;

  /// Crea una copia de la entidad con campos actualizados
  Business copyWith({
    String? id,
    String? name,
    String? ownerId,
    SubscriptionPlan? subscriptionPlan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Business &&
        other.id == id &&
        other.name == name &&
        other.ownerId == ownerId &&
        other.subscriptionPlan == subscriptionPlan &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      ownerId,
      subscriptionPlan,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Business(id: $id, name: $name, ownerId: $ownerId, subscriptionPlan: $subscriptionPlan, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
