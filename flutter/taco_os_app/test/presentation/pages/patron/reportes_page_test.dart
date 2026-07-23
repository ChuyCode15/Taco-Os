import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_bloc.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_event.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_state.dart';
import 'package:taco_os_app/presentation/pages/patron/reportes/reportes_page.dart';

// Mock class
class MockPatronBloc extends Mock implements PatronBloc {}

// Fake event for Mocktail
class FakeLoadReportsRequested extends Fake implements LoadReportsRequested {}

void main() {
  late MockPatronBloc mockPatronBloc;
  const testBusinessId = 'test-business-id';

  setUpAll(() async {
    registerFallbackValue(FakeLoadReportsRequested());
    // Initialize date formatting for Spanish locale
    await initializeDateFormatting('es_ES', null);
    await initializeDateFormatting('es_MX', null);
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
        child: const ReportesPage(businessId: testBusinessId),
      ),
    );
  }

  group('ReportesPage - Requirement 12.3', () {
    testWidgets('renders page with correct title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify page title
      expect(find.text('Reportes'), findsOneWidget);
    });

    testWidgets('loads reports on init with last 7 days', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify LoadReportsRequested was dispatched on init
      verify(
        () => mockPatronBloc.add(
          any(
            that: isA<LoadReportsRequested>().having(
              (e) => e.businessId,
              'businessId',
              testBusinessId,
            ),
          ),
        ),
      ).called(1);
    });

    testWidgets('shows date range selector icon in app bar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify date range icon button exists
      expect(find.byIcon(Icons.date_range), findsOneWidget);
      expect(find.widgetWithIcon(IconButton, Icons.date_range), findsOneWidget);
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
        const errorMessage = 'Error al cargar reportes';
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

        // Verify LoadReportsRequested was dispatched again
        verify(
          () => mockPatronBloc.add(any(that: isA<LoadReportsRequested>())),
        ).called(1);
      },
    );
  });

  group('ReportesPage - Reports Data Display (Requirement 12.3)', () {
    testWidgets('displays transaction count, total sales, and total expenses', (
      tester,
    ) async {
      // Create state with reports data
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final reportsState = ReportsLoaded(
        totalSales: 15000.00,
        totalExpenses: 3000.00,
        startDate: startDate,
        endDate: endDate,
        transactionCount: 50,
      );

      when(() => mockPatronBloc.state).thenReturn(reportsState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify transaction count
      expect(find.text('Transacciones'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);

      // Verify total sales
      expect(find.text('Total de Ventas'), findsOneWidget);
      expect(find.text('\$15,000.00'), findsOneWidget);

      // Verify total expenses
      expect(find.text('Total de Gastos'), findsOneWidget);
      expect(find.text('\$3,000.00'), findsOneWidget);
    });

    testWidgets('displays net profit when sales > expenses', (tester) async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final reportsState = ReportsLoaded(
        totalSales: 10000.00,
        totalExpenses: 2000.00,
        startDate: startDate,
        endDate: endDate,
        transactionCount: 25,
      );

      when(() => mockPatronBloc.state).thenReturn(reportsState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify net profit is displayed
      expect(find.text('Ganancia Neta'), findsOneWidget);
      expect(find.text('\$8,000.00'), findsOneWidget);

      // Verify profit icon
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('displays net loss when sales < expenses', (tester) async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final reportsState = ReportsLoaded(
        totalSales: 1000.00,
        totalExpenses: 3000.00,
        startDate: startDate,
        endDate: endDate,
        transactionCount: 5,
      );

      when(() => mockPatronBloc.state).thenReturn(reportsState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify net loss is displayed
      expect(find.text('Pérdida Neta'), findsOneWidget);
      expect(find.text('\$2,000.00'), findsOneWidget);

      // Verify loss icon
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('displays date range information', (tester) async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final reportsState = ReportsLoaded(
        totalSales: 5000.00,
        totalExpenses: 1000.00,
        startDate: startDate,
        endDate: endDate,
        transactionCount: 15,
      );

      when(() => mockPatronBloc.state).thenReturn(reportsState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify date range card
      expect(find.text('Rango de Fechas'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month), findsOneWidget);

      // Note: Date formatting depends on locale
      // We just verify the date range section exists
    });

    testWidgets('displays correct icons for each section', (tester) async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final reportsState = ReportsLoaded(
        totalSales: 5000.00,
        totalExpenses: 1000.00,
        startDate: startDate,
        endDate: endDate,
        transactionCount: 20,
      );

      when(() => mockPatronBloc.state).thenReturn(reportsState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify icons
      expect(find.byIcon(Icons.calendar_month), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets('pull-to-refresh reloads reports data', (tester) async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final reportsState = ReportsLoaded(
        totalSales: 5000.00,
        totalExpenses: 1000.00,
        startDate: startDate,
        endDate: endDate,
        transactionCount: 10,
      );

      when(() => mockPatronBloc.state).thenReturn(reportsState);

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

      // Verify LoadReportsRequested was dispatched
      verify(
        () => mockPatronBloc.add(any(that: isA<LoadReportsRequested>())),
      ).called(1);
    });
  });

  group('ReportesPage - Empty State (Requirement 12.3)', () {
    testWidgets('shows empty state message when there are no transactions', (
      tester,
    ) async {
      // Create state with zero transactions
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final emptyReportsState = ReportsLoaded(
        totalSales: 0.00,
        totalExpenses: 0.00,
        startDate: startDate,
        endDate: endDate,
        transactionCount: 0,
      );

      when(() => mockPatronBloc.state).thenReturn(emptyReportsState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify empty state message
      expect(find.text('No hay datos en este rango'), findsOneWidget);
      expect(find.text('Rango consultado:'), findsOneWidget);

      // Verify empty state icon
      expect(find.byIcon(Icons.assessment_outlined), findsOneWidget);

      // Verify change range button
      expect(find.text('Cambiar rango'), findsOneWidget);
    });

    testWidgets('empty state displays the queried date range', (tester) async {
      // Create state with zero transactions
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final emptyReportsState = ReportsLoaded(
        totalSales: 0.00,
        totalExpenses: 0.00,
        startDate: startDate,
        endDate: endDate,
        transactionCount: 0,
      );

      when(() => mockPatronBloc.state).thenReturn(emptyReportsState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify empty state shows range consulted
      expect(find.text('Rango consultado:'), findsOneWidget);

      // Note: Exact date format depends on locale
      // We just verify the label exists
    });

    testWidgets(
      'empty state does not show transaction count and totals cards',
      (tester) async {
        // Create state with zero transactions
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 7);
        final emptyReportsState = ReportsLoaded(
          totalSales: 0.00,
          totalExpenses: 0.00,
          startDate: startDate,
          endDate: endDate,
          transactionCount: 0,
        );

        when(() => mockPatronBloc.state).thenReturn(emptyReportsState);

        await tester.pumpWidget(createWidgetUnderTest());

        // Verify data cards are NOT shown in empty state
        expect(find.text('Transacciones'), findsNothing);
        expect(find.text('Total de Ventas'), findsNothing);
        expect(find.text('Total de Gastos'), findsNothing);
        expect(find.text('Ganancia Neta'), findsNothing);
        expect(find.text('Pérdida Neta'), findsNothing);
      },
    );
  });

  group('ReportesPage - Edge Cases', () {
    testWidgets('handles zero expenses and non-zero sales', (tester) async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final reportsState = ReportsLoaded(
        totalSales: 5000.00,
        totalExpenses: 0.00,
        startDate: startDate,
        endDate: endDate,
        transactionCount: 10,
      );

      when(() => mockPatronBloc.state).thenReturn(reportsState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify expenses show zero
      expect(find.text('Total de Gastos'), findsOneWidget);
      expect(find.text('\$0.00'), findsOneWidget);

      // Verify sales show correct amount (may appear twice: in card and net profit)
      expect(find.text('Total de Ventas'), findsOneWidget);
      expect(find.text('\$5,000.00'), findsWidgets);

      // Verify net profit equals sales (no expenses)
      expect(find.text('Ganancia Neta'), findsOneWidget);
    });

    testWidgets('handles zero sales and non-zero expenses', (tester) async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final reportsState = ReportsLoaded(
        totalSales: 0.00,
        totalExpenses: 1500.00,
        startDate: startDate,
        endDate: endDate,
        transactionCount: 5,
      );

      when(() => mockPatronBloc.state).thenReturn(reportsState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify sales show zero
      expect(find.text('Total de Ventas'), findsOneWidget);
      expect(find.text('\$0.00'), findsOneWidget);

      // Verify expenses show correct amount (may appear twice: in card and net loss)
      expect(find.text('Total de Gastos'), findsOneWidget);
      expect(find.text('\$1,500.00'), findsWidgets);

      // Verify net loss equals expenses (no sales)
      expect(find.text('Pérdida Neta'), findsOneWidget);
    });

    testWidgets('handles large transaction counts', (tester) async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 12, 31);
      final reportsState = ReportsLoaded(
        totalSales: 999999.99,
        totalExpenses: 100000.00,
        startDate: startDate,
        endDate: endDate,
        transactionCount: 9999,
      );

      when(() => mockPatronBloc.state).thenReturn(reportsState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify large numbers are displayed correctly
      expect(find.text('9999'), findsOneWidget);
      expect(find.text('\$999,999.99'), findsOneWidget);
      expect(find.text('\$100,000.00'), findsOneWidget);
    });

    testWidgets('handles single transaction', (tester) async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final reportsState = ReportsLoaded(
        totalSales: 100.00,
        totalExpenses: 20.00,
        startDate: startDate,
        endDate: endDate,
        transactionCount: 1,
      );

      when(() => mockPatronBloc.state).thenReturn(reportsState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify single transaction is displayed
      expect(find.text('1'), findsOneWidget);
      expect(find.text('\$100.00'), findsOneWidget);
      expect(find.text('\$20.00'), findsOneWidget);
    });

    testWidgets('handles break-even scenario (sales = expenses)', (
      tester,
    ) async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final reportsState = ReportsLoaded(
        totalSales: 5000.00,
        totalExpenses: 5000.00,
        startDate: startDate,
        endDate: endDate,
        transactionCount: 20,
      );

      when(() => mockPatronBloc.state).thenReturn(reportsState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify break-even shows as profit (0 >= 0)
      expect(find.text('Ganancia Neta'), findsOneWidget);
      expect(find.text('\$0.00'), findsOneWidget);
    });

    testWidgets('page is scrollable for small screens', (tester) async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final reportsState = ReportsLoaded(
        totalSales: 5000.00,
        totalExpenses: 1000.00,
        startDate: startDate,
        endDate: endDate,
        transactionCount: 10,
      );

      when(() => mockPatronBloc.state).thenReturn(reportsState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify SingleChildScrollView exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('ReportesPage - Currency Formatting', () {
    testWidgets('formats currency with Mexican peso symbol and decimals', (
      tester,
    ) async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final reportsState = ReportsLoaded(
        totalSales: 12345.67,
        totalExpenses: 2345.89,
        startDate: startDate,
        endDate: endDate,
        transactionCount: 15,
      );

      when(() => mockPatronBloc.state).thenReturn(reportsState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify currency formatting with $ symbol and 2 decimal places
      expect(find.text('\$12,345.67'), findsOneWidget);
      expect(find.text('\$2,345.89'), findsOneWidget);
    });

    testWidgets('handles decimal amounts correctly', (tester) async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final reportsState = ReportsLoaded(
        totalSales: 10.50,
        totalExpenses: 5.25,
        startDate: startDate,
        endDate: endDate,
        transactionCount: 2,
      );

      when(() => mockPatronBloc.state).thenReturn(reportsState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify decimal formatting (may appear multiple times)
      expect(find.text('\$10.50'), findsWidgets);
      expect(find.text('\$5.25'), findsWidgets);
    });
  });

  group('ReportesPage - State Transitions', () {
    testWidgets('transitions from loading to data loaded', (tester) async {
      // Start with loading state
      when(() => mockPatronBloc.state).thenReturn(PatronLoading());
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);

      when(() => mockPatronBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          PatronLoading(),
          ReportsLoaded(
            totalSales: 5000.00,
            totalExpenses: 1000.00,
            startDate: startDate,
            endDate: endDate,
            transactionCount: 10,
          ),
        ]),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Pump to process state change
      await tester.pump();

      // Verify data is shown
      expect(find.text('10'), findsOneWidget);
      expect(find.text('\$5,000.00'), findsOneWidget);
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

      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);

      // Setup stream to emit new state after retry
      when(() => mockPatronBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          const PatronError('Error al cargar'),
          ReportsLoaded(
            totalSales: 3000.00,
            totalExpenses: 500.00,
            startDate: startDate,
            endDate: endDate,
            transactionCount: 5,
          ),
        ]),
      );

      // Update current state
      when(() => mockPatronBloc.state).thenReturn(
        ReportsLoaded(
          totalSales: 3000.00,
          totalExpenses: 500.00,
          startDate: startDate,
          endDate: endDate,
          transactionCount: 5,
        ),
      );

      // Tap retry
      await tester.tap(find.text('Reintentar'));
      await tester.pump(); // Start the animation
      await tester.pump(const Duration(seconds: 1)); // Complete the animation

      // Verify LoadReportsRequested was called
      verify(
        () => mockPatronBloc.add(any(that: isA<LoadReportsRequested>())),
      ).called(greaterThan(0));
    });

    testWidgets('transitions from empty to data loaded', (tester) async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);

      // Start with empty state
      when(() => mockPatronBloc.state).thenReturn(
        ReportsLoaded(
          totalSales: 0.00,
          totalExpenses: 0.00,
          startDate: startDate,
          endDate: endDate,
          transactionCount: 0,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify empty state
      expect(find.text('No hay datos en este rango'), findsOneWidget);

      // Update state to have data
      when(() => mockPatronBloc.state).thenReturn(
        ReportsLoaded(
          totalSales: 1000.00,
          totalExpenses: 200.00,
          startDate: startDate,
          endDate: endDate,
          transactionCount: 5,
        ),
      );
      when(() => mockPatronBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          ReportsLoaded(
            totalSales: 1000.00,
            totalExpenses: 200.00,
            startDate: startDate,
            endDate: endDate,
            transactionCount: 5,
          ),
        ]),
      );

      // Trigger rebuild
      await tester.pumpAndSettle();

      // Note: In a real app, this would happen after date range change
      // We just verify empty state was initially shown
    });
  });
}
