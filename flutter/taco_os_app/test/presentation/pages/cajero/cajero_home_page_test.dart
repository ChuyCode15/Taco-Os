import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/domain/entities/cash_session.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_state.dart';
import 'package:taco_os_app/presentation/blocs/cajero/sync_status_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/sync_status_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/sync_status_state.dart';
import 'package:taco_os_app/presentation/pages/cajero/cajero_home_page.dart';

// Mock classes
class MockCajeroBloc extends Mock implements CajeroBloc {}

class MockSyncStatusBloc extends Mock implements SyncStatusBloc {}

// Fake events for Mocktail
class FakeCheckSyncStatus extends Fake implements CheckSyncStatus {}

void main() {
  late MockCajeroBloc mockCajeroBloc;
  late MockSyncStatusBloc mockSyncStatusBloc;

  setUpAll(() {
    registerFallbackValue(FakeCheckSyncStatus());
  });

  setUp(() {
    mockCajeroBloc = MockCajeroBloc();
    mockSyncStatusBloc = MockSyncStatusBloc();

    // Default state setup
    final testSession = CashSession(
      id: 'test-session-id',
      businessId: 'test-business-id',
      userId: 'test-user-id',
      initialCash: 500.0,
      status: SessionStatus.open,
      openedAt: DateTime(2025, 1, 1, 9, 0),
    );

    when(
      () => mockCajeroBloc.state,
    ).thenReturn(TurnoActivo(session: testSession));
    when(() => mockCajeroBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockSyncStatusBloc.state).thenReturn(const SyncSynced());
    when(
      () => mockSyncStatusBloc.stream,
    ).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<CajeroBloc>.value(value: mockCajeroBloc),
          BlocProvider<SyncStatusBloc>.value(value: mockSyncStatusBloc),
        ],
        child: const CajeroHomePage(),
      ),
    );
  }

  group('CajeroHomePage - Requirement 4.1 (3 botones fijos)', () {
    testWidgets('renders exactly 3 footer buttons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify page title
      expect(find.text('Modo Cajero'), findsOneWidget);

      // Verify exactly 3 footer buttons exist - Requirement 4.1
      expect(find.text('Ventas'), findsOneWidget);
      expect(find.text('Gastos'), findsOneWidget);
      expect(find.text('¿Cómo voy?'), findsOneWidget);

      // Verify button icons
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });

    testWidgets('buttons are in the footer', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify bottomNavigationBar exists
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNotNull);

      // Verify all 3 buttons exist in the widget tree
      expect(find.text('Ventas'), findsOneWidget);
      expect(find.text('Gastos'), findsOneWidget);
      expect(find.text('¿Cómo voy?'), findsOneWidget);
    });

    testWidgets('renders full screen without secondary navigation', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify no drawer/hamburger menu - Requirement 4.2
      expect(find.byType(Drawer), findsNothing);

      // Verify AppBar is simple without navigation drawer
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.leading, isNull);

      // Verify main content exists
      expect(find.text('¡Bienvenido!'), findsOneWidget);
      expect(find.text('Selecciona una opción para continuar'), findsOneWidget);
    });
  });

  group('CajeroHomePage - Requirement 4.3, 4.4, 4.5 (navegación de botones)', () {
    testWidgets('Ventas button is tappable (Requirement 4.3)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the Ventas button by text
      final ventasButton = find.widgetWithText(ElevatedButton, 'Ventas');
      expect(ventasButton, findsOneWidget);

      // Verify button is enabled
      final button = tester.widget<ElevatedButton>(ventasButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Gastos button is tappable (Requirement 4.4)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the Gastos button
      final gastosButton = find.widgetWithText(ElevatedButton, 'Gastos');
      expect(gastosButton, findsOneWidget);

      // Verify button is enabled (dialog test should be in ExpenseDialog's own tests)
      final button = tester.widget<ElevatedButton>(gastosButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('¿Cómo voy? button is tappable (Requirement 4.5)', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the ¿Cómo voy? button
      final comoVoyButton = find.widgetWithText(ElevatedButton, '¿Cómo voy?');
      expect(comoVoyButton, findsOneWidget);

      // Verify button is enabled
      final button = tester.widget<ElevatedButton>(comoVoyButton);
      expect(button.onPressed, isNotNull);
    });
  });

  group('CajeroHomePage - Requirement 10.10 (SyncStatusBloc indicator)', () {
    testWidgets('shows sync indicator in header', (tester) async {
      when(() => mockSyncStatusBloc.state).thenReturn(const SyncSynced());

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify sync indicator is present in the AppBar actions
      expect(find.byType(AppBar), findsOneWidget);

      // Verify sync status text is shown
      expect(find.text('Sincronizado'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows "Sincronizado" when state is SyncSynced', (
      tester,
    ) async {
      when(() => mockSyncStatusBloc.state).thenReturn(const SyncSynced());

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify "Sincronizado" text and green check icon
      expect(find.text('Sincronizado'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Verify icon color is green
      final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(icon.color, Colors.green);
    });

    testWidgets('shows "Pendiente" with count when state is SyncPending', (
      tester,
    ) async {
      when(
        () => mockSyncStatusBloc.state,
      ).thenReturn(const SyncPending(pendingCount: 5));

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify "Pendiente" text with count and sync icon
      expect(find.text('Pendiente'), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);

      // Verify icon color is orange
      final icon = tester.widget<Icon>(find.byIcon(Icons.sync));
      expect(icon.color, Colors.orange);

      // Verify tooltip shows count
      final tooltip = find.byTooltip('Pendiente (5)');
      expect(tooltip, findsOneWidget);
    });

    testWidgets('shows "Sin" when state is SyncOffline', (tester) async {
      when(() => mockSyncStatusBloc.state).thenReturn(const SyncOffline());

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify "Sin" text (first word of "Sin conexión") and cloud_off icon
      expect(find.text('Sin'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);

      // Verify icon color is red
      final icon = tester.widget<Icon>(find.byIcon(Icons.cloud_off));
      expect(icon.color, Colors.red);

      // Verify tooltip shows full text
      final tooltip = find.byTooltip('Sin conexión');
      expect(tooltip, findsOneWidget);
    });

    testWidgets('dispatches CheckSyncStatus on init with active session', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify CheckSyncStatus event was dispatched with session ID
      verify(
        () => mockSyncStatusBloc.add(
          const CheckSyncStatus(sessionId: 'test-session-id'),
        ),
      ).called(1);
    });

    testWidgets('sync indicator updates when state changes', (tester) async {
      // Start with SyncSynced
      when(() => mockSyncStatusBloc.state).thenReturn(const SyncSynced());
      when(
        () => mockSyncStatusBloc.stream,
      ).thenAnswer((_) => Stream.value(const SyncPending(pendingCount: 3)));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Verify state changed to Pendiente
      expect(find.text('Pendiente'), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });
  });

  group('CajeroHomePage - UI Elements', () {
    testWidgets('renders welcome message and icon', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify welcome message
      expect(find.text('¡Bienvenido!'), findsOneWidget);
      expect(find.text('Selecciona una opción para continuar'), findsOneWidget);

      // Verify decorative icon
      expect(find.byIcon(Icons.point_of_sale), findsOneWidget);
    });

    testWidgets('buttons have correct colors', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find all ElevatedButtons
      final ventasButton = find.ancestor(
        of: find.text('Ventas'),
        matching: find.byType(ElevatedButton),
      );
      final gastosButton = find.ancestor(
        of: find.text('Gastos'),
        matching: find.byType(ElevatedButton),
      );
      final comoVoyButton = find.ancestor(
        of: find.text('¿Cómo voy?'),
        matching: find.byType(ElevatedButton),
      );

      // Verify buttons exist
      expect(ventasButton, findsOneWidget);
      expect(gastosButton, findsOneWidget);
      expect(comoVoyButton, findsOneWidget);

      // Get button widgets
      final ventasWidget = tester.widget<ElevatedButton>(ventasButton);
      final gastosWidget = tester.widget<ElevatedButton>(gastosButton);
      final comoVoyWidget = tester.widget<ElevatedButton>(comoVoyButton);

      // Verify colors
      expect(ventasWidget.style?.backgroundColor?.resolve({}), Colors.green);
      expect(gastosWidget.style?.backgroundColor?.resolve({}), Colors.orange);
      expect(comoVoyWidget.style?.backgroundColor?.resolve({}), Colors.blue);
    });

    testWidgets('buttons have proper styling with icons and text', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify each button contains both icon and text
      // Ventas button
      final ventasButton = find.ancestor(
        of: find.text('Ventas'),
        matching: find.byType(ElevatedButton),
      );
      expect(
        find.descendant(
          of: ventasButton,
          matching: find.byIcon(Icons.shopping_cart),
        ),
        findsOneWidget,
      );

      // Gastos button
      final gastosButton = find.ancestor(
        of: find.text('Gastos'),
        matching: find.byType(ElevatedButton),
      );
      expect(
        find.descendant(
          of: gastosButton,
          matching: find.byIcon(Icons.receipt_long),
        ),
        findsOneWidget,
      );

      // ¿Cómo voy? button
      final comoVoyButton = find.ancestor(
        of: find.text('¿Cómo voy?'),
        matching: find.byType(ElevatedButton),
      );
      expect(
        find.descendant(
          of: comoVoyButton,
          matching: find.byIcon(Icons.analytics),
        ),
        findsOneWidget,
      );
    });
  });

  group('CajeroHomePage - Edge Cases', () {
    testWidgets('handles CajeroInitial state gracefully', (tester) async {
      when(() => mockCajeroBloc.state).thenReturn(const CajeroInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      // Page should still render but CheckSyncStatus should not be called
      // since there's no active session
      expect(find.text('Modo Cajero'), findsOneWidget);
      expect(find.text('Ventas'), findsOneWidget);

      // Verify CheckSyncStatus was not dispatched without session
      verifyNever(() => mockSyncStatusBloc.add(any()));
    });

    testWidgets('footer buttons are evenly spaced', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify Row with mainAxisAlignment.spaceEvenly exists
      final footerRow = find.byType(Row).last;
      expect(footerRow, findsOneWidget);

      final rowWidget = tester.widget<Row>(footerRow);
      expect(rowWidget.mainAxisAlignment, MainAxisAlignment.spaceEvenly);
    });

    testWidgets('buttons are wrapped in Expanded widgets', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify all 3 buttons are in Expanded widgets for equal width
      final expandedWidgets = find.byType(Expanded);
      expect(expandedWidgets, findsNWidgets(3));
    });

    testWidgets('footer has shadow decoration', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the footer container
      final containers = find.byType(Container);
      expect(containers, findsWidgets);

      // The footer container should have a BoxDecoration with shadow
      bool foundFooterWithShadow = false;
      for (final container in tester.widgetList<Container>(containers)) {
        final decoration = container.decoration;
        if (decoration is BoxDecoration && decoration.boxShadow != null) {
          foundFooterWithShadow = true;
          break;
        }
      }
      expect(foundFooterWithShadow, isTrue);
    });
  });

  group('CajeroHomePage - Requirement 4.6 (performance)', () {
    testWidgets('page renders quickly after opening', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(createWidgetUnderTest());

      stopwatch.stop();

      // Verify page renders in less than 300ms - Requirement 4.6
      // Note: In tests, rendering is instant, but this validates structure
      expect(find.byType(CajeroHomePage), findsOneWidget);
      expect(find.text('Modo Cajero'), findsOneWidget);
      expect(stopwatch.elapsedMilliseconds, lessThan(300));
    });
  });
}
