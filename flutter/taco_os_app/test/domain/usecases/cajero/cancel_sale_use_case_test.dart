import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/domain/entities/sale.dart';
import 'package:taco_os_app/domain/entities/sale_item.dart';
import 'package:taco_os_app/domain/repositories/i_transaction_repository.dart';
import 'package:taco_os_app/domain/usecases/cajero/cancel_sale_use_case.dart';

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

void main() {
  late CancelSaleUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = CancelSaleUseCase(mockRepository);
  });

  group('CancelSaleUseCase - Anti-Fraud Window Validation', () {
    final tSale = Sale(
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
      status: SaleStatus.cancelled,
      timestamp: DateTime.now(),
      cancellationPhotoUrl: '/path/to/photo.jpg',
    );

    test(
      'should succeed when cancelling sale within window (0 minutes elapsed)',
      () async {
        // Arrange - Sale just registered (0 minutes ago)
        final saleTimestamp = DateTime.now();
        final params = CancelSaleParams(
          saleId: 'sale-123',
          photoPath: '/path/to/cancellation-photo.jpg',
          saleTimestamp: saleTimestamp,
        );
        when(
          () => mockRepository.cancelSale(any(), any()),
        ).thenAnswer((_) async => Right(tSale));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
        verify(() => mockRepository.cancelSale('sale-123', any())).called(1);
      },
    );

    test(
      'should succeed when cancelling sale within window (4 minutes 59 seconds elapsed)',
      () async {
        // Arrange - Sale registered 4 minutes and 59 seconds ago
        final saleTimestamp = DateTime.now().subtract(
          const Duration(minutes: 4, seconds: 59),
        );
        final params = CancelSaleParams(
          saleId: 'sale-123',
          photoPath: '/path/to/cancellation-photo.jpg',
          saleTimestamp: saleTimestamp,
        );
        when(
          () => mockRepository.cancelSale(any(), any()),
        ).thenAnswer((_) async => Right(tSale));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
        verify(() => mockRepository.cancelSale('sale-123', any())).called(1);
      },
    );

    test('should fail when cancelling sale at exactly 5 minutes', () async {
      // Arrange - Sale registered exactly 5 minutes ago (boundary)
      final saleTimestamp = DateTime.now().subtract(const Duration(minutes: 5));
      final params = CancelSaleParams(
        saleId: 'sale-123',
        photoPath: '/path/to/cancellation-photo.jpg',
        saleTimestamp: saleTimestamp,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('no puede ser cancelada después de 5 minutos'),
        );
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.cancelSale(any(), any()));
    });

    test(
      'should fail when cancelling sale after 5 minutes (6 minutes)',
      () async {
        // Arrange - Sale registered 6 minutes ago
        final saleTimestamp = DateTime.now().subtract(
          const Duration(minutes: 6),
        );
        final params = CancelSaleParams(
          saleId: 'sale-123',
          photoPath: '/path/to/cancellation-photo.jpg',
          saleTimestamp: saleTimestamp,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            (failure as ValidationFailure).message,
            contains('no puede ser cancelada después de 5 minutos'),
          );
        }, (_) => fail('Should have returned a failure'));
        verifyNever(() => mockRepository.cancelSale(any(), any()));
      },
    );

    test('should fail when cancelling sale after 10 minutes', () async {
      // Arrange - Sale registered 10 minutes ago (well outside window)
      final saleTimestamp = DateTime.now().subtract(
        const Duration(minutes: 10),
      );
      final params = CancelSaleParams(
        saleId: 'sale-123',
        photoPath: '/path/to/cancellation-photo.jpg',
        saleTimestamp: saleTimestamp,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('no puede ser cancelada después de 5 minutos'),
        );
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.cancelSale(any(), any()));
    });
  });

  group('CancelSaleUseCase - Photo Validation', () {
    final tSale = Sale(
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
      status: SaleStatus.cancelled,
      timestamp: DateTime.now(),
      cancellationPhotoUrl: '/path/to/photo.jpg',
    );

    test('should fail when photo path is empty', () async {
      // Arrange
      final saleTimestamp = DateTime.now();
      final params = CancelSaleParams(
        saleId: 'sale-123',
        photoPath: '',
        saleTimestamp: saleTimestamp,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('foto del producto devuelto es obligatoria'),
        );
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.cancelSale(any(), any()));
    });

    test(
      'should succeed when photo path is provided and within window',
      () async {
        // Arrange
        final saleTimestamp = DateTime.now().subtract(
          const Duration(minutes: 2),
        );
        final params = CancelSaleParams(
          saleId: 'sale-123',
          photoPath: '/path/to/cancellation-photo.jpg',
          saleTimestamp: saleTimestamp,
        );
        when(
          () => mockRepository.cancelSale(any(), any()),
        ).thenAnswer((_) async => Right(tSale));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
        verify(
          () => mockRepository.cancelSale(
            'sale-123',
            '/path/to/cancellation-photo.jpg',
          ),
        ).called(1);
      },
    );
  });

  group('CancelSaleUseCase - Combined Validations', () {
    test(
      'should fail with ValidationFailure even with photo if outside window',
      () async {
        // Arrange - Outside window but with photo
        final saleTimestamp = DateTime.now().subtract(
          const Duration(minutes: 6),
        );
        final params = CancelSaleParams(
          saleId: 'sale-123',
          photoPath: '/path/to/cancellation-photo.jpg',
          saleTimestamp: saleTimestamp,
        );

        // Act
        final result = await useCase(params);

        // Assert - Window validation happens first
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            (failure as ValidationFailure).message,
            contains('no puede ser cancelada después de 5 minutos'),
          );
        }, (_) => fail('Should have returned a failure'));
        verifyNever(() => mockRepository.cancelSale(any(), any()));
      },
    );

    test('should fail when within window but without photo', () async {
      // Arrange - Within window but no photo
      final saleTimestamp = DateTime.now().subtract(const Duration(minutes: 2));
      final params = CancelSaleParams(
        saleId: 'sale-123',
        photoPath: '',
        saleTimestamp: saleTimestamp,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('foto del producto devuelto es obligatoria'),
        );
      }, (_) => fail('Should have returned a failure'));
      verifyNever(() => mockRepository.cancelSale(any(), any()));
    });
  });

  group('CancelSaleUseCase - Repository Error Handling', () {
    test('should return LocalDatabaseFailure when repository fails', () async {
      // Arrange
      final saleTimestamp = DateTime.now().subtract(const Duration(minutes: 2));
      final params = CancelSaleParams(
        saleId: 'sale-123',
        photoPath: '/path/to/cancellation-photo.jpg',
        saleTimestamp: saleTimestamp,
      );
      when(() => mockRepository.cancelSale(any(), any())).thenAnswer(
        (_) async =>
            Left(LocalDatabaseFailure(message: 'Error actualizando SQLite')),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<LocalDatabaseFailure>());
      }, (_) => fail('Should have returned a failure'));
      verify(() => mockRepository.cancelSale(any(), any())).called(1);
    });

    test('should return CameraFailure when repository returns it', () async {
      // Arrange
      final saleTimestamp = DateTime.now().subtract(const Duration(minutes: 2));
      final params = CancelSaleParams(
        saleId: 'sale-123',
        photoPath: '/path/to/cancellation-photo.jpg',
        saleTimestamp: saleTimestamp,
      );
      when(() => mockRepository.cancelSale(any(), any())).thenAnswer(
        (_) async => Left(CameraFailure(message: 'Cámara no disponible')),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<CameraFailure>());
      }, (_) => fail('Should have returned a failure'));
      verify(() => mockRepository.cancelSale(any(), any())).called(1);
    });
  });
}
