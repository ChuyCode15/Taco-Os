import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:taco_os_app/core/utils/validators.dart';

void main() {
  group('FondoDeCambioValidator', () {
    group('validate with string input', () {
      test('should accept valid zero value', () {
        final result = FondoDeCambioValidator.validate('0.00');
        expect(result.isValid, true);
        expect(result.errorMessage, null);
      });

      test('should accept valid minimum boundary value', () {
        final result = FondoDeCambioValidator.validate('0.01');
        expect(result.isValid, true);
      });

      test('should accept valid mid-range value', () {
        final result = FondoDeCambioValidator.validate('5000.50');
        expect(result.isValid, true);
      });

      test('should accept valid maximum boundary value', () {
        final result = FondoDeCambioValidator.validate('999999.99');
        expect(result.isValid, true);
      });

      test('should reject null input', () {
        final result = FondoDeCambioValidator.validate(null);
        expect(result.isValid, false);
        expect(result.errorMessage, 'El fondo de cambio es requerido');
      });

      test('should reject empty string', () {
        final result = FondoDeCambioValidator.validate('');
        expect(result.isValid, false);
        expect(result.errorMessage, 'El fondo de cambio es requerido');
      });

      test('should reject whitespace-only string', () {
        final result = FondoDeCambioValidator.validate('   ');
        expect(result.isValid, false);
        expect(result.errorMessage, 'El fondo de cambio es requerido');
      });

      test('should reject negative value', () {
        final result = FondoDeCambioValidator.validate('-100.00');
        expect(result.isValid, false);
        expect(result.errorMessage, 'El fondo de cambio no puede ser negativo');
      });

      test('should reject value exceeding maximum', () {
        final result = FondoDeCambioValidator.validate('1000000.00');
        expect(result.isValid, false);
        expect(
          result.errorMessage,
          'El fondo de cambio no puede exceder \$999,999.99',
        );
      });

      test('should reject non-numeric value', () {
        final result = FondoDeCambioValidator.validate('abc');
        expect(result.isValid, false);
        expect(
          result.errorMessage,
          'El fondo de cambio debe ser un valor numérico válido',
        );
      });

      test('should handle string with leading/trailing whitespace', () {
        final result = FondoDeCambioValidator.validate('  500.00  ');
        expect(result.isValid, true);
      });
    });

    group('validateValue with double input', () {
      test('should accept valid zero value', () {
        final result = FondoDeCambioValidator.validateValue(0.0);
        expect(result.isValid, true);
      });

      test('should accept valid maximum value', () {
        final result = FondoDeCambioValidator.validateValue(999999.99);
        expect(result.isValid, true);
      });

      test('should reject negative value', () {
        final result = FondoDeCambioValidator.validateValue(-1.0);
        expect(result.isValid, false);
      });

      test('should reject value exceeding maximum', () {
        final result = FondoDeCambioValidator.validateValue(1000000.0);
        expect(result.isValid, false);
      });
    });
  });

  group('ExpenseAmountValidator', () {
    group('validate with string input', () {
      test('should accept valid minimum boundary value', () {
        final result = ExpenseAmountValidator.validate('0.01');
        expect(result.isValid, true);
      });

      test('should accept valid mid-range value', () {
        final result = ExpenseAmountValidator.validate('250.75');
        expect(result.isValid, true);
      });

      test('should accept valid maximum boundary value', () {
        final result = ExpenseAmountValidator.validate('999999.99');
        expect(result.isValid, true);
      });

      test('should reject null input', () {
        final result = ExpenseAmountValidator.validate(null);
        expect(result.isValid, false);
        expect(result.errorMessage, 'El monto del gasto es requerido');
      });

      test('should reject empty string', () {
        final result = ExpenseAmountValidator.validate('');
        expect(result.isValid, false);
        expect(result.errorMessage, 'El monto del gasto es requerido');
      });

      test('should reject zero value', () {
        final result = ExpenseAmountValidator.validate('0.00');
        expect(result.isValid, false);
        expect(result.errorMessage, 'El monto debe ser mayor a cero');
      });

      test('should reject negative value', () {
        final result = ExpenseAmountValidator.validate('-50.00');
        expect(result.isValid, false);
        expect(result.errorMessage, 'El monto debe ser mayor a cero');
      });

      test('should reject value exceeding maximum', () {
        final result = ExpenseAmountValidator.validate('1000000.00');
        expect(result.isValid, false);
        expect(result.errorMessage, 'El monto no puede exceder \$999,999.99');
      });

      test('should reject non-numeric value', () {
        final result = ExpenseAmountValidator.validate('xyz');
        expect(result.isValid, false);
        expect(
          result.errorMessage,
          'El monto debe ser un valor numérico válido',
        );
      });

      test('should handle string with leading/trailing whitespace', () {
        final result = ExpenseAmountValidator.validate('  100.50  ');
        expect(result.isValid, true);
      });
    });

    group('validateValue with double input', () {
      test('should accept valid minimum value', () {
        final result = ExpenseAmountValidator.validateValue(0.01);
        expect(result.isValid, true);
      });

      test('should accept valid maximum value', () {
        final result = ExpenseAmountValidator.validateValue(999999.99);
        expect(result.isValid, true);
      });

      test('should reject zero value', () {
        final result = ExpenseAmountValidator.validateValue(0.0);
        expect(result.isValid, false);
      });

      test('should reject negative value', () {
        final result = ExpenseAmountValidator.validateValue(-10.0);
        expect(result.isValid, false);
      });

      test('should reject value exceeding maximum', () {
        final result = ExpenseAmountValidator.validateValue(1000000.0);
        expect(result.isValid, false);
      });
    });
  });

  group('ProductQuantityValidator', () {
    group('validate with string input', () {
      test('should accept valid minimum boundary value', () {
        final result = ProductQuantityValidator.validate('1');
        expect(result.isValid, true);
      });

      test('should accept valid mid-range value', () {
        final result = ProductQuantityValidator.validate('500');
        expect(result.isValid, true);
      });

      test('should accept valid maximum boundary value', () {
        final result = ProductQuantityValidator.validate('999999999');
        expect(result.isValid, true);
      });

      test('should reject null input', () {
        final result = ProductQuantityValidator.validate(null);
        expect(result.isValid, false);
        expect(result.errorMessage, 'La cantidad es requerida');
      });

      test('should reject empty string', () {
        final result = ProductQuantityValidator.validate('');
        expect(result.isValid, false);
        expect(result.errorMessage, 'La cantidad es requerida');
      });

      test('should reject zero value', () {
        final result = ProductQuantityValidator.validate('0');
        expect(result.isValid, false);
        expect(result.errorMessage, 'La cantidad debe ser mayor a cero');
      });

      test('should reject negative value', () {
        final result = ProductQuantityValidator.validate('-5');
        expect(result.isValid, false);
        expect(result.errorMessage, 'La cantidad debe ser mayor a cero');
      });

      test('should reject decimal value', () {
        final result = ProductQuantityValidator.validate('10.5');
        expect(result.isValid, false);
        expect(
          result.errorMessage,
          'La cantidad debe ser un número entero válido',
        );
      });

      test('should reject value exceeding maximum', () {
        final result = ProductQuantityValidator.validate('1000000000');
        expect(result.isValid, false);
        expect(result.errorMessage, 'La cantidad no puede exceder 999,999,999');
      });

      test('should reject non-numeric value', () {
        final result = ProductQuantityValidator.validate('abc');
        expect(result.isValid, false);
        expect(
          result.errorMessage,
          'La cantidad debe ser un número entero válido',
        );
      });

      test('should handle string with leading/trailing whitespace', () {
        final result = ProductQuantityValidator.validate('  25  ');
        expect(result.isValid, true);
      });
    });

    group('validateValue with int input', () {
      test('should accept valid minimum value', () {
        final result = ProductQuantityValidator.validateValue(1);
        expect(result.isValid, true);
      });

      test('should accept valid maximum value', () {
        final result = ProductQuantityValidator.validateValue(999999999);
        expect(result.isValid, true);
      });

      test('should reject zero value', () {
        final result = ProductQuantityValidator.validateValue(0);
        expect(result.isValid, false);
      });

      test('should reject negative value', () {
        final result = ProductQuantityValidator.validateValue(-1);
        expect(result.isValid, false);
      });

      test('should reject value exceeding maximum', () {
        final result = ProductQuantityValidator.validateValue(1000000000);
        expect(result.isValid, false);
      });
    });
  });

  group('ExpenseDescriptionValidator', () {
    test('should accept valid single character description', () {
      final result = ExpenseDescriptionValidator.validate('a');
      expect(result.isValid, true);
    });

    test('should accept valid mid-length description', () {
      final result = ExpenseDescriptionValidator.validate(
        'Compra de servilletas',
      );
      expect(result.isValid, true);
    });

    test('should accept valid 100 character description', () {
      final result = ExpenseDescriptionValidator.validate('a' * 100);
      expect(result.isValid, true);
    });

    test('should reject null input', () {
      final result = ExpenseDescriptionValidator.validate(null);
      expect(result.isValid, false);
      expect(result.errorMessage, 'La descripción del gasto es requerida');
    });

    test('should reject empty string', () {
      final result = ExpenseDescriptionValidator.validate('');
      expect(result.isValid, false);
      expect(result.errorMessage, 'La descripción del gasto es requerida');
    });

    test('should reject whitespace-only string', () {
      final result = ExpenseDescriptionValidator.validate('   ');
      expect(result.isValid, false);
      expect(result.errorMessage, 'La descripción del gasto es requerida');
    });

    test('should reject description exceeding 100 characters', () {
      final result = ExpenseDescriptionValidator.validate('a' * 101);
      expect(result.isValid, false);
      expect(
        result.errorMessage,
        'La descripción no puede exceder 100 caracteres',
      );
    });

    test('should handle description with leading/trailing whitespace', () {
      final result = ExpenseDescriptionValidator.validate('  Hielo  ');
      expect(result.isValid, true);
    });

    test('should accept description with special characters', () {
      final result = ExpenseDescriptionValidator.validate(
        'Compra de gas (tanque 20kg) - Proveedor #1',
      );
      expect(result.isValid, true);
    });

    test('should accept description with accents and ñ', () {
      final result = ExpenseDescriptionValidator.validate('Refresco de piña');
      expect(result.isValid, true);
    });
  });

  group('BusinessNameValidator', () {
    test('should accept valid single character name', () {
      final result = BusinessNameValidator.validate('A');
      expect(result.isValid, true);
    });

    test('should accept valid mid-length name', () {
      final result = BusinessNameValidator.validate('Tacos El Güero');
      expect(result.isValid, true);
    });

    test('should accept valid 60 character name', () {
      final result = BusinessNameValidator.validate('a' * 60);
      expect(result.isValid, true);
    });

    test('should reject null input', () {
      final result = BusinessNameValidator.validate(null);
      expect(result.isValid, false);
      expect(result.errorMessage, 'El nombre del negocio es requerido');
    });

    test('should reject empty string', () {
      final result = BusinessNameValidator.validate('');
      expect(result.isValid, false);
      expect(result.errorMessage, 'El nombre del negocio es requerido');
    });

    test('should reject whitespace-only string', () {
      final result = BusinessNameValidator.validate('   ');
      expect(result.isValid, false);
      expect(result.errorMessage, 'El nombre del negocio es requerido');
    });

    test('should reject name exceeding 60 characters', () {
      final result = BusinessNameValidator.validate('a' * 61);
      expect(result.isValid, false);
      expect(result.errorMessage, 'El nombre no puede exceder 60 caracteres');
    });

    test('should handle name with leading/trailing whitespace', () {
      final result = BusinessNameValidator.validate('  Taquería Los Amigos  ');
      expect(result.isValid, true);
    });

    test('should accept name with special characters', () {
      final result = BusinessNameValidator.validate(
        "Tacos & Quesadillas 'El Patrón'",
      );
      expect(result.isValid, true);
    });

    test('should accept name with numbers', () {
      final result = BusinessNameValidator.validate('Tacos 24/7');
      expect(result.isValid, true);
    });
  });

  group('ValidationResult', () {
    test('should create success result with factory', () {
      final result = ValidationResult.success();
      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });

    test('should create failure result with factory', () {
      final result = ValidationResult.failure('Error message');
      expect(result.isValid, false);
      expect(result.errorMessage, 'Error message');
    });
  });

  // **Property 7: Fondo_de_Cambio Validation**
  // **Validates: Requirements 3.2, 3.6, 3.7**
  group('Property-Based Test: FondoDeCambioValidator', () {
    final random = Random(42); // Fixed seed for reproducibility
    const numTests = 100; // Number of random test cases to generate

    test(
      'Property: All values outside [0.00, 999,999.99] should return ValidationFailure',
      () {
        // Generate random values below minimum (negative values)
        for (int i = 0; i < numTests ~/ 2; i++) {
          // Generate values from -1,000,000 to -0.01
          final invalidValue = -0.01 - (random.nextDouble() * 999999.99);
          final result = FondoDeCambioValidator.validateValue(invalidValue);

          expect(
            result.isValid,
            false,
            reason:
                'Expected validation to fail for negative value: $invalidValue',
          );
          expect(
            result.errorMessage,
            'El fondo de cambio no puede ser negativo',
            reason: 'Expected correct error message for negative value',
          );
        }

        // Generate random values above maximum (> 999,999.99)
        for (int i = 0; i < numTests ~/ 2; i++) {
          // Generate values from 1,000,000.00 to 2,000,000.00
          final invalidValue = 1000000.0 + (random.nextDouble() * 1000000.0);
          final result = FondoDeCambioValidator.validateValue(invalidValue);

          expect(
            result.isValid,
            false,
            reason:
                'Expected validation to fail for value exceeding maximum: $invalidValue',
          );
          expect(
            result.errorMessage,
            'El fondo de cambio no puede exceder \$999,999.99',
            reason: 'Expected correct error message for value above maximum',
          );
        }
      },
    );

    test(
      'Property: All values within [0.00, 999,999.99] should pass validation',
      () {
        // Test boundary: 0.00
        final resultZero = FondoDeCambioValidator.validateValue(0.0);
        expect(
          resultZero.isValid,
          true,
          reason: 'Expected validation to pass for boundary value 0.00',
        );

        // Test boundary: 999,999.99
        final resultMax = FondoDeCambioValidator.validateValue(999999.99);
        expect(
          resultMax.isValid,
          true,
          reason: 'Expected validation to pass for boundary value 999,999.99',
        );

        // Generate random values within valid range (0.00 to 999,999.99)
        for (int i = 0; i < numTests; i++) {
          final validValue = random.nextDouble() * 999999.99;
          final result = FondoDeCambioValidator.validateValue(validValue);

          expect(
            result.isValid,
            true,
            reason:
                'Expected validation to pass for valid value within range: $validValue',
          );
          expect(
            result.errorMessage,
            null,
            reason: 'Expected no error message for valid value: $validValue',
          );
        }
      },
    );

    test('Property: String validation should match value validation behavior', () {
      // Test with random valid values as strings
      for (int i = 0; i < numTests ~/ 3; i++) {
        final validValue = random.nextDouble() * 999999.99;
        final stringValue = validValue.toStringAsFixed(2);

        final stringResult = FondoDeCambioValidator.validate(stringValue);
        final valueResult = FondoDeCambioValidator.validateValue(validValue);

        expect(
          stringResult.isValid,
          valueResult.isValid,
          reason:
              'String validation and value validation should agree for: $stringValue',
        );
      }

      // Test with random negative values as strings
      for (int i = 0; i < numTests ~/ 3; i++) {
        final invalidValue = -0.01 - (random.nextDouble() * 999999.99);
        final stringValue = invalidValue.toStringAsFixed(2);

        final stringResult = FondoDeCambioValidator.validate(stringValue);

        expect(
          stringResult.isValid,
          false,
          reason:
              'String validation should fail for negative value: $stringValue',
        );
      }

      // Test with random values above maximum as strings
      for (int i = 0; i < numTests ~/ 3; i++) {
        final invalidValue = 1000000.0 + (random.nextDouble() * 1000000.0);
        final stringValue = invalidValue.toStringAsFixed(2);

        final stringResult = FondoDeCambioValidator.validate(stringValue);

        expect(
          stringResult.isValid,
          false,
          reason:
              'String validation should fail for value above maximum: $stringValue',
        );
      }
    });

    test('Property: Boundary values should be handled correctly', () {
      // Test exact boundaries multiple times with slight variations
      final boundaries = [
        0.0, // Lower boundary
        0.01, // Just above lower boundary
        999999.98, // Just below upper boundary
        999999.99, // Upper boundary
      ];

      for (final boundary in boundaries) {
        final result = FondoDeCambioValidator.validateValue(boundary);
        expect(
          result.isValid,
          true,
          reason: 'Expected boundary value $boundary to pass validation',
        );
      }

      // Test values just outside boundaries
      final invalidBoundaries = [
        -0.01, // Just below lower boundary
        1000000.0, // Just above upper boundary
      ];

      for (final boundary in invalidBoundaries) {
        final result = FondoDeCambioValidator.validateValue(boundary);
        expect(
          result.isValid,
          false,
          reason:
              'Expected invalid boundary value $boundary to fail validation',
        );
      }
    });

    test(
      'Property: Validation is idempotent (repeated calls yield same result)',
      () {
        for (int i = 0; i < numTests; i++) {
          // Generate random value (could be valid or invalid)
          final testValue =
              (random.nextDouble() * 2000000.0) -
              500000.0; // Range: -500k to 1.5M

          final result1 = FondoDeCambioValidator.validateValue(testValue);
          final result2 = FondoDeCambioValidator.validateValue(testValue);
          final result3 = FondoDeCambioValidator.validateValue(testValue);

          expect(
            result1.isValid,
            result2.isValid,
            reason: 'Validation should be idempotent for value: $testValue',
          );
          expect(
            result2.isValid,
            result3.isValid,
            reason: 'Validation should be idempotent for value: $testValue',
          );
          expect(
            result1.errorMessage,
            result2.errorMessage,
            reason: 'Error messages should be consistent for value: $testValue',
          );
        }
      },
    );
  });
}
