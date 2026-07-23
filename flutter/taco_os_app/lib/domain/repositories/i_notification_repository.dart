import 'package:fpdart/fpdart.dart';
import '../entities/notification.dart';
import '../../core/errors/failures.dart';

/// Repositorio abstracto de notificaciones del sistema
///
/// Define las operaciones de consulta y actualización de notificaciones
/// dirigidas al Patrón sobre eventos importantes: cancelaciones de venta,
/// sobrantes/faltantes en cortes y cierres automáticos de turno.
///
/// Validada por Requirement 6.4: Notificaciones de cancelación de ventas
/// Validada por Requirement 9.5: Notificaciones de diferencias en cortes
/// Validada por Requirement 12.5: Badge de notificaciones en Dashboard del Patrón
/// Validada por Requirement 13.2: Interfaces abstractas para repositorios
abstract class INotificationRepository {
  /// Obtiene las notificaciones no leídas de un negocio
  ///
  /// Recupera todas las notificaciones con isRead = false para mostrar
  /// en el badge del Dashboard del Patrón. Se filtran por business_id
  /// para mantener aislamiento multi-tenant.
  ///
  /// Parameters:
  /// - businessId: Identificador del negocio (aislamiento multi-tenant)
  ///
  /// Returns:
  /// - Right(List&lt;Notification&gt;): Lista de notificaciones no leídas ordenadas por fecha (más recientes primero)
  /// - Left(LocalDatabaseFailure): Error al leer de la base de datos local
  ///
  /// Validada por Requirement 12.5: Badge con número de alertas pendientes
  /// Validada por Requirement 15.2: Filtrado por business_id
  Future<Either<Failure, List<Notification>>> getUnread(String businessId);

  /// Marca una notificación como leída
  ///
  /// Actualiza el flag isRead = true para la notificación especificada.
  /// Utilizado cuando el Patrón abre y revisa una notificación en el Dashboard.
  ///
  /// Parameters:
  /// - notificationId: Identificador de la notificación a marcar como leída
  ///
  /// Returns:
  /// - Right(void): Notificación marcada exitosamente
  /// - Left(LocalDatabaseFailure): Error al actualizar la base de datos
  /// - Left(ValidationFailure): Notificación no encontrada
  ///
  /// Validada por Requirement 12.5: Actualización del badge tras leer notificaciones
  Future<Either<Failure, void>> markAsRead(String notificationId);
}
