import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/domain/entities/sale.dart';
import 'package:taco_os_app/domain/entities/sale_item.dart';
import 'package:taco_os_app/domain/repositories/i_transaction_repository.dart';
import 'package:taco_os_app/domain/usecases/cajero/register_sale_use_case.dart';

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

void main() {
  late RegisterSaleUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = RegisterSaleUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      Sale(
        id: 'sale-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        items: const [
          SaleItem(
            productId: 'prod-1',
            productName: 'Taco al pastor',
            quantity: 1,
            unitPrice: 15.0,
            subtotal: 15.0,
          ),
        ],
        total: 15.0,
        paymentMethod: PaymentMethod.cash,
        status: SaleStatus.completed,
        timestamp: DateTime.now(),
      ),
    );
  });

  group('RegisterSaleUseCase - Product Quantity Boundary Testing', () {
    test('should fail with quantity = 0 (minimum invalid)', () async {
      // Arrange
      final sale = Sale(
        id: 'sale-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        items: const [
          SaleItem(
            productId: 'prod-1',
            productName: 'Taco al pastor',
            quantity: 0,
            unitPrice: 15.0,
            subtotal: 0.0,
          ),
        ],
        total: 0.0,
        paymentMethod: PaymentMethod.cash,
        status: SaleStatus.completed,
        timestamp: DateTime.now(),
      );
      final params = RegisterSaleParams(sale: sale);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('mayor a cero'),
        );
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.saveSale(any()));
    });

    test('should succeed with quantity = 1 (minimum valid)', () async {
      // Arrange
      final sale = Sale(
        id: 'sale-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        items: const [
          SaleItem(
            productId: 'prod-1',
            productName: 'Taco al pastor',
            quantity: 1,
            unitPrice: 15.0,
            subtotal: 15.0,
          ),
        ],
        total: 15.0,
        paymentMethod: PaymentMethod.cash,
        status: SaleStatus.completed,
        timestamp: DateTime.now(),
      );
      final params = RegisterSaleParams(sale: sale);
      when(
        () => mockRepository.saveSale(any()),
      ).thenAnswer((_) async => Right(sale));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.saveSale(any())).called(1);
    });

    test(
      'should succeed with quantity = 999,999,999 (maximum valid)',
      () async {
        // Arrange
        final sale = Sale(
          id: 'sale-123',
          sessionId: 'session-456',
          businessId: 'business-789',
          cashierId: 'user-012',
          items: const [
            SaleItem(
              productId: 'prod-1',
              productName: 'Taco al pastor',
              quantity: 999999999,
              unitPrice: 1.0,
              subtotal: 999999999.0,
            ),
          ],
          total: 999999999.0,
          paymentMethod: PaymentMethod.cash,
          status: SaleStatus.completed,
          timestamp: DateTime.now(),
        );
        final params = RegisterSaleParams(sale: sale);
        when(
          () => mockRepository.saveSale(any()),
        ).thenAnswer((_) async => Right(sale));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
        verify(() => mockRepository.saveSale(any())).called(1);
      },
    );

    test('should fail with negative quantity', () async {
      // Arrange
      final sale = Sale(
        id: 'sale-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        items: const [
          SaleItem(
            productId: 'prod-1',
            productName: 'Taco al pastor',
            quantity: -5,
            unitPrice: 15.0,
            subtotal: -75.0,
          ),
        ],
        total: -75.0,
        paymentMethod: PaymentMethod.cash,
        status: SaleStatus.completed,
        timestamp: DateTime.now(),
      );
      final params = RegisterSaleParams(sale: sale);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('mayor a cero'),
        );
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.saveSale(any()));
    });
  });

  group('RegisterSaleUseCase - Sale Item Validation', () {
    test('should fail when sale has no items', () async {
      // Arrange
      final sale = Sale(
        id: 'sale-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        items: const [],
        total: 0.0,
        paymentMethod: PaymentMethod.cash,
        status: SaleStatus.completed,
        timestamp: DateTime.now(),
      );
      final params = RegisterSaleParams(sale: sale);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('al menos un producto'),
        );
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.saveSale(any()));
    });

    test('should fail when unit price is zero', () async {
      // Arrange
      final sale = Sale(
        id: 'sale-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        items: const [
          SaleItem(
            productId: 'prod-1',
            productName: 'Taco al pastor',
            quantity: 3,
            unitPrice: 0.0,
            subtotal: 0.0,
          ),
        ],
        total: 0.0,
        paymentMethod: PaymentMethod.cash,
        status: SaleStatus.completed,
        timestamp: DateTime.now(),
      );
      final params = RegisterSaleParams(sale: sale);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('precio unitario debe ser mayor a cero'),
        );
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.saveSale(any()));
    });

    test('should fail when unit price is negative', () async {
      // Arrange
      final sale = Sale(
        id: 'sale-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        items: const [
          SaleItem(
            productId: 'prod-1',
            productName: 'Taco al pastor',
            quantity: 3,
            unitPrice: -15.0,
            subtotal: -45.0,
          ),
        ],
        total: -45.0,
        paymentMethod: PaymentMethod.cash,
        status: SaleStatus.completed,
        timestamp: DateTime.now(),
      );
      final params = RegisterSaleParams(sale: sale);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('precio unitario debe ser mayor a cero'),
        );
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.saveSale(any()));
    });

    test(
      'should fail when subtotal does not match quantity × unitPrice',
      () async {
        // Arrange
        final sale = Sale(
          id: 'sale-123',
          sessionId: 'session-456',
          businessId: 'business-789',
          cashierId: 'user-012',
          items: const [
            SaleItem(
              productId: 'prod-1',
              productName: 'Taco al pastor',
              quantity: 3,
              unitPrice: 15.0,
              subtotal: 40.0, // Should be 45.0
            ),
          ],
          total: 40.0,
          paymentMethod: PaymentMethod.cash,
          status: SaleStatus.completed,
          timestamp: DateTime.now(),
        );
        final params = RegisterSaleParams(sale: sale);

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            (failure as ValidationFailure).message,
            contains('Subtotal incorrecto'),
          );
        }, (_) => fail('Should have returned a failure'));
        verifyNever(() => mockRepository.saveSale(any()));
      },
    );

    test('should succeed with multiple items', () async {
      // Arrange
      final sale = Sale(
        id: 'sale-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        items: const [
          SaleItem(
            productId: 'prod-1',
            productName: 'Taco al pastor',
            quantity: 3,
            unitPrice: 15.0,
            subtotal: 45.0,
          ),
          SaleItem(
            productId: 'prod-2',
            productName: 'Refresco',
            quantity: 2,
            unitPrice: 20.0,
            subtotal: 40.0,
          ),
        ],
        total: 85.0,
        paymentMethod: PaymentMethod.card,
        status: SaleStatus.completed,
        timestamp: DateTime.now(),
      );
      final params = RegisterSaleParams(sale: sale);
      when(
        () => mockRepository.saveSale(any()),
      ).thenAnswer((_) async => Right(sale));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.saveSale(any())).called(1);
    });
  });

  group('RegisterSaleUseCase - Total Validation', () {
    test('should fail when total is zero', () async {
      // Arrange
      final sale = Sale(
        id: 'sale-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        items: const [
          SaleItem(
            productId: 'prod-1',
            productName: 'Taco al pastor',
            quantity: 1,
            unitPrice: 15.0,
            subtotal: 15.0,
          ),
        ],
        total: 0.0,
        paymentMethod: PaymentMethod.cash,
        status: SaleStatus.completed,
        timestamp: DateTime.now(),
      );
      final params = RegisterSaleParams(sale: sale);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('monto total debe ser mayor a cero'),
        );
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.saveSale(any()));
    });

    test('should fail when total is negative', () async {
      // Arrange
      final sale = Sale(
        id: 'sale-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        items: const [
          SaleItem(
            productId: 'prod-1',
            productName: 'Taco al pastor',
            quantity: 1,
            unitPrice: 15.0,
            subtotal: 15.0,
          ),
        ],
        total: -15.0,
        paymentMethod: PaymentMethod.cash,
        status: SaleStatus.completed,
        timestamp: DateTime.now(),
      );
      final params = RegisterSaleParams(sale: sale);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('monto total debe ser mayor a cero'),
        );
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.saveSale(any()));
    });

    test('should fail when total does not match sum of subtotals', () async {
      // Arrange
      final sale = Sale(
        id: 'sale-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        items: const [
          SaleItem(
            productId: 'prod-1',
            productName: 'Taco al pastor',
            quantity: 3,
            unitPrice: 15.0,
            subtotal: 45.0,
          ),
          SaleItem(
            productId: 'prod-2',
            productName: 'Refresco',
            quantity: 2,
            unitPrice: 20.0,
            subtotal: 40.0,
          ),
        ],
        total: 100.0, // Should be 85.0
        paymentMethod: PaymentMethod.cash,
        status: SaleStatus.completed,
        timestamp: DateTime.now(),
      );
      final params = RegisterSaleParams(sale: sale);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('no coincide con la suma'),
        );
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.saveSale(any()));
    });
  });

  group('RegisterSaleUseCase - Repository Error Handling', () {
    test('should return LocalDatabaseFailure when repository fails', () async {
      // Arrange
      final sale = Sale(
        id: 'sale-123',
        sessionId: 'session-456',
        businessId: 'business-789',
        cashierId: 'user-012',
        items: const [
          SaleItem(
            productId: 'prod-1',
            productName: 'Taco al pastor',
            quantity: 3,
            unitPrice: 15.0,
            subtotal: 45.0,
          ),
        ],
        total: 45.0,
        paymentMethod: PaymentMethod.cash,
        status: SaleStatus.completed,
        timestamp: DateTime.now(),
      );
      final params = RegisterSaleParams(sale: sale);
      when(() => mockRepository.saveSale(any())).thenAnswer(
        (_) async =>
            Left(LocalDatabaseFailure(message: 'Error escribiendo en SQLite')),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<LocalDatabaseFailure>());
      }, (_) => fail('Should have returned a failure'));
      verify(() => mockRepository.saveSale(any())).called(1);
    });
  });
}
