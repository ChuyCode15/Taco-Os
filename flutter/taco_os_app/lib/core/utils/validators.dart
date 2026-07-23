/// Utilities for validating user input in the Taco'Os app.
///
/// Each validator provides both string-based and value-based validation.
/// Returns `ValidationResult` with success/failure and optional error message.
library;

/// Result of a validation operation.
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult._({required this.isValid, this.errorMessage});

  /// Creates a successful validation result.
  factory ValidationResult.success() {
    return const ValidationResult._(isValid: true);
  }

  /// Creates a failed validation result with an error message.
  factory ValidationResult.failure(String message) {
    return ValidationResult._(isValid: false, errorMessage: message);
  }
}

/// Validates [Fondo_de_Cambio] (opening balance).
///
/// **Valid range:** 0.00 – 999,999.99
///
/// Accepts zero (turno sin efectivo inicial).
///
/// **Requirements:** 3.2, 3.6, 3.7
class FondoDeCambioValidator {
  FondoDeCambioValidator._();

  /// Validates a string input for Fondo_de_Cambio.
  ///
  /// Accepts null-safe string input and returns validation result.
  static ValidationResult validate(String? input) {
    if (input == null || input.trim().isEmpty) {
      return ValidationResult.failure('El fondo de cambio es requerido');
    }

    final value = double.tryParse(input.trim());
    if (value == null) {
      return ValidationResult.failure(
        'El fondo de cambio debe ser un valor numérico válido',
      );
    }

    return validateValue(value);
  }

  /// Validates a double value for Fondo_de_Cambio.
  static ValidationResult validateValue(double value) {
    if (value < 0.0) {
      return ValidationResult.failure(
        'El fondo de cambio no puede ser negativo',
      );
    }
    if (value > 999999.99) {
      return ValidationResult.failure(
        'El fondo de cambio no puede exceder \$999,999.99',
      );
    }
    return ValidationResult.success();
  }
}

/// Validates expense amount (monto de gasto).
///
/// **Valid range:** 0.01 – 999,999.99
///
/// Zero and negative values are rejected (gastos must be positive).
///
/// **Requirements:** 7.3, 7.4
class ExpenseAmountValidator {
  ExpenseAmountValidator._();

  /// Validates a string input for expense amount.
  static ValidationResult validate(String? input) {
    if (input == null || input.trim().isEmpty) {
      return ValidationResult.failure('El monto del gasto es requerido');
    }

    final value = double.tryParse(input.trim());
    if (value == null) {
      return ValidationResult.failure(
        'El monto debe ser un valor numérico válido',
      );
    }

    return validateValue(value);
  }

  /// Validates a double value for expense amount.
  static ValidationResult validateValue(double value) {
    if (value <= 0.0) {
      return ValidationResult.failure('El monto debe ser mayor a cero');
    }
    if (value > 999999.99) {
      return ValidationResult.failure('El monto no puede exceder \$999,999.99');
    }
    return ValidationResult.success();
  }
}

/// Validates product quantity (cantidad de producto).
///
/// **Valid range:** 1 – 999,999,999
///
/// Zero, negative, and decimal values are rejected.
///
/// **Requirements:** 5.8
class ProductQuantityValidator {
  ProductQuantityValidator._();

  /// Validates a string input for product quantity.
  static ValidationResult validate(String? input) {
    if (input == null || input.trim().isEmpty) {
      return ValidationResult.failure('La cantidad es requerida');
    }

    final value = int.tryParse(input.trim());
    if (value == null) {
      return ValidationResult.failure(
        'La cantidad debe ser un número entero válido',
      );
    }

    return validateValue(value);
  }

  /// Validates an int value for product quantity.
  static ValidationResult validateValue(int value) {
    if (value <= 0) {
      return ValidationResult.failure('La cantidad debe ser mayor a cero');
    }
    if (value > 999999999) {
      return ValidationResult.failure(
        'La cantidad no puede exceder 999,999,999',
      );
    }
    return ValidationResult.success();
  }
}

/// Validates expense description (descripción de gasto).
///
/// **Valid range:** 1 – 100 characters
///
/// Empty strings and strings exceeding 100 characters are rejected.
///
/// **Requirements:** 7.3, 7.4, 7.5
class ExpenseDescriptionValidator {
  ExpenseDescriptionValidator._();

  /// Validates a string input for expense description.
  static ValidationResult validate(String? input) {
    if (input == null || input.trim().isEmpty) {
      return ValidationResult.failure('La descripción del gasto es requerida');
    }

    final trimmed = input.trim();
    if (trimmed.length > 100) {
      return ValidationResult.failure(
        'La descripción no puede exceder 100 caracteres',
      );
    }

    return ValidationResult.success();
  }
}

/// Validates business name (nombre de negocio).
///
/// **Valid range:** 1 – 60 characters
///
/// Empty strings and strings exceeding 60 characters are rejected.
///
/// **Requirements:** 9.2 (inferred from Patron config), 12.6
class BusinessNameValidator {
  BusinessNameValidator._();

  /// Validates a string input for business name.
  static ValidationResult validate(String? input) {
    if (input == null || input.trim().isEmpty) {
      return ValidationResult.failure('El nombre del negocio es requerido');
    }

    final trimmed = input.trim();
    if (trimmed.length > 60) {
      return ValidationResult.failure(
        'El nombre no puede exceder 60 caracteres',
      );
    }

    return ValidationResult.success();
  }
}

/// Validates counted cash amount during Corte (efectivo contado).
///
/// **Valid range:** 0.00 – 999,999.99
///
/// Accepts zero (when no cash was counted).
///
/// **Requirements:** 9.1, 9.2
class CountedCashValidator {
  CountedCashValidator._();

  /// Validates a string input for counted cash.
  static ValidationResult validate(String? input) {
    if (input == null || input.trim().isEmpty) {
      return ValidationResult.failure('El efectivo contado es requerido');
    }

    final value = double.tryParse(input.trim());
    if (value == null) {
      return ValidationResult.failure(
        'El efectivo contado debe ser un valor numérico válido',
      );
    }

    return validateValue(value);
  }

  /// Validates a double value for counted cash.
  static ValidationResult validateValue(double value) {
    if (value < 0.0) {
      return ValidationResult.failure(
        'El efectivo contado no puede ser negativo',
      );
    }
    if (value > 999999.99) {
      return ValidationResult.failure(
        'El efectivo contado no puede exceder \$999,999.99',
      );
    }
    return ValidationResult.success();
  }
}
