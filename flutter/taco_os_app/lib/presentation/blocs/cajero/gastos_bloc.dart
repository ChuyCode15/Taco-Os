import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taco_os_app/domain/entities/expense.dart';
import 'package:taco_os_app/domain/usecases/cajero/register_expense_use_case.dart';
import 'package:taco_os_app/presentation/blocs/cajero/gastos_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/gastos_state.dart';
import 'package:uuid/uuid.dart';

/// BLoC para gestionar el registro rápido de gastos en el Modo_Cajero
///
/// Maneja la validación de campos del popup de gastos (descripción y monto),
/// registro en Local_DB mediante RegisterExpenseUseCase, y gestión de errores
/// de validación y base de datos.
///
/// **Estados:**
/// - [GastosInitial]: Estado inicial antes de interactuar con el popup
/// - [GastosLoading]: Operación de guardado en progreso
/// - [GastosSuccess]: Gasto registrado exitosamente en Local_DB
/// - [GastosValidationError]: Error de validación en descripción o monto
/// - [GastosError]: Error al escribir en Local_DB
///
/// **Eventos:**
/// - [ExpenseFormChanged]: Se actualiza el formulario (descripción o monto)
/// - [ExpenseSubmitted]: Se confirma el gasto y se guarda en Local_DB
///
/// **Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5, 7.6**
class GastosBloc extends Bloc<GastosEvent, GastosState> {
  final RegisterExpenseUseCase _registerExpenseUseCase;
  final Uuid _uuid = const Uuid();

  // Estado interno del formulario (no parte del estado público)
  String _description = '';
  String _amountInput = '';

  GastosBloc({required RegisterExpenseUseCase registerExpenseUseCase})
    : _registerExpenseUseCase = registerExpenseUseCase,
      super(const GastosInitial()) {
    on<ExpenseFormChanged>(_onExpenseFormChanged);
    on<ExpenseSubmitted>(_onExpenseSubmitted);
  }

  /// Maneja [ExpenseFormChanged]
  ///
  /// Actualiza el estado interno del formulario con los valores actuales
  /// de descripción y monto. Este evento se dispara mientras el usuario
  /// escribe en los campos, permitiendo validación en tiempo real si es necesario.
  ///
  /// No emite cambios de estado visibles — solo actualiza el estado interno.
  /// El estado público solo cambia cuando se envía el formulario.
  ///
  /// **Validates: Requirement 7.1**
  Future<void> _onExpenseFormChanged(
    ExpenseFormChanged event,
    Emitter<GastosState> emit,
  ) async {
    // Actualizar estado interno del formulario
    _description = event.description ?? _description;
    _amountInput = event.amountInput ?? _amountInput;

    // No emitir cambios de estado — solo actualizar internamente
    // El estado solo cambia cuando se envía el formulario
  }

  /// Maneja [ExpenseSubmitted]
  ///
  /// 1. Valida la descripción y el monto usando los validators
  /// 2. Si la validación falla: emite [GastosValidationError] con el mensaje
  /// 3. Si la validación es exitosa: emite [GastosLoading]
  /// 4. Crea la entidad [Expense] con todos los datos requeridos
  /// 5. Llama a [RegisterExpenseUseCase] para persistir en Local_DB
  /// 6. Si exitoso: emite [GastosSuccess] con el gasto registrado
  /// 7. Si falla: emite [GastosError] con el mensaje de error
  ///
  /// **Comportamiento Offline-First:**
  /// - El gasto se registra en Local_DB con is_synced = false
  /// - SyncService sincroniza con el backend en el siguiente ciclo de 5 min
  /// - La operación nunca falla por falta de conectividad
  ///
  /// **Validaciones (Requirements 7.3, 7.4, 7.5):**
  /// - Descripción: no vacía, máximo 100 caracteres (se trunca o rechaza)
  /// - Monto: entre 0.01 y 999,999.99, no vacío, no cero, no negativo
  ///
  /// **Validates: Requirements 7.2, 7.3, 7.4, 7.5, 7.6, 10.1, 10.2**
  Future<void> _onExpenseSubmitted(
    ExpenseSubmitted event,
    Emitter<GastosState> emit,
  ) async {
    // Validar la descripción con el validador del domain
    // Usamos el valor del estado interno si no se pasa en el evento
    final description = event.description ?? _description;
    final amountInput = event.amountInput ?? _amountInput;

    // Validar descripción vacía
    if (description.trim().isEmpty) {
      emit(
        const GastosValidationError(
          message: 'La descripción del gasto es requerida',
        ),
      );
      return;
    }

    // Validar longitud de descripción (máximo 100 caracteres)
    // Opción 1: Truncar automáticamente
    final truncatedDescription = description.length > 100
        ? description.substring(0, 100)
        : description;

    // Validar monto vacío
    if (amountInput.trim().isEmpty) {
      emit(
        const GastosValidationError(message: 'El monto del gasto es requerido'),
      );
      return;
    }

    // Parsear y validar monto
    final amount = double.tryParse(amountInput.trim());
    if (amount == null) {
      emit(
        const GastosValidationError(
          message: 'El monto debe ser un valor numérico válido',
        ),
      );
      return;
    }

    // Validar que el monto sea mayor a cero (Requirement 7.3)
    if (amount <= 0.0) {
      emit(
        const GastosValidationError(message: 'El monto debe ser mayor a cero'),
      );
      return;
    }

    // Validar que el monto no exceda el límite (Requirement 7.2)
    if (amount > 999999.99) {
      emit(
        const GastosValidationError(
          message: 'El monto no puede exceder \$999,999.99',
        ),
      );
      return;
    }

    // Todas las validaciones pasaron — proceder a guardar
    emit(const GastosLoading());

    // Crear entidad Expense
    final expense = Expense(
      id: _uuid.v4(),
      sessionId: event.sessionId,
      businessId: event.businessId,
      cashierId: event.cashierId,
      description: truncatedDescription,
      amount: amount,
      timestamp: DateTime.now(),
      isSynced: false, // Offline-first: se sincroniza después
    );

    // Registrar gasto con use case
    final result = await _registerExpenseUseCase(
      RegisterExpenseParams(expense: expense),
    );

    result.fold(
      (failure) {
        // Error al guardar en Local_DB
        emit(GastosError(message: failure.message));
      },
      (registeredExpense) {
        // Éxito: gasto registrado
        // Limpiar el formulario interno
        _description = '';
        _amountInput = '';
        emit(GastosSuccess(expense: registeredExpense));
      },
    );
  }
}
