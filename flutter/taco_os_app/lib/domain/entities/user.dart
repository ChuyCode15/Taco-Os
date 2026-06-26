/// Enumeración de roles de usuario en el sistema Taco'Os
///
/// Justification: Backend uses "dueño" (owner) as the role name for business
/// owners. Renamed from "patron" to "dueno" for consistency with backend
/// API responses. This avoids runtime role comparison mismatches.
enum UserRole {
  /// Usuario de rol operativo que registra ventas, gastos y realiza cortes
  cajero,

  /// Usuario de rol administrativo (dueño del negocio)
  /// Backend sends: "rol": "dueño"
  dueno,
}

/// Entidad de dominio que representa un usuario del sistema
///
/// Esta es una entidad inmutable que representa el concepto de negocio
/// de un usuario, sin dependencias externas según Clean Architecture.
///
/// Validada por Requirement 13.1: Arquitectura Clean Code
class User {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? businessId;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.businessId,
    required this.createdAt,
  });

  /// Crea una copia de la entidad con campos actualizados
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    UserRole? role,
    String? businessId,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      businessId: businessId ?? this.businessId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.role == role &&
        other.businessId == businessId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, email, displayName, role, businessId, createdAt);
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName, role: $role, businessId: $businessId, createdAt: $createdAt)';
  }
}
