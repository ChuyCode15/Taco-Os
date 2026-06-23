import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/domain/entities/product.dart';
import 'package:taco_os_app/domain/entities/sale.dart';
import 'package:taco_os_app/domain/entities/sale_item.dart';
import 'package:taco_os_app/domain/usecases/cajero/cancel_sale_use_case.dart';
import 'package:taco_os_app/domain/usecases/cajero/register_sale_use_case.dart';
import 'package:taco_os_app/domain/usecases/catalog/get_products_by_category_use_case.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_state.dart';

// Mocks
class MockGetProductsByCategoryUseCase extends Mock
    implements GetProductsByCategoryUseCase {}

class MockRegisterSaleUseCase extends Mock implements RegisterSaleUseCase {}

class MockCancelSaleUseCase extends Mock implements CancelSaleUseCase {}

void main() {
  late VentasBloc ventasBloc;
  late MockGetProductsByCategoryUseCase mockGetProductsByCategory;
  late MockRegisterSaleUseCase mockRegisterSale;
  late MockCancelSaleUseCase mockCancelSale;

  setUp(() {
    mockGetProductsByCategory = MockGetProductsByCategoryUseCase();
    mockRegisterSale = MockRegisterSaleUseCase();
    mockCancelSale = MockCancelSaleUseCase();

    ventasBloc = VentasBloc(
      getProductsByCategoryUseCase: mockGetProductsByCategory,
      registerSaleUseCase: mockRegisterSale,
      cancelSaleUseCase: mockCancelSale,
    );

    // Register fallback values for mocktail
    registerFallbackValue(
      GetProductsByCategoryParams(
        businessId: '',
        category: ProductCategory.comida,
      ),
    );
    registerFallbackValue(RegisterSaleParams(sale: _createDummySale()));
    registerFallbackValue(
      CancelSaleParams(
        saleId: '',
        photoPath: '',
        saleTimestamp: DateTime.now(),
      ),
    );
  });

  tearDown(() {
    ventasBloc.close();
  });

  group('Task 20.1 - isCancellable() Helper Function', () {
    test('returns true when sale timestamp is less than 5 minutes ago', () {
      // Arrange
      final recentTimestamp = DateTime.now().subtract(
        const Duration(minutes: 4),
      );

      // Act
      final result = ventasBloc.isCancellable(recentTimestamp);

      // Assert
      expect(result, isTrue);
    });

    test('returns false when sale timestamp is exactly 5 minutes ago', () {
      // Arrange
      final exactlyFiveMinutes = DateTime.now().subtract(
        const Duration(minutes: 5),
      );

      // Act
      final result = ventasBloc.isCancellable(exactlyFiveMinutes);

      // Assert
      expect(result, isFalse);
    });

    test('returns false when sale timestamp is more than 5 minutes ago', () {
      // Arrange
      final oldTimestamp = DateTime.now().subtract(const Duration(minutes: 10));

      // Act
      final result = ventasBloc.isCancellable(oldTimestamp);

      // Assert
      expect(result, isFalse);
    });

    test('returns true when sale timestamp is 1 second ago', () {
      // Arrange
      final veryRecentTimestamp = DateTime.now().subtract(
        const Duration(seconds: 1),
      );

      // Act
      final result = ventasBloc.isCancellable(veryRecentTimestamp);

      // Assert
      expect(result, isTrue);
    });

    test('returns true when sale timestamp is 4 minutes 59 seconds ago', () {
      // Arrange
      final justUnderFiveMinutes = DateTime.now().subtract(
        const Duration(minutes: 4, seconds: 59),
      );

      // Act
      final result = ventasBloc.isCancellable(justUnderFiveMinutes);

      // Assert
      expect(result, isTrue);
    });
  });

  group('Task 20.1 - SaleCancellationRequested Event', () {
    blocTest<VentasBloc, VentasState>(
      'emits CancellationView when sale is within 5-minute window',
      build: () => ventasBloc,
      act: (bloc) {
        final recentTimestamp = DateTime.now().subtract(
          const Duration(minutes: 3),
        );
        bloc.add(
          SaleCancellationRequested(
            saleId: 'sale-123',
            saleTimestamp: recentTimestamp,
          ),
        );
      },
      expect: () => [
        predicate<CancellationView>(
          (state) =>
              state.saleId == 'sale-123' &&
              state.saleTimestamp.difference(DateTime.now()).inMinutes.abs() <=
                  3,
        ),
      ],
    );

    blocTest<VentasBloc, VentasState>(
      'emits SaleError when sale is outside 5-minute window',
      build: () => ventasBloc,
      act: (bloc) {
        final oldTimestamp = DateTime.now().subtract(
          const Duration(minutes: 6),
        );
        bloc.add(
          SaleCancellationRequested(
            saleId: 'sale-123',
            saleTimestamp: oldTimestamp,
          ),
        );
      },
      expect: () => [
        const SaleError(
          message: 'La venta no puede ser cancelada después de 5 minutos',
        ),
      ],
    );

    blocTest<VentasBloc, VentasState>(
      'emits SaleError when sale is exactly at 5-minute boundary',
      build: () => ventasBloc,
      act: (bloc) {
        final exactlyFiveMinutes = DateTime.now().subtract(
          const Duration(minutes: 5),
        );
        bloc.add(
          SaleCancellationRequested(
            saleId: 'sale-123',
            saleTimestamp: exactlyFiveMinutes,
          ),
        );
      },
      expect: () => [
        const SaleError(
          message: 'La venta no puede ser cancelada después de 5 minutos',
        ),
      ],
    );
  });

  group('Task 20.1 - CancellationPhotoTaken Event', () {
    blocTest<VentasBloc, VentasState>(
      'verifies isCancellable again before processing (race condition guard)',
      build: () {
        // Mock successful cancellation
        when(() => mockCancelSale(any())).thenAnswer(
          (_) async => Right(_createDummySale(status: SaleStatus.cancelled)),
        );
        return ventasBloc;
      },
      act: (bloc) {
        final oldTimestamp = DateTime.now().subtract(
          const Duration(minutes: 6),
        );
        bloc.add(
          CancellationPhotoTaken(
            saleId: 'sale-123',
            photoPath: '/path/to/photo.jpg',
            saleTimestamp: oldTimestamp,
          ),
        );
      },
      expect: () => [
        const SaleError(
          message: 'La ventana de cancelación ha expirado (5 minutos)',
        ),
      ],
      verify: (_) {
        // Verify that CancelSaleUseCase was NOT called because window expired
        verifyNever(() => mockCancelSale(any()));
      },
    );

    blocTest<VentasBloc, VentasState>(
      'successfully cancels sale when within window and photo provided',
      build: () {
        final cancelledSale = _createDummySale(status: SaleStatus.cancelled);
        when(
          () => mockCancelSale(any()),
        ).thenAnswer((_) async => Right(cancelledSale));
        return ventasBloc;
      },
      act: (bloc) {
        final recentTimestamp = DateTime.now().subtract(
          const Duration(minutes: 2),
        );
        bloc.add(
          CancellationPhotoTaken(
            saleId: 'sale-123',
            photoPath: '/path/to/photo.jpg',
            saleTimestamp: recentTimestamp,
          ),
        );
      },
      expect: () => [
        const VentasLoading(),
        predicate<CancellationSuccess>(
          (state) => state.cancelledSale.status == SaleStatus.cancelled,
        ),
      ],
      verify: (_) {
        // Verify that CancelSaleUseCase was called with correct parameters
        verify(
          () => mockCancelSale(
            any(
              that: predicate<CancelSaleParams>(
                (params) =>
                    params.saleId == 'sale-123' &&
                    params.photoPath == '/path/to/photo.jpg',
              ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<VentasBloc, VentasState>(
      'emits SaleError when CancelSaleUseCase fails',
      build: () {
        when(() => mockCancelSale(any())).thenAnswer(
          (_) async =>
              const Left(LocalDatabaseFailure(message: 'Database error')),
        );
        return ventasBloc;
      },
      act: (bloc) {
        final recentTimestamp = DateTime.now().subtract(
          const Duration(minutes: 2),
        );
        bloc.add(
          CancellationPhotoTaken(
            saleId: 'sale-123',
            photoPath: '/path/to/photo.jpg',
            saleTimestamp: recentTimestamp,
          ),
        );
      },
      expect: () => [
        const VentasLoading(),
        const SaleError(message: 'Database error'),
      ],
    );
  });

  group('Task 20 - Anti-Fraude Window Requirements Validation', () {
    test('Requirement 6.1 - Sale is cancellable only within 5 minutes', () {
      // Test various timestamps
      final testCases = [
        (Duration(seconds: 30), true, 'Within 30 seconds'),
        (Duration(minutes: 1), true, 'Within 1 minute'),
        (Duration(minutes: 4, seconds: 30), true, 'Within 4.5 minutes'),
        (Duration(minutes: 4, seconds: 59), true, 'Just under 5 minutes'),
        (Duration(minutes: 5), false, 'Exactly 5 minutes'),
        (Duration(minutes: 5, seconds: 1), false, 'Just over 5 minutes'),
        (Duration(minutes: 10), false, 'After 10 minutes'),
      ];

      for (final testCase in testCases) {
        final timestamp = DateTime.now().subtract(testCase.$1);
        final expected = testCase.$2;
        final description = testCase.$3;

        expect(
          ventasBloc.isCancellable(timestamp),
          expected,
          reason: description,
        );
      }
    });

    blocTest<VentasBloc, VentasState>(
      'Requirement 6.2 - Activates camera when cancellation requested within window',
      build: () => ventasBloc,
      act: (bloc) {
        final recentTimestamp = DateTime.now().subtract(
          const Duration(minutes: 3),
        );
        bloc.add(
          SaleCancellationRequested(
            saleId: 'sale-123',
            saleTimestamp: recentTimestamp,
          ),
        );
      },
      expect: () => [isA<CancellationView>()],
    );

    blocTest<VentasBloc, VentasState>(
      'Requirement 6.3 - Blocks cancellation when camera unavailable (via use case)',
      build: () {
        when(() => mockCancelSale(any())).thenAnswer(
          (_) async =>
              const Left(CameraFailure(message: 'Cámara no disponible')),
        );
        return ventasBloc;
      },
      act: (bloc) {
        final recentTimestamp = DateTime.now().subtract(
          const Duration(minutes: 2),
        );
        bloc.add(
          CancellationPhotoTaken(
            saleId: 'sale-123',
            photoPath: '/path/to/photo.jpg',
            saleTimestamp: recentTimestamp,
          ),
        );
      },
      expect: () => [
        const VentasLoading(),
        const SaleError(message: 'Cámara no disponible'),
      ],
    );

    blocTest<VentasBloc, VentasState>(
      'Requirement 6.5 - Prevents cancellation after 5 minutes with appropriate message',
      build: () => ventasBloc,
      act: (bloc) {
        final oldTimestamp = DateTime.now().subtract(
          const Duration(minutes: 5),
        );
        bloc.add(
          SaleCancellationRequested(
            saleId: 'sale-123',
            saleTimestamp: oldTimestamp,
          ),
        );
      },
      expect: () => [
        const SaleError(
          message: 'La venta no puede ser cancelada después de 5 minutos',
        ),
      ],
    );
  });
}

// Helper function to create a dummy sale for testing
Sale _createDummySale({SaleStatus status = SaleStatus.completed}) {
  return Sale(
    id: 'test-sale-id',
    sessionId: 'test-session-id',
    businessId: 'test-business-id',
    cashierId: 'test-cashier-id',
    items: [
      const SaleItem(
        productId: 'product-1',
        productName: 'Taco',
        quantity: 2,
        unitPrice: 15.0,
        subtotal: 30.0,
      ),
    ],
    total: 30.0,
    paymentMethod: PaymentMethod.cash,
    status: status,
    timestamp: DateTime.now(),
    isSynced: false,
  );
}
