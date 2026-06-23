import 'package:equatable/equatable.dart';
import 'package:taco_os_app/domain/entities/expense.dart';

/// Estados del GastosBloc
///
/// Representa el flujo completo del registro rápido de gastos:
/// estado inicial, carga durante guardado, éxito con gasto registrado,
/// errores de validación, y errores de base de datos.
///
/// **Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5, 7.6**
sealed class GastosState extends Equatable {
  const GastosState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial del formulario de gastos
///
/// El popup está abierto pero aún no se ha enviado el formulario.
/// Los campos están vacíos o con valores ingresados por el cajero.
///
/// **Validates: Requirement 7.1**
class GastosInitial extends GastosState {
  const GastosInitial();
}

/// Estado de carga durante el registro del gasto
///
/// Se emite mientras se está guardando el gasto en Local_DB.
/// El UI debería mostrar un indicador de carga y deshabilitar los botones.
///
/// **Validates: Requirement 7.2**
class GastosLoading extends GastosState {
  const GastosLoading();
}

/// Estado de gasto registrado exitosamente
///
/// El gasto fue guardado en Local_DB con is_synced = false.
/// El popup debe cerrarse y mostrar un snackbar de confirmación
/// visible durante al menos 2 segundos.
///
/// **Validates: Requirements 7.2, 7.6, 10.1**
class GastosSuccess extends GastosState {
  final Expense expense;

  const GastosSuccess({required this.expense});

  @override
  List<Object?> get props => [expense];
}

/// Estado de error de validación en el formulario
///
/// Indica que la descripción o el monto no cumplen con las validaciones:
/// - Descripción vacía (Requirement 7.4)
/// - Descripción > 100 caracteres (Requirement 7.5)
/// - Monto vacío, cero o negativo (Requirement 7.3)
/// - Monto > 999,999.99 (Requirement 7.2)
///
/// El popup permanece abierto y muestra el mensaje de error.
/// No se escribe nada en Local_DB.
///
/// **Validates: Requirements 7.3, 7.4, 7.5**
class GastosValidationError extends GastosState {
  final String message;

  const GastosValidationError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de error al guardar en Local_DB
///
/// Indica que hubo un error al escribir el gasto en la base de datos local.
/// El popup permanece abierto con el mensaje de error.
/// El cajero puede reintentar la operación.
///
/// **Validates: Requirement 7.2 (error handling)**
class GastosError extends GastosState {
  final String message;

  const GastosError({required this.message});

  @override
  List<Object?> get props => [message];
}
