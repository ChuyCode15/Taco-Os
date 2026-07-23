import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/domain/entities/cash_session.dart';
import 'package:taco_os_app/domain/entities/sale.dart';
import 'package:taco_os_app/domain/entities/sale_item.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_state.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_state.dart';
import 'package:taco_os_app/presentation/pages/cajero/ventas/sale_confirmation_page.dart';

// Mocks
class MockVentasBloc extends Mock implements VentasBloc {}

class MockCajeroBloc extends Mock implements CajeroBloc {}

void main() {
  late MockVentasBloc mockVentasBloc;
  late MockCajeroBloc mockCajeroBloc;

  setUp(() {
    mockVentasBloc = MockVentasBloc();
    mockCajeroBloc = MockCajeroBloc();

    // Default bloc states
    final testSession = CashSession(
      id: 'session-123',
      businessId: 'business-456',
      userId: 'user-789',
      initialCash: 1000.0,
      openedAt: DateTime.now(),
      status: SessionStatus.open,
    );

    when(
      () => mockCajeroBloc.state,
    ).thenReturn(TurnoActivo(session: testSession));
    when(() => mockVentasBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCajeroBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<VentasBloc>.value(value: mockVentasBloc),
          BlocProvider<CajeroBloc>.value(value: mockCajeroBloc),
        ],
        child: const SaleConfirmationPage(),
      ),
    );
  }

  group('Task 20.2 - Sale Cancellation UI', () {
    testWidgets(
      'Requirement 6.2 - Shows cancellation button only for recent sales (< 5 minutes)',
      (WidgetTester tester) async {
        // Create a recent sale (2 minutes old)
        final recentSale = Sale(
          id: 'sale-123',
          sessionId: 'session-123',
          businessId: 'business-456',
          cashierId: 'user-789',
          items: [
            SaleItem(
              productId: 'prod-1',
              productName: 'Taco',
              quantity: 2,
              unitPrice: 15.0,
              subtotal: 30.0,
            ),
          ],
          total: 30.0,
          paymentMethod: PaymentMethod.cash,
          status: SaleStatus.completed,
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          isSynced: false,
        );

        when(
          () => mockVentasBloc.state,
        ).thenReturn(SaleSuccess(sale: recentSale));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Should show success screen
        expect(find.text('¡Venta Registrada!'), findsOneWidget);

        // Should show warning about cancellation window
        expect(find.textContaining('próximos 5 minutos'), findsOneWidget);

        // Should show cancel button
        expect(find.text('Cancelar Venta'), findsOneWidget);
      },
    );

    testWidgets(
      'Requirement 6.5 - Does NOT show cancellation button for old sales (>= 5 minutes)',
      (WidgetTester tester) async {
        // Create an old sale (6 minutes old)
        final oldSale = Sale(
          id: 'sale-123',
          sessionId: 'session-123',
          businessId: 'business-456',
          cashierId: 'user-789',
          items: [
            SaleItem(
              productId: 'prod-1',
              productName: 'Taco',
              quantity: 2,
              unitPrice: 15.0,
              subtotal: 30.0,
            ),
          ],
          total: 30.0,
          paymentMethod: PaymentMethod.cash,
          status: SaleStatus.completed,
          timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
          isSynced: false,
        );

        when(() => mockVentasBloc.state).thenReturn(SaleSuccess(sale: oldSale));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Should show success screen
        expect(find.text('¡Venta Registrada!'), findsOneWidget);

        // Should NOT show warning about cancellation window
        expect(find.textContaining('próximos 5 minutos'), findsNothing);

        // Should NOT show cancel button
        expect(find.text('Cancelar Venta'), findsNothing);
      },
    );

    testWidgets(
      'Requirement 6.1 - isCancellable property correctly identifies cancellable sales',
      (WidgetTester tester) async {
        // Test isCancellable property on entity
        final recentSale = Sale(
          id: 'sale-1',
          sessionId: 'session-1',
          businessId: 'business-1',
          cashierId: 'user-1',
          items: [],
          total: 50.0,
          paymentMethod: PaymentMethod.cash,
          status: SaleStatus.completed,
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
          isSynced: false,
        );

        // Should be cancellable (< 5 minutes and completed)
        expect(recentSale.isCancellable, isTrue);

        final oldSale = recentSale.copyWith(
          timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
        );

        // Should NOT be cancellable (>= 5 minutes)
        expect(oldSale.isCancellable, isFalse);

        final cancelledSale = recentSale.copyWith(status: SaleStatus.cancelled);

        // Should NOT be cancellable (already cancelled)
        expect(cancelledSale.isCancellable, isFalse);
      },
    );

    testWidgets('Requirement 6.7 - Cancel button styled with warning colors', (
      WidgetTester tester,
    ) async {
      final recentSale = Sale(
        id: 'sale-123',
        sessionId: 'session-123',
        businessId: 'business-456',
        cashierId: 'user-789',
        items: [
          SaleItem(
            productId: 'prod-1',
            productName: 'Taco',
            quantity: 1,
            unitPrice: 15.0,
            subtotal: 15.0,
          ),
        ],
        total: 15.0,
        paymentMethod: PaymentMethod.cash,
        status: SaleStatus.completed,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        isSynced: false,
      );

      when(
        () => mockVentasBloc.state,
      ).thenReturn(SaleSuccess(sale: recentSale));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the cancel button
      final cancelButtonFinder = find.widgetWithText(
        OutlinedButton,
        'Cancelar Venta',
      );
      expect(cancelButtonFinder, findsOneWidget);

      // Verify it has red styling
      final button = tester.widget<OutlinedButton>(cancelButtonFinder);
      expect(button.style?.foregroundColor?.resolve({}), Colors.red);

      // Verify cancel icon is present
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('Shows sale summary on success screen', (
      WidgetTester tester,
    ) async {
      final testSale = Sale(
        id: 'sale-123',
        sessionId: 'session-123',
        businessId: 'business-456',
        cashierId: 'user-789',
        items: [
          SaleItem(
            productId: 'prod-1',
            productName: 'Taco',
            quantity: 2,
            unitPrice: 15.0,
            subtotal: 30.0,
          ),
        ],
        total: 30.0,
        paymentMethod: PaymentMethod.cash,
        status: SaleStatus.completed,
        timestamp: DateTime.now(),
        isSynced: false,
      );

      when(() => mockVentasBloc.state).thenReturn(SaleSuccess(sale: testSale));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify success elements
      expect(find.text('¡Venta Registrada!'), findsOneWidget);
      expect(find.text('\$30.00'), findsOneWidget);
      expect(find.text('Efectivo'), findsOneWidget);
      expect(find.text('Regresar a Modo Cajero'), findsOneWidget);
    });
  });
}
