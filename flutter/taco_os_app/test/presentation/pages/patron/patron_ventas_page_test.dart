import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_bloc.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_event.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_state.dart';
import 'package:taco_os_app/presentation/pages/patron/ventas/patron_ventas_page.dart';

// Mock class
class MockPatronBloc extends Mock implements PatronBloc {}

// Fake event for Mocktail
class FakeLoadTodaySalesRequested extends Fake
    implements LoadTodaySalesRequested {}

void main() {
  late MockPatronBloc mockPatronBloc;
  const testBusinessId = 'test-business-id';

  setUpAll(() {
    registerFallbackValue(FakeLoadTodaySalesRequested());
  });

  setUp(() {
    mockPatronBloc = MockPatronBloc();
    when(() => mockPatronBloc.state).thenReturn(PatronInitial());
    when(() => mockPatronBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<PatronBloc>.value(
        value: mockPatronBloc,
        child: const PatronVentasPage(businessId: testBusinessId),
      ),
    );
  }

  group('PatronVentasPage - Requirement 12.2', () {
    testWidgets('renders page with correct title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify page title
      expect(find.text('Ventas del Día'), findsOneWidget);
    });

    testWidgets('loads today\'s sales on init', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify LoadTodaySalesRequested was dispatched on init
      verify(
        () => mockPatronBloc.add(const LoadTodaySalesRequested(testBusinessId)),
      ).called(1);
    });

    testWidgets('shows loading indicator when state is PatronLoading', (
      tester,
    ) async {
      when(() => mockPatronBloc.state).thenReturn(PatronLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'shows error message and retry button when state is PatronError',
      (tester) async {
        const errorMessage = 'Error al cargar ventas';
        when(
          () => mockPatronBloc.state,
        ).thenReturn(const PatronError(errorMessage));

        await tester.pumpWidget(createWidgetUnderTest());

        // Verify error icon and message are shown
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text(errorMessage), findsOneWidget);
        expect(find.text('Reintentar'), findsOneWidget);

        // Clear previous calls
        clearInteractions(mockPatronBloc);

        // Tap retry button
        await tester.tap(find.text('Reintentar'));
        await tester.pumpAndSettle();

        // Verify LoadTodaySalesRequested was dispatched again
        verify(
          () =>
              mockPatronBloc.add(const LoadTodaySalesRequested(testBusinessId)),
        ).called(1);
      },
    );
  });

  group('PatronVentasPage - Sales Data Display (Requirement 12.2)', () {
    testWidgets(
      'displays transaction count, total sales, and payment breakdown',
      (tester) async {
        // Create state with sales data
        const salesState = TodaySalesLoaded(
          transactionCount: 25,
          totalSales: 5000.00,
          cashSales: 3000.00,
          cardSales: 2000.00,
        );

        when(() => mockPatronBloc.state).thenReturn(salesState);

        await tester.pumpWidget(createWidgetUnderTest());

        // Verify transaction count
        expect(find.text('Transacciones'), findsOneWidget);
        expect(find.text('25'), findsOneWidget);

        // Verify total sales
        expect(find.text('Total de Ventas'), findsOneWidget);
        expect(find.text('\$5,000.00'), findsOneWidget);

        // Verify payment breakdown section title
        expect(find.text('Desglose por Método de Pago'), findsOneWidget);

        // Verify cash sales
        expect(find.text('Efectivo'), findsOneWidget);
        expect(find.text('\$3,000.00'), findsOneWidget);

        // Verify card sales
        expect(find.text('Tarjeta'), findsOneWidget);
        expect(find.text('\$2,000.00'), findsOneWidget);
      },
    );

    testWidgets('displays correct icons for each section', (tester) async {
      const salesState = TodaySalesLoaded(
        transactionCount: 10,
        totalSales: 1500.00,
        cashSales: 900.00,
        cardSales: 600.00,
      );

      when(() => mockPatronBloc.state).thenReturn(salesState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify icons
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
      expect(find.byIcon(Icons.money), findsOneWidget);
      expect(find.byIcon(Icons.credit_card), findsOneWidget);
    });

    testWidgets('displays current date', (tester) async {
      const salesState = TodaySalesLoaded(
        transactionCount: 5,
        totalSales: 500.00,
        cashSales: 300.00,
        cardSales: 200.00,
      );

      when(() => mockPatronBloc.state).thenReturn(salesState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify date card icon exists (calendar_today)
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);

      // Note: Actual date formatting depends on locale and DateTime.now()
      // We just verify the date card exists
    });

    testWidgets('pull-to-refresh reloads sales data', (tester) async {
      const salesState = TodaySalesLoaded(
        transactionCount: 10,
        totalSales: 1000.00,
        cashSales: 600.00,
        cardSales: 400.00,
      );

      when(() => mockPatronBloc.state).thenReturn(salesState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Clear previous calls from init
      clearInteractions(mockPatronBloc);

      // Find the RefreshIndicator and trigger a refresh
      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, 500),
        1000,
      );
      await tester.pumpAndSettle();

      // Verify LoadTodaySalesRequested was dispatched
      verify(
        () => mockPatronBloc.add(const LoadTodaySalesRequested(testBusinessId)),
      ).called(1);
    });
  });

  group('PatronVentasPage - Empty State (Requirement 12.2)', () {
    testWidgets('shows empty state message when there are no sales', (
      tester,
    ) async {
      // Create state with zero sales
      const emptySalesState = TodaySalesLoaded(
        transactionCount: 0,
        totalSales: 0.00,
        cashSales: 0.00,
        cardSales: 0.00,
      );

      when(() => mockPatronBloc.state).thenReturn(emptySalesState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify empty state message
      expect(find.text('No hay ventas registradas hoy'), findsOneWidget);
      expect(
        find.text(
          'Las ventas aparecerán aquí cuando los cajeros registren transacciones',
        ),
        findsOneWidget,
      );

      // Verify empty state icon
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('shows zeros in empty state', (tester) async {
      // Create state with zero sales
      const emptySalesState = TodaySalesLoaded(
        transactionCount: 0,
        totalSales: 0.00,
        cashSales: 0.00,
        cardSales: 0.00,
      );

      when(() => mockPatronBloc.state).thenReturn(emptySalesState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify zeros are displayed
      expect(find.text('0'), findsOneWidget);
      expect(find.text('\$0.00'), findsOneWidget);

      // Verify empty state still shows transaction and sales cards
      expect(find.text('Transacciones'), findsOneWidget);
      expect(find.text('Total de Ventas'), findsOneWidget);
    });

    testWidgets('empty state does not show payment breakdown', (tester) async {
      // Create state with zero sales
      const emptySalesState = TodaySalesLoaded(
        transactionCount: 0,
        totalSales: 0.00,
        cashSales: 0.00,
        cardSales: 0.00,
      );

      when(() => mockPatronBloc.state).thenReturn(emptySalesState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify payment breakdown section is NOT shown
      expect(find.text('Desglose por Método de Pago'), findsNothing);
      expect(find.text('Efectivo'), findsNothing);
      expect(find.text('Tarjeta'), findsNothing);
    });
  });

  group('PatronVentasPage - Edge Cases', () {
    testWidgets('handles zero cash sales and non-zero card sales', (
      tester,
    ) async {
      const salesState = TodaySalesLoaded(
        transactionCount: 5,
        totalSales: 1000.00,
        cashSales: 0.00,
        cardSales: 1000.00,
      );

      when(() => mockPatronBloc.state).thenReturn(salesState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify cash shows zero
      expect(find.text('Efectivo'), findsOneWidget);
      expect(find.text('\$0.00'), findsOneWidget);

      // Verify card shows correct amount
      expect(find.text('Tarjeta'), findsOneWidget);
      expect(find.text('\$1,000.00'), findsOneWidget);
    });

    testWidgets('handles zero card sales and non-zero cash sales', (
      tester,
    ) async {
      const salesState = TodaySalesLoaded(
        transactionCount: 3,
        totalSales: 500.00,
        cashSales: 500.00,
        cardSales: 0.00,
      );

      when(() => mockPatronBloc.state).thenReturn(salesState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify cash shows correct amount
      expect(find.text('Efectivo'), findsOneWidget);
      expect(find.text('\$500.00'), findsOneWidget);

      // Verify card shows zero
      expect(find.text('Tarjeta'), findsOneWidget);
      expect(find.text('\$0.00'), findsOneWidget);
    });

    testWidgets('handles large transaction counts', (tester) async {
      const salesState = TodaySalesLoaded(
        transactionCount: 999,
        totalSales: 99999.99,
        cashSales: 59999.99,
        cardSales: 40000.00,
      );

      when(() => mockPatronBloc.state).thenReturn(salesState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify large numbers are displayed correctly
      expect(find.text('999'), findsOneWidget);
      expect(find.text('\$99,999.99'), findsOneWidget);
      expect(find.text('\$59,999.99'), findsOneWidget);
      expect(find.text('\$40,000.00'), findsOneWidget);
    });

    testWidgets('handles single transaction', (tester) async {
      const salesState = TodaySalesLoaded(
        transactionCount: 1,
        totalSales: 50.00,
        cashSales: 50.00,
        cardSales: 0.00,
      );

      when(() => mockPatronBloc.state).thenReturn(salesState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify single transaction is displayed
      expect(find.text('1'), findsOneWidget);
      expect(find.text('\$50.00'), findsOneWidget);
    });

    testWidgets('page is scrollable for small screens', (tester) async {
      const salesState = TodaySalesLoaded(
        transactionCount: 10,
        totalSales: 1000.00,
        cashSales: 600.00,
        cardSales: 400.00,
      );

      when(() => mockPatronBloc.state).thenReturn(salesState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify SingleChildScrollView exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('PatronVentasPage - Currency Formatting', () {
    testWidgets('formats currency with Mexican peso symbol and decimals', (
      tester,
    ) async {
      const salesState = TodaySalesLoaded(
        transactionCount: 5,
        totalSales: 1234.56,
        cashSales: 789.01,
        cardSales: 445.55,
      );

      when(() => mockPatronBloc.state).thenReturn(salesState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify currency formatting with $ symbol and 2 decimal places
      expect(find.text('\$1,234.56'), findsOneWidget);
      expect(find.text('\$789.01'), findsOneWidget);
      expect(find.text('\$445.55'), findsOneWidget);
    });

    testWidgets('handles decimal amounts correctly', (tester) async {
      const salesState = TodaySalesLoaded(
        transactionCount: 2,
        totalSales: 10.50,
        cashSales: 5.25,
        cardSales: 5.25,
      );

      when(() => mockPatronBloc.state).thenReturn(salesState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify decimal formatting
      expect(find.text('\$10.50'), findsOneWidget);
      expect(find.text('\$5.25'), findsOneWidget);
    });
  });

  group('PatronVentasPage - State Transitions', () {
    testWidgets('transitions from loading to data loaded', (tester) async {
      // Start with loading state
      when(() => mockPatronBloc.state).thenReturn(PatronLoading());
      when(() => mockPatronBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          PatronLoading(),
          const TodaySalesLoaded(
            transactionCount: 5,
            totalSales: 500.00,
            cashSales: 300.00,
            cardSales: 200.00,
          ),
        ]),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Pump to process state change
      await tester.pump();

      // Verify data is shown
      expect(find.text('5'), findsOneWidget);
      expect(find.text('\$500.00'), findsOneWidget);
    });

    testWidgets('transitions from error to data loaded after retry', (
      tester,
    ) async {
      // Start with error state
      when(
        () => mockPatronBloc.state,
      ).thenReturn(const PatronError('Error al cargar'));

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify error is shown
      expect(find.text('Error al cargar'), findsOneWidget);

      // Update state to loaded
      when(() => mockPatronBloc.state).thenReturn(
        const TodaySalesLoaded(
          transactionCount: 3,
          totalSales: 300.00,
          cashSales: 200.00,
          cardSales: 100.00,
        ),
      );
      when(() => mockPatronBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          const TodaySalesLoaded(
            transactionCount: 3,
            totalSales: 300.00,
            cashSales: 200.00,
            cardSales: 100.00,
          ),
        ]),
      );

      // Tap retry
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      // Verify data is shown (error is gone)
      expect(find.text('Error al cargar'), findsNothing);
    });
  });
}
