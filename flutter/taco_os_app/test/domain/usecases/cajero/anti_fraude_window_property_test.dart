import 'dart:math';

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

/// **Property 3: Anti-Fraude Window Enforcement**
/// **Validates: Requirements 6.1, 6.4, 6.5**
///
/// This property-based test verifies that:
/// 1. Sales can only be cancelled within 5 minutes of their creation timestamp
/// 2. The `isCancellable` property on the Sale entity returns true only when
///    `now - timestamp < 5 minutes`
/// 3. The `CancelSaleUseCase` properly enforces this rule by returning a
///    `ValidationFailure` for timestamps that are 5 minutes or older
///
/// The test generates random timestamps between 0 and 10 minutes in the past
/// and verifies the anti-fraud window enforcement property holds for all inputs.
void main() {
  late CancelSaleUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = CancelSaleUseCase(mockRepository);
  });

  group('Property 3: Anti-Fraude Window Enforcement', () {
    final random = Random(42); // Fixed seed for reproducibility
    const numTests = 100; // Number of random test cases to generate

    test(
      'Property: isCancellable returns true only when now - timestamp < 5 minutes',
      () {
        // Generate random timestamps between 0 and 10 minutes in the past
        for (int i = 0; i < numTests; i++) {
          // Generate random seconds between 0 and 600 (10 minutes)
          final secondsAgo = random.nextInt(601);
          final timestamp = DateTime.now().subtract(
            Duration(seconds: secondsAgo),
          );

          // Create a completed sale with the generated timestamp
          final sale = Sale(
            id: 'sale-$i',
            sessionId: 'session-test',
            businessId: 'business-test',
            cashierId: 'cashier-test',
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
            timestamp: timestamp,
          );

          // Calculate if the sale should be cancellable
          // A sale is cancellable if elapsed time < 5 minutes (300 seconds)
          final shouldBeCancellable = secondsAgo < 300;

          // Verify that isCancellable property matches expected result
          expect(
            sale.isCancellable,
            shouldBeCancellable,
            reason:
                'Sale with timestamp $secondsAgo seconds ago should ${shouldBeCancellable ? "be" : "not be"} cancellable',
          );
        }
      },
    );

    test(
      'Property: CancelSaleUseCase returns ValidationFailure for timestamps >= 5 minutes',
      () async {
        // Generate random timestamps between 0 and 10 minutes in the past
        for (int i = 0; i < numTests; i++) {
          // Generate random seconds between 0 and 600 (10 minutes)
          final secondsAgo = random.nextInt(601);
          final timestamp = DateTime.now().subtract(
            Duration(seconds: secondsAgo),
          );

          // Create params for cancellation
          final params = CancelSaleParams(
            saleId: 'sale-$i',
            photoPath: '/path/to/photo-$i.jpg',
            saleTimestamp: timestamp,
          );

          // Calculate expected result
          // Should fail if >= 5 minutes (300 seconds)
          final shouldFail = secondsAgo >= 300;

          if (shouldFail) {
            // Act
            final result = await useCase(params);

            // Assert - Should return ValidationFailure
            expect(
              result.isLeft(),
              true,
              reason:
                  'CancelSaleUseCase should fail for timestamp $secondsAgo seconds ago (>= 5 minutes)',
            );

            result.fold(
              (failure) {
                expect(
                  failure,
                  isA<ValidationFailure>(),
                  reason: 'Failure should be a ValidationFailure',
                );
                expect(
                  (failure as ValidationFailure).message,
                  contains('no puede ser cancelada después de 5 minutos'),
                  reason: 'Failure message should mention the 5-minute window',
                );
              },
              (_) => fail(
                'Expected ValidationFailure for timestamp $secondsAgo seconds ago',
              ),
            );

            // Verify repository was never called
            verifyNever(() => mockRepository.cancelSale(any(), any()));
          } else {
            // Within window - should succeed if repository returns success
            final mockSale = Sale(
              id: 'sale-$i',
              sessionId: 'session-test',
              businessId: 'business-test',
              cashierId: 'cashier-test',
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
              status: SaleStatus.cancelled,
              timestamp: timestamp,
              cancellationPhotoUrl: '/path/to/photo-$i.jpg',
            );

            when(
              () => mockRepository.cancelSale(any(), any()),
            ).thenAnswer((_) async => Right(mockSale));

            // Act
            final result = await useCase(params);

            // Assert - Should succeed
            expect(
              result.isRight(),
              true,
              reason:
                  'CancelSaleUseCase should succeed for timestamp $secondsAgo seconds ago (< 5 minutes)',
            );

            // Verify repository was called
            verify(() => mockRepository.cancelSale('sale-$i', any())).called(1);

            // Reset mock for next iteration
            reset(mockRepository);
          }
        }
      },
    );

    test(
      'Property: Boundary test at exactly 5 minutes (300 seconds)',
      () async {
        // Test multiple times at the exact boundary to catch edge cases
        for (int i = 0; i < 10; i++) {
          // Create timestamp at exactly 5 minutes (300 seconds) ago
          final timestamp = DateTime.now().subtract(
            const Duration(seconds: 300),
          );

          // Test Sale entity's isCancellable property
          final sale = Sale(
            id: 'boundary-sale-$i',
            sessionId: 'session-test',
            businessId: 'business-test',
            cashierId: 'cashier-test',
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
            timestamp: timestamp,
          );

          // At exactly 5 minutes, should NOT be cancellable
          expect(
            sale.isCancellable,
            false,
            reason: 'Sale at exactly 5 minutes should NOT be cancellable',
          );

          // Test CancelSaleUseCase with exact boundary
          final params = CancelSaleParams(
            saleId: 'boundary-sale-$i',
            photoPath: '/path/to/photo.jpg',
            saleTimestamp: timestamp,
          );

          final result = await useCase(params);

          // Should fail with ValidationFailure
          expect(
            result.isLeft(),
            true,
            reason:
                'CancelSaleUseCase should fail at exactly 5 minutes boundary',
          );

          result.fold((failure) {
            expect(failure, isA<ValidationFailure>());
          }, (_) => fail('Expected ValidationFailure at 5-minute boundary'));

          verifyNever(() => mockRepository.cancelSale(any(), any()));
        }
      },
    );

    test(
      'Property: Just under 5 minutes (299 seconds) should be cancellable',
      () async {
        // Test multiple times just under the boundary
        for (int i = 0; i < 10; i++) {
          // Create timestamp at 299 seconds (just under 5 minutes) ago
          final timestamp = DateTime.now().subtract(
            const Duration(seconds: 299),
          );

          // Test Sale entity's isCancellable property
          final sale = Sale(
            id: 'under-boundary-sale-$i',
            sessionId: 'session-test',
            businessId: 'business-test',
            cashierId: 'cashier-test',
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
            timestamp: timestamp,
          );

          // Just under 5 minutes should be cancellable
          expect(
            sale.isCancellable,
            true,
            reason:
                'Sale at 299 seconds (just under 5 minutes) should be cancellable',
          );

          // Test CancelSaleUseCase
          final mockCancelledSale = sale.copyWith(
            status: SaleStatus.cancelled,
            cancellationPhotoUrl: '/path/to/photo.jpg',
          );

          when(
            () => mockRepository.cancelSale(any(), any()),
          ).thenAnswer((_) async => Right(mockCancelledSale));

          final params = CancelSaleParams(
            saleId: 'under-boundary-sale-$i',
            photoPath: '/path/to/photo.jpg',
            saleTimestamp: timestamp,
          );

          final result = await useCase(params);

          // Should succeed
          expect(
            result.isRight(),
            true,
            reason: 'CancelSaleUseCase should succeed just under 5 minutes',
          );

          verify(
            () => mockRepository.cancelSale('under-boundary-sale-$i', any()),
          ).called(1);

          reset(mockRepository);
        }
      },
    );

    test(
      'Property: Cancelled sales are never cancellable regardless of time',
      () {
        // Test with various timestamps for already-cancelled sales
        for (int i = 0; i < 20; i++) {
          // Generate random seconds between 0 and 300 (within window)
          final secondsAgo = random.nextInt(301);
          final timestamp = DateTime.now().subtract(
            Duration(seconds: secondsAgo),
          );

          // Create an already-cancelled sale
          final cancelledSale = Sale(
            id: 'cancelled-sale-$i',
            sessionId: 'session-test',
            businessId: 'business-test',
            cashierId: 'cashier-test',
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
            status: SaleStatus.cancelled, // Already cancelled
            timestamp: timestamp,
            cancellationPhotoUrl: '/path/to/previous-photo.jpg',
          );

          // Should NOT be cancellable even though within time window
          expect(
            cancelledSale.isCancellable,
            false,
            reason:
                'Cancelled sale should NOT be cancellable even when timestamp is $secondsAgo seconds ago',
          );
        }
      },
    );
  });
}
