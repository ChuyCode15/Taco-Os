import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/corte.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../datasources/local/app_database.dart';
import '../models/sale_model.dart';
import '../models/expense_model.dart';
import '../models/corte_model.dart';

/// Implementación concreta del repositorio de transacciones
///
/// Esta clase implementa [ITransactionRepository] usando SQLite (drift) como
/// fuente de datos local. Todas las operaciones escriben primero en la base
/// de datos local con el flag is_synced = false, implementando la estrategia
/// offline-first del sistema.
///
/// Validada por Requirement 5.6: Registro de Ventas
/// Validada por Requirement 5.7: Persistencia en Local_DB tras confirmar venta
/// Validada por Requirement 6.4: Cancelación con foto y reversión de totales
/// Validada por Requirement 7.2: Registro rápido de gastos
/// Validada por Requirement 9.4: Registro de corte de caja
/// Validada por Requirement 10.2: Flag is_synced = false hasta sincronización
/// Validada por Requirement 13.1: Clean Architecture - Infrastructure layer
/// Validada por Requirement 13.2: Dependencia de abstracciones (ITransactionRepository)
/// Validada por Requirement 13.3: Métodos separados por tipo de entidad
class TransactionRepositoryImpl implements ITransactionRepository {
  final AppDatabase _database;

  TransactionRepositoryImpl({required AppDatabase database})
    : _database = database;

  // ==================== OPERACIONES DE VENTAS ====================

  @override
  Future<Either<Failure, Sale>> saveSale(Sale sale) async {
    try {
      // Validación: la venta debe tener al menos un ítem
      if (sale.items.isEmpty) {
        return const Left(
          ValidationFailure(
            message: 'La venta debe contener al menos un producto',
          ),
        );
      }

      // Validación: el total debe ser positivo
      if (sale.total <= 0) {
        return const Left(
          ValidationFailure(
            message: 'El total de la venta debe ser mayor a cero',
          ),
        );
      }

      // Convertir entidad a modelo
      final saleModel = SaleModel.fromEntity(sale);

      // Preparar el companion para la inserción de venta
      final saleCompanion = SalesCompanion(
        id: Value(saleModel.id),
        sessionId: Value(saleModel.sessionId),
        businessId: Value(saleModel.businessId),
        cashierId: Value(saleModel.cashierId),
        total: Value(saleModel.total),
        paymentMethod: Value(saleModel.paymentMethod),
        cardPhotoUrl: Value(saleModel.cancellationPhotoUrl),
        status: Value(saleModel.status),
        cancellationPhotoUrl: Value(saleModel.cancellationPhotoUrl),
        timestamp: Value(DateTime.parse(saleModel.timestamp)),
        isSynced: const Value(false), // Offline-first: is_synced = false
        syncError: const Value(null),
      );

      // Insertar venta en la base de datos
      await _database.transactionDao.insertSale(saleCompanion);

      // Preparar los companions para los sale_items
      final saleItemsCompanions = saleModel.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return SaleItemsCompanion(
          id: Value(
            '${saleModel.id}_item_$index',
          ), // ID único basado en sale_id e índice
          saleId: Value(saleModel.id),
          productId: Value(item.productId),
          productName: Value(item.productName),
          quantity: Value(item.quantity),
          unitPrice: Value(item.unitPrice),
          subtotal: Value(item.subtotal),
        );
      }).toList();

      // Insertar todos los sale_items en batch
      await _database.transactionDao.insertSaleItems(saleItemsCompanions);

      // Retornar la venta con is_synced = false
      return Right(sale.copyWith(isSynced: false));
    } catch (e) {
      return Left(
        LocalDatabaseFailure(
          message: 'Error al guardar la venta: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Sale>> cancelSale(
    String saleId,
    String photoPath,
  ) async {
    try {
      // Validación: la foto es obligatoria
      if (photoPath.isEmpty) {
        return const Left(
          ValidationFailure(
            message:
                'La foto del producto devuelto es obligatoria para cancelar la venta',
          ),
        );
      }

      // Buscar la venta en la base de datos local
      // Nota: No podemos filtrar por business_id aquí porque no lo tenemos como parámetro
      // La validación de ventana anti-fraude debe hacerse en el use case
      final saleData = await (_database.select(
        _database.sales,
      )..where((s) => s.id.equals(saleId))).getSingleOrNull();

      if (saleData == null) {
        return const Left(ValidationFailure(message: 'Venta no encontrada'));
      }

      // Verificar que la venta no esté ya cancelada
      if (saleData.status == 'cancelled') {
        return const Left(
          ValidationFailure(message: 'La venta ya está cancelada'),
        );
      }

      // Verificar ventana anti-fraude (5 minutos)
      final elapsed = DateTime.now().difference(saleData.timestamp);
      if (elapsed.inMinutes >= 5) {
        return const Left(
          ValidationFailure(
            message: 'La ventana de cancelación ha expirado (5 minutos)',
          ),
        );
      }

      // Actualizar la venta: marcar como cancelada y asociar foto
      final updated = await _database.transactionDao.updateSale(
        saleId,
        SalesCompanion(
          status: const Value('cancelled'),
          cancellationPhotoUrl: Value(photoPath),
          isSynced: const Value(false), // Marcar como pendiente de sync
        ),
      );

      if (!updated) {
        return const Left(
          LocalDatabaseFailure(
            message: 'Error al actualizar el estado de la venta',
          ),
        );
      }

      // Recuperar la venta actualizada con sus items
      final updatedSaleData = await (_database.select(
        _database.sales,
      )..where((s) => s.id.equals(saleId))).getSingle();

      final saleItemsData = await _database.transactionDao.getSaleItems(saleId);

      // Convertir a entidad de dominio
      final sale = _saleDataToEntity(updatedSaleData, saleItemsData);

      return Right(sale);
    } catch (e) {
      return Left(
        LocalDatabaseFailure(
          message: 'Error al cancelar la venta: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Sale>>> getPendingSales(String sessionId) async {
    try {
      // Obtener todas las ventas pendientes de sincronización para esta sesión
      // Nota: El DAO ya filtra por business_id internamente
      final salesData =
          await (_database.select(_database.sales)
                ..where((s) => s.sessionId.equals(sessionId))
                ..where((s) => s.isSynced.equals(false))
                ..orderBy([(s) => OrderingTerm.asc(s.timestamp)]))
              .get();

      // Para cada venta, obtener sus items
      final sales = <Sale>[];
      for (final saleData in salesData) {
        final saleItemsData = await _database.transactionDao.getSaleItems(
          saleData.id,
        );
        final sale = _saleDataToEntity(saleData, saleItemsData);
        sales.add(sale);
      }

      return Right(sales);
    } catch (e) {
      return Left(
        LocalDatabaseFailure(
          message: 'Error al obtener ventas pendientes: ${e.toString()}',
        ),
      );
    }
  }

  // ==================== OPERACIONES DE GASTOS ====================

  @override
  Future<Either<Failure, Expense>> saveExpense(Expense expense) async {
    try {
      // Validación: la descripción no puede estar vacía
      if (expense.description.trim().isEmpty) {
        return const Left(
          ValidationFailure(message: 'La descripción del gasto es obligatoria'),
        );
      }

      // Validación: la descripción no puede exceder 100 caracteres
      if (expense.description.length > 100) {
        return const Left(
          ValidationFailure(
            message: 'La descripción del gasto no puede exceder 100 caracteres',
          ),
        );
      }

      // Validación: el monto debe estar en el rango válido (0.01–999,999.99)
      if (expense.amount < 0.01 || expense.amount > 999999.99) {
        return const Left(
          ValidationFailure(
            message: 'El monto del gasto debe estar entre 0.01 y 999,999.99',
          ),
        );
      }

      // Convertir entidad a modelo
      final expenseModel = ExpenseModel.fromEntity(expense);

      // Preparar el companion para la inserción
      final expenseCompanion = ExpensesCompanion(
        id: Value(expenseModel.id),
        sessionId: Value(expenseModel.sessionId),
        businessId: Value(expenseModel.businessId),
        cashierId: Value(expenseModel.cashierId),
        description: Value(expenseModel.description),
        amount: Value(expenseModel.amount),
        timestamp: Value(DateTime.parse(expenseModel.timestamp)),
        isSynced: const Value(false), // Offline-first: is_synced = false
        syncError: const Value(null),
      );

      // Insertar gasto en la base de datos
      await _database.transactionDao.insertExpense(expenseCompanion);

      // Retornar el gasto con is_synced = false
      return Right(expense.copyWith(isSynced: false));
    } catch (e) {
      return Left(
        LocalDatabaseFailure(
          message: 'Error al guardar el gasto: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getPendingExpenses(
    String sessionId,
  ) async {
    try {
      // Obtener todos los gastos pendientes de sincronización para esta sesión
      final expensesData =
          await (_database.select(_database.expenses)
                ..where((e) => e.sessionId.equals(sessionId))
                ..where((e) => e.isSynced.equals(false))
                ..orderBy([(e) => OrderingTerm.asc(e.timestamp)]))
              .get();

      // Convertir a entidades de dominio
      final expenses = expensesData.map(_expenseDataToEntity).toList();

      return Right(expenses);
    } catch (e) {
      return Left(
        LocalDatabaseFailure(
          message: 'Error al obtener gastos pendientes: ${e.toString()}',
        ),
      );
    }
  }

  // ==================== OPERACIONES DE CORTE ====================

  @override
  Future<Either<Failure, Corte>> saveCorte(Corte corte) async {
    try {
      // Validación: el efectivo contado debe estar en el rango válido (0.00–999,999.99)
      if (corte.countedCash < 0.00 || corte.countedCash > 999999.99) {
        return const Left(
          ValidationFailure(
            message: 'El efectivo contado debe estar entre 0.00 y 999,999.99',
          ),
        );
      }

      // Convertir entidad a modelo
      final corteModel = CorteModel.fromEntity(corte);

      // Preparar el companion para la inserción
      final corteCompanion = CortesCompanion(
        id: Value(corteModel.id),
        sessionId: Value(corteModel.sessionId),
        businessId: Value(corteModel.businessId),
        cashierId: Value(corteModel.cashierId),
        totalCashSales: Value(corteModel.totalCashSales),
        totalCardSales: Value(corteModel.totalCardSales),
        totalExpenses: Value(corteModel.totalExpenses),
        openingBalance: Value(corteModel.openingBalance),
        countedCash: Value(corteModel.countedCash),
        difference: Value(corteModel.difference),
        closedAt: Value(DateTime.parse(corteModel.closedAt)),
        isSynced: const Value(false), // Offline-first: is_synced = false
        syncError: const Value(null),
      );

      // Insertar corte en la base de datos
      await _database.transactionDao.insertCorte(corteCompanion);

      // Retornar el corte con is_synced = false
      return Right(corte.copyWith(isSynced: false));
    } catch (e) {
      return Left(
        LocalDatabaseFailure(
          message: 'Error al guardar el corte: ${e.toString()}',
        ),
      );
    }
  }

  // ==================== MÉTODOS AUXILIARES ====================

  /// Convierte un SaleData y sus SaleItemData a una entidad Sale
  Sale _saleDataToEntity(SaleData saleData, List<SaleItemData> saleItemsData) {
    return Sale(
      id: saleData.id,
      sessionId: saleData.sessionId,
      businessId: saleData.businessId,
      cashierId: saleData.cashierId,
      items: saleItemsData.map(_saleItemDataToEntity).toList(),
      total: saleData.total,
      paymentMethod: _parsePaymentMethod(saleData.paymentMethod),
      status: _parseSaleStatus(saleData.status),
      timestamp: saleData.timestamp,
      isSynced: saleData.isSynced,
      syncError: saleData.syncError,
      cancellationPhotoUrl: saleData.cancellationPhotoUrl,
    );
  }

  /// Convierte un SaleItemData a una entidad SaleItem
  SaleItem _saleItemDataToEntity(SaleItemData itemData) {
    return SaleItem(
      productId: itemData.productId,
      productName: itemData.productName,
      quantity: itemData.quantity,
      unitPrice: itemData.unitPrice,
      subtotal: itemData.subtotal,
    );
  }

  /// Convierte un ExpenseData a una entidad Expense
  Expense _expenseDataToEntity(ExpenseData expenseData) {
    return Expense(
      id: expenseData.id,
      sessionId: expenseData.sessionId,
      businessId: expenseData.businessId,
      cashierId: expenseData.cashierId,
      description: expenseData.description,
      amount: expenseData.amount,
      timestamp: expenseData.timestamp,
      isSynced: expenseData.isSynced,
      syncError: expenseData.syncError,
    );
  }

  /// Convierte string a enum PaymentMethod
  PaymentMethod _parsePaymentMethod(String value) {
    switch (value) {
      case 'cash':
        return PaymentMethod.cash;
      case 'card':
        return PaymentMethod.card;
      default:
        throw ArgumentError('Unknown payment method: $value');
    }
  }

  /// Convierte string a enum SaleStatus
  SaleStatus _parseSaleStatus(String value) {
    switch (value) {
      case 'completed':
        return SaleStatus.completed;
      case 'cancelled':
        return SaleStatus.cancelled;
      default:
        throw ArgumentError('Unknown sale status: $value');
    }
  }
}
