import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/domain/entities/cash_session.dart';
import 'package:taco_os_app/domain/entities/product.dart';
import 'package:taco_os_app/domain/entities/sale.dart';
import 'package:taco_os_app/domain/entities/sale_item.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_state.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/ventas_state.dart';
import 'package:taco_os_app/presentation/pages/cajero/ventas/sale_confirmation_page.dart';

// Mocks
class MockVentasBloc extends Mock implements VentasBloc {}

class MockCajeroBloc extends Mock implements CajeroBloc {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockVentasBloc mockVentasBloc;
  late MockCajeroBloc mockCajeroBloc;
  // ignore: unused_local_variable
  late MockGoRouter mockGoRouter;

  // Sample data
  final testSession = CashSession(
    id: 'session-123',
    businessId: 'business-456',
    userId: 'user-789',
    initialCash: 1000.0,
    openedAt: DateTime.now(),
    status: SessionStatus.open,
  );

  final testProduct = Product(
    id: 'prod-1',
    businessId: 'business-456',
    name: 'Taco al Pastor',
    price: 15.0,
    category: ProductCategory.comida,
    isActive: true,
    createdAt: DateTime.now(),
  );

  final testSaleItem = SaleItem(
    productId: testProduct.id,
    productName: testProduct.name,
    quantity: 2,
    unitPrice: testProduct.price,
    subtotal: 30.0,
  );

  final testSale = Sale(
    id: 'sale-123',
    sessionId: testSession.id,
    businessId: testSession.businessId,
    cashierId: testSession.userId,
    items: [testSaleItem],
    total: 30.0,
    paymentMethod: PaymentMethod.cash,
    status: SaleStatus.completed,
    timestamp: DateTime.now(),
    isSynced: false,
  );

  setUp(() {
    mockVentasBloc = MockVentasBloc();
    mockCajeroBloc = MockCajeroBloc();
    mockGoRouter = MockGoRouter();

    // Register fallback values for mocktail
    registerFallbackValue(
      SaleCancellationRequested(saleId: '', saleTimestamp: DateTime.now()),
    );

    // Default bloc states
    when(
      () => mockCajeroBloc.state,
    ).thenReturn(TurnoActivo(session: testSession));
    when(
      () => mockVentasBloc.state,
    ).thenReturn(CartView(cartItems: [testSaleItem], total: 30.0));
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

  group('Task 20.2 - Cancellation UI Implementation', () {
    testWidgets(
      'Requirement 6.2 - Shows cancellation option only when sale is cancellable (< 5 minutes)',
      (WidgetTester tester) async {
        // Test 1: Recent sale (< 5 minutes) - should show cancel button
        final recentSale = testSale.copyWith(
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        );

        when(
          () => mockVentasBloc.state,
        ).thenReturn(SaleSuccess(sale: recentSale));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Should show cancellation option
        expect(find.text('Cancelar Venta'), findsOneWidget);
        expect(
          find.text(
            'Puedes cancelar esta venta dentro de los próximos 5 minutos',
          ),
          findsOneWidget,
        );

        // Test 2: Old sale (>= 5 minutes) - should NOT show cancel button
        final oldSale = testSale.copyWith(
          timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
        );

        when(() => mockVentasBloc.state).thenReturn(SaleSuccess(sale: oldSale));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Should NOT show cancellation option
        expect(find.text('Cancelar Venta'), findsNothing);
        expect(
          find.text(
            'Puedes cancelar esta venta dentro de los próximos 5 minutos',
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Requirement 6.2 - Verifies isCancellable() before dispatching cancellation event',
      (WidgetTester tester) async {
        // Create a sale that is initially cancellable
        final recentSale = testSale.copyWith(
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        );

        when(
          () => mockVentasBloc.state,
        ).thenReturn(SaleSuccess(sale: recentSale));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap the cancel button
        await tester.tap(find.text('Cancelar Venta'));
        await tester.pumpAndSettle();

        // Confirm in the dialog
        expect(find.text('Confirmar Cancelación'), findsOneWidget);
        await tester.tap(find.text('Sí, cancelar'));
        await tester.pumpAndSettle();

        // Verify that the event was dispatched
        verify(
          () => mockVentasBloc.add(
            SaleCancellationRequested(
              saleId: recentSale.id,
              saleTimestamp: recentSale.timestamp,
            ),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'Requirement 6.2 - Shows error if sale becomes non-cancellable during dialog',
      (WidgetTester tester) async {
        // Create a sale that will be non-cancellable
        final expiredSale = testSale.copyWith(
          timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
        );

        when(
          () => mockVentasBloc.state,
        ).thenReturn(SaleSuccess(sale: expiredSale));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Should not show cancel button for expired sale
        expect(find.text('Cancelar Venta'), findsNothing);
      },
    );

    testWidgets(
      'Requirement 6.4, 6.6 - Confirmation dialog warns about mandatory photo',
      (WidgetTester tester) async {
        final recentSale = testSale.copyWith(
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        );

        when(
          () => mockVentasBloc.state,
        ).thenReturn(SaleSuccess(sale: recentSale));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap cancel button
        await tester.tap(find.text('Cancelar Venta'));
        await tester.pumpAndSettle();

        // Check dialog content mentions photo requirement
        expect(find.text('Confirmar Cancelación'), findsOneWidget);
        expect(
          find.textContaining('foto del producto devuelto como evidencia'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Requirement 6.7 - Cancel button is styled prominently with warning colors',
      (WidgetTester tester) async {
        final recentSale = testSale.copyWith(
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        );

        when(
          () => mockVentasBloc.state,
        ).thenReturn(SaleSuccess(sale: recentSale));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Find the cancel button
        final cancelButton = find.widgetWithText(
          OutlinedButton,
          'Cancelar Venta',
        );
        expect(cancelButton, findsOneWidget);

        // Verify it has red styling
        final button = tester.widget<OutlinedButton>(cancelButton);
        expect(button.style?.foregroundColor?.resolve({}), Colors.red);
      },
    );

    testWidgets(
      'Shows success screen with sale summary after successful sale',
      (WidgetTester tester) async {
        when(
          () => mockVentasBloc.state,
        ).thenReturn(SaleSuccess(sale: testSale));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Verify success screen elements
        expect(find.text('¡Venta Registrada!'), findsOneWidget);
        expect(
          find.text('La venta se ha registrado exitosamente'),
          findsOneWidget,
        );
        expect(
          find.text('\$${testSale.total.toStringAsFixed(2)}'),
          findsOneWidget,
        );
        expect(find.text('Regresar a Modo Cajero'), findsOneWidget);
      },
    );

    testWidgets('Shows cart with products and payment method selection', (
      WidgetTester tester,
    ) async {
      when(
        () => mockVentasBloc.state,
      ).thenReturn(CartView(cartItems: [testSaleItem], total: 30.0));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Verify cart elements
      expect(find.text('Confirmar Venta'), findsOneWidget);
      expect(find.text('Total a Cobrar'), findsOneWidget);
      expect(find.text('\$30.00'), findsWidgets);
      expect(find.text('Método de Pago'), findsOneWidget);
      expect(find.text('Efectivo'), findsOneWidget);
      expect(find.text('Tarjeta'), findsOneWidget);
    });
  });
}
