import 'package:equatable/equatable.dart';

/// Eventos del GastosBloc
///
/// Gestiona las acciones relacionadas con el registro rápido de gastos:
/// actualización del formulario y envío para persistir en Local_DB.
///
/// **Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5, 7.6**
sealed class GastosEvent extends Equatable {
  const GastosEvent();

  @override
  List<Object?> get props => [];
}

/// Evento disparado cuando el cajero cambia los campos del formulario
///
/// Actualiza el estado interno del formulario con descripción y/o monto.
/// Se usa para mantener sincronizado el estado del BLoC con el UI mientras
/// el usuario escribe en los campos del popup.
///
/// **Parámetros opcionales:**
/// - [description]: Texto de la descripción del gasto (máximo 100 caracteres)
/// - [amountInput]: Texto del campo de monto (será parseado a double)
///
/// **Validates: Requirement 7.1**
class ExpenseFormChanged extends GastosEvent {
  final String? description;
  final String? amountInput;

  const ExpenseFormChanged({this.description, this.amountInput});

  @override
  List<Object?> get props => [description, amountInput];
}

/// Evento disparado cuando el cajero confirma el gasto
///
/// Valida los campos de descripción y monto, y si son válidos,
/// registra el gasto en Local_DB con is_synced = false.
///
/// **Parámetros obligatorios:**
/// - [sessionId]: ID de la sesión de caja activa
/// - [businessId]: ID del negocio (aislamiento multi-tenant)
/// - [cashierId]: ID del cajero que registra el gasto
///
/// **Parámetros opcionales:**
/// - [description]: Descripción del gasto (si no se pasa, usa el estado interno)
/// - [amountInput]: Monto del gasto como string (si no se pasa, usa el estado interno)
///
/// **Validaciones aplicadas (Requirements 7.3, 7.4, 7.5):**
/// - Descripción: no vacía, máximo 100 caracteres (se trunca automáticamente)
/// - Monto: entre 0.01 y 999,999.99, no vacío, no cero, no negativo
///
/// **Validates: Requirements 7.2, 7.3, 7.4, 7.5, 7.6, 10.1, 10.2**
class ExpenseSubmitted extends GastosEvent {
  final String sessionId;
  final String businessId;
  final String cashierId;
  final String? description;
  final String? amountInput;

  const ExpenseSubmitted({
    required this.sessionId,
    required this.businessId,
    required this.cashierId,
    this.description,
    this.amountInput,
  });

  @override
  List<Object?> get props => [
    sessionId,
    businessId,
    cashierId,
    description,
    amountInput,
  ];
}
