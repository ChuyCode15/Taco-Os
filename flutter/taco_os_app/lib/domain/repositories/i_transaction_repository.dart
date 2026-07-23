import 'package:fpdart/fpdart.dart';
import '../entities/sale.dart';
import '../entities/expense.dart';
import '../entities/corte.dart';
import '../../core/errors/failures.dart';

/// Repositorio abstracto de transacciones (ventas, gastos y cortes)
///
/// Define las operaciones de persistencia y recuperación de transacciones
/// del turno activo. Separa claramente las responsabilidades: un método
/// por tipo de operación (ventas, gastos, cortes).
///
/// Validada por Requirement 5.6: Registro de Ventas
/// Validada por Requirement 6.4: Cancelación de Ventas con foto
/// Validada por Requirement 7.2: Registro Rápido de Gastos
/// Validada por Requirement 9.4: Corte de Caja
/// Validada por Requirement 13.3: Métodos separados por tipo de entidad
abstract class ITransactionRepository {
  // ==================== OPERACIONES DE VENTAS ====================

  /// Guarda una venta en la base de datos local
  ///
  /// Persiste la venta con is_synced = false para sincronización posterior.
  /// La venta incluye método de pago, productos y timestamp.
  ///
  /// Parameters:
  /// - sale: Entidad Sale a persistir
  ///
  /// Returns:
  /// - Right(Sale): Venta guardada exitosamente
  /// - Left(LocalDatabaseFailure): Error al escribir en la base de datos local
  /// - Left(ValidationFailure): Datos de la venta inválidos
  ///
  /// Validada por Requirement 5.6: Registro de ventas con método de pago
  /// Validada por Requirement 13.3: Método separado para operaciones de venta
  Future<Either<Failure, Sale>> saveSale(Sale sale);

  /// Cancela una venta dentro de la ventana anti-fraude (5 minutos)
  ///
  /// Marca la venta como cancelada, asocia la foto obligatoria y revierte
  /// el efecto de la venta en los totales del turno. Solo permite cancelación
  /// si han transcurrido menos de 5 minutos desde el registro.
  ///
  /// Parameters:
  /// - saleId: Identificador de la venta a cancelar
  /// - photoPath: Ruta de la foto obligatoria del producto devuelto
  ///
  /// Returns:
  /// - Right(Sale): Venta cancelada exitosamente con foto asociada
  /// - Left(ValidationFailure): Venta fuera de ventana anti-fraude o foto faltante
  /// - Left(LocalDatabaseFailure): Error al actualizar la base de datos
  /// - Left(CameraFailure): Cámara no disponible para capturar foto
  ///
  /// Validada por Requirement 6.4: Cancelación con foto obligatoria
  /// Validada por Requirement 6.1: Ventana anti-fraude de 5 minutos
  /// Validada por Requirement 13.3: Método separado para cancelación
  Future<Either<Failure, Sale>> cancelSale(String saleId, String photoPath);

  /// Obtiene las ventas pendientes de sincronización de una sesión
  ///
  /// Recupera todas las ventas con is_synced = false para el turno especificado.
  /// Utilizado por el SyncService para identificar transacciones pendientes.
  ///
  /// Parameters:
  /// - sessionId: Identificador del turno activo
  ///
  /// Returns:
  /// - Right(List<Sale>): Lista de ventas pendientes (puede estar vacía)
  /// - Left(LocalDatabaseFailure): Error al leer de la base de datos
  ///
  /// Validada por Requirement 10.2: Flag is_synced = false hasta sincronización
  /// Validada por Requirement 13.3: Método separado para consulta de ventas
  Future<Either<Failure, List<Sale>>> getPendingSales(String sessionId);

  // ==================== OPERACIONES DE GASTOS ====================

  /// Guarda un gasto en la base de datos local
  ///
  /// Persiste el gasto con is_synced = false para sincronización posterior.
  /// El gasto incluye descripción (max 100 chars) y monto.
  ///
  /// Parameters:
  /// - expense: Entidad Expense a persistir
  ///
  /// Returns:
  /// - Right(Expense): Gasto guardado exitosamente
  /// - Left(LocalDatabaseFailure): Error al escribir en la base de datos local
  /// - Left(ValidationFailure): Datos del gasto inválidos (monto, descripción)
  ///
  /// Validada por Requirement 7.2: Registro rápido de gastos con validaciones
  /// Validada por Requirement 13.3: Método separado para operaciones de gasto
  Future<Either<Failure, Expense>> saveExpense(Expense expense);

  /// Obtiene los gastos pendientes de sincronización de una sesión
  ///
  /// Recupera todos los gastos con is_synced = false para el turno especificado.
  /// Utilizado por el SyncService para identificar transacciones pendientes.
  ///
  /// Parameters:
  /// - sessionId: Identificador del turno activo
  ///
  /// Returns:
  /// - Right(List<Expense>): Lista de gastos pendientes (puede estar vacía)
  /// - Left(LocalDatabaseFailure): Error al leer de la base de datos
  ///
  /// Validada por Requirement 10.2: Flag is_synced = false hasta sincronización
  /// Validada por Requirement 13.3: Método separado para consulta de gastos
  Future<Either<Failure, List<Expense>>> getPendingExpenses(String sessionId);

  // ==================== OPERACIONES DE CORTE ====================

  /// Guarda un corte de caja en la base de datos local
  ///
  /// Persiste el corte con is_synced = false para sincronización posterior.
  /// El corte incluye conteo de efectivo, cálculo de diferencias y totales
  /// del turno (ventas en efectivo, ventas con tarjeta, gastos).
  ///
  /// Parameters:
  /// - corte: Entidad Corte a persistir
  ///
  /// Returns:
  /// - Right(Corte): Corte guardado exitosamente
  /// - Left(LocalDatabaseFailure): Error al escribir en la base de datos local
  /// - Left(ValidationFailure): Datos del corte inválidos
  ///
  /// Validada por Requirement 9.4: Registro de cierre de turno con totales
  /// Validada por Requirement 9.5: Cálculo de diferencia en corte
  /// Validada por Requirement 13.3: Método separado para operaciones de corte
  Future<Either<Failure, Corte>> saveCorte(Corte corte);
}
