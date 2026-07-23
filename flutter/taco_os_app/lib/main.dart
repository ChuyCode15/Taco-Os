import 'package:flutter/material.dart';

import 'injection_container.dart' as di;
import 'infrastructure/services/sync_service.dart';
import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise the get_it dependency injection container.
  // The full implementation will be added in Task 10.
  await di.init();

  // Requirement 11.3: Implementar sincronización de catálogo al inicio de la app
  // Task 11.3: Initialize catalog synchronization at app startup
  await _initializeCatalogSync();

  // Requirement 13.5: Iniciar SyncService en su isolate de Dart separado
  // Requirement 11.1: Ejecutar ciclo de sync cada 5 minutos usando isolate separado
  // Task 25.2: Start SyncService in its background Dart isolate
  await _startSyncService();

  runApp(const App());
}

/// Inicia el SyncService para sincronización periódica de transacciones
///
/// **Requirement 13.5**: Iniciar SyncService en su isolate de Dart separado
/// **Requirement 11.1**: Ejecutar ciclo de sync cada 5 minutos usando isolate
///
/// **Task 25.2**: Iniciar SyncService en su isolate de fondo para
/// sincronización periódica de transacciones:
/// - Prioridad: cash_sessions → sales → expenses → cortes
/// - Ciclo cada 5 minutos
/// - Lote máximo: 100 transacciones por ciclo
///
/// NOTA: El SyncService actualmente usa Timer en el isolate principal por
/// simplicidad de implementación. La estructura está preparada para migrar
/// a isolate separado cuando todas las dependencias sean serializables.
Future<void> _startSyncService() async {
  try {
    // Obtener el servicio de sincronización del contenedor DI
    final syncService = di.sl<ISyncService>();

    // Requirement 11.1: Iniciar el servicio de sincronización en background
    // Esto inicia el ciclo periódico de 5 minutos para:
    // - Sincronizar transacciones pendientes con el backend
    // - Detectar cambios de conectividad
    // - Activar sync inmediato al recuperar conexión
    await syncService.start();

    debugPrint('SyncService iniciado correctamente');
  } catch (e) {
    // Si falla la inicialización del SyncService, la app debe continuar
    // funcionando en modo offline. El usuario podrá intentar sync manual.
    debugPrint('Error al iniciar SyncService: $e');
    // No relanzamos el error - la app debe poder iniciar en modo offline
  }
}

/// Sincroniza el catálogo de productos al iniciar la app
///
/// **Requirement 11.2**: Al iniciar la app con conectividad, llamar
/// ProductRepository.syncCatalog() con timeout de 30s
///
/// **Requirement 11.4**: Si falla o excede el timeout, conservar productos
/// existentes en Local_DB sin modificarlos
///
/// **Requirement 11.5**: Si catálogo local vacío y se recupera conectividad,
/// iniciar descarga automática
///
/// **Task 11.3**: Implementar sincronización de catálogo al inicio de la app
///
/// NOTA: Esta función usa un business_id placeholder porque el SessionRepository
/// y el flujo de autenticación completo aún no están implementados.
/// En producción, el business_id se obtendrá del usuario autenticado.
/// TODO: Obtener business_id del contexto de autenticación cuando esté disponible
Future<void> _initializeCatalogSync() async {
  try {
    // Obtener el servicio de sincronización del contenedor DI
    final syncService = di.sl<ISyncService>();

    // TODO: Obtener business_id del usuario autenticado
    // Por ahora usamos un placeholder para la estructura
    // En producción, esto vendría de:
    // 1. Verificar si hay un usuario autenticado (CheckSessionUseCase)
    // 2. Obtener el business_id del usuario/sesión activa
    //
    // Ejemplo de implementación futura:
    // final authRepo = di.sl<IAuthRepository>();
    // final userResult = await authRepo.getCurrentUser();
    // userResult.fold(
    //   (failure) => return, // No hay usuario autenticado, no sincronizar
    //   (user) async {
    //     if (user?.businessId != null) {
    //       await syncService.syncCatalogOnStartup(user!.businessId);
    //     }
    //   },
    // );

    const businessId = 'BUSINESS_ID_PLACEHOLDER';

    // Requirement 11.2: Llamar syncCatalog() con timeout de 30s
    // Requirement 11.4: Si falla o excede timeout, conservar productos existentes
    // El timeout y manejo de errores está implementado en SyncServiceImpl.syncCatalogOnStartup
    await syncService.syncCatalogOnStartup(businessId);

    // Nota: Los errores se manejan silenciosamente dentro de syncCatalogOnStartup
    // para no bloquear el inicio de la app
  } catch (e) {
    // Requirement 11.4: En cualquier error, la app debe continuar funcionando
    // Capturamos cualquier excepción inesperada para no bloquear el inicio
    debugPrint('Error al inicializar sincronización de catálogo: $e');
    // No relanzamos el error - la app debe poder iniciar incluso si falla la sync
  }
}
