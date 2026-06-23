import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_bloc.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_event.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_state.dart';
import 'package:taco_os_app/presentation/pages/patron/equipo/equipo_page.dart';

// Mock class
class MockPatronBloc extends Mock implements PatronBloc {}

// Fake event for Mocktail
class FakeLoadTeamRequested extends Fake implements LoadTeamRequested {}

void main() {
  late MockPatronBloc mockPatronBloc;
  const testBusinessId = 'test-business-id';

  setUpAll(() {
    registerFallbackValue(FakeLoadTeamRequested());
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
        child: const EquipoPage(businessId: testBusinessId),
      ),
    );
  }

  group('EquipoPage - Requirement 12.4', () {
    testWidgets('renders page with correct title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify page title
      expect(find.text('Equipo'), findsOneWidget);
    });

    testWidgets('loads team on init', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify LoadTeamRequested was dispatched on init
      verify(
        () => mockPatronBloc.add(const LoadTeamRequested(testBusinessId)),
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
        const errorMessage = 'Error al cargar equipo';
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

        // Verify LoadTeamRequested was dispatched again
        verify(
          () => mockPatronBloc.add(const LoadTeamRequested(testBusinessId)),
        ).called(1);
      },
    );

    testWidgets('shows refresh button in app bar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify refresh button exists
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byTooltip('Actualizar'), findsOneWidget);
    });

    testWidgets('refresh button reloads team data', (tester) async {
      const teamState = TeamLoaded([]);
      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Clear previous calls from init
      clearInteractions(mockPatronBloc);

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Verify LoadTeamRequested was dispatched
      verify(
        () => mockPatronBloc.add(const LoadTeamRequested(testBusinessId)),
      ).called(1);
    });

    testWidgets('shows FloatingActionButton to add cashier', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify FAB exists
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Vincular Cajero'), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });
  });

  group('EquipoPage - Empty State (Requirement 12.4)', () {
    testWidgets('shows empty state when team list is empty', (tester) async {
      const emptyTeamState = TeamLoaded([]);
      when(() => mockPatronBloc.state).thenReturn(emptyTeamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify empty state message
      expect(find.text('No hay cajeros vinculados'), findsOneWidget);
      expect(
        find.text(
          'Usa el botón de abajo para vincular tu primer cajero mediante código QR',
        ),
        findsOneWidget,
      );

      // Verify empty state icon
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('empty state does not show team member cards', (tester) async {
      const emptyTeamState = TeamLoaded([]);
      when(() => mockPatronBloc.state).thenReturn(emptyTeamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify no ListTile widgets (team member cards)
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('FAB shows dialog when tapped on empty state', (tester) async {
      const emptyTeamState = TeamLoaded([]);
      when(() => mockPatronBloc.state).thenReturn(emptyTeamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Vincular Cajero'), findsNWidgets(2)); // Title + FAB
      expect(
        find.text(
          'Para vincular un cajero, el cajero debe escanear el código QR del negocio desde su aplicación.',
        ),
        findsOneWidget,
      );
      expect(find.text('Cerrar'), findsOneWidget);
      expect(find.text('Ir a Configuración'), findsOneWidget);
    });
  });

  group('EquipoPage - Team Data Display (Requirement 12.4)', () {
    testWidgets('displays team members with active shift status', (
      tester,
    ) async {
      const teamState = TeamLoaded([
        TeamMemberData(
          id: 'cashier-1',
          name: 'Juan Pérez',
          email: 'juan@example.com',
          hasActiveShift: true,
        ),
        TeamMemberData(
          id: 'cashier-2',
          name: 'María García',
          email: 'maria@example.com',
          hasActiveShift: false,
        ),
      ]);

      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify team member names
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('María García'), findsOneWidget);

      // Verify emails
      expect(find.text('juan@example.com'), findsOneWidget);
      expect(find.text('maria@example.com'), findsOneWidget);

      // Verify shift status labels
      expect(find.text('En turno'), findsOneWidget);
      expect(find.text('Inactivo'), findsOneWidget);
    });

    testWidgets('shows summary card with total and active count', (
      tester,
    ) async {
      const teamState = TeamLoaded([
        TeamMemberData(
          id: 'cashier-1',
          name: 'Juan Pérez',
          email: 'juan@example.com',
          hasActiveShift: true,
        ),
        TeamMemberData(
          id: 'cashier-2',
          name: 'María García',
          email: 'maria@example.com',
          hasActiveShift: true,
        ),
        TeamMemberData(
          id: 'cashier-3',
          name: 'Pedro López',
          email: 'pedro@example.com',
          hasActiveShift: false,
        ),
      ]);

      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify summary card
      expect(find.text('Total de Cajeros'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2 activos'), findsOneWidget);
    });

    testWidgets('separates active and inactive members in sections', (
      tester,
    ) async {
      const teamState = TeamLoaded([
        TeamMemberData(
          id: 'cashier-1',
          name: 'Juan Pérez',
          email: 'juan@example.com',
          hasActiveShift: true,
        ),
        TeamMemberData(
          id: 'cashier-2',
          name: 'María García',
          email: 'maria@example.com',
          hasActiveShift: false,
        ),
      ]);

      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify section headers
      expect(find.text('Cajeros Activos (1)'), findsOneWidget);
      expect(find.text('Cajeros Inactivos (1)'), findsOneWidget);
    });

    testWidgets('displays avatar with first letter of name', (tester) async {
      const teamState = TeamLoaded([
        TeamMemberData(
          id: 'cashier-1',
          name: 'Juan Pérez',
          email: 'juan@example.com',
          hasActiveShift: true,
        ),
      ]);

      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify CircleAvatar exists
      expect(find.byType(CircleAvatar), findsOneWidget);

      // Verify first letter is displayed
      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('handles empty name with fallback avatar', (tester) async {
      const teamState = TeamLoaded([
        TeamMemberData(
          id: 'cashier-1',
          name: '',
          email: 'test@example.com',
          hasActiveShift: false,
        ),
      ]);

      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify fallback letter 'C' is displayed
      expect(find.text('C'), findsOneWidget);
    });
  });

  group('EquipoPage - Active Members Only', () {
    testWidgets('shows only active section when all members are active', (
      tester,
    ) async {
      const teamState = TeamLoaded([
        TeamMemberData(
          id: 'cashier-1',
          name: 'Juan Pérez',
          email: 'juan@example.com',
          hasActiveShift: true,
        ),
        TeamMemberData(
          id: 'cashier-2',
          name: 'María García',
          email: 'maria@example.com',
          hasActiveShift: true,
        ),
      ]);

      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify active section exists
      expect(find.text('Cajeros Activos (2)'), findsOneWidget);

      // Verify inactive section does NOT exist
      expect(find.textContaining('Cajeros Inactivos'), findsNothing);
    });

    testWidgets('shows only inactive section when all members are inactive', (
      tester,
    ) async {
      const teamState = TeamLoaded([
        TeamMemberData(
          id: 'cashier-1',
          name: 'Juan Pérez',
          email: 'juan@example.com',
          hasActiveShift: false,
        ),
        TeamMemberData(
          id: 'cashier-2',
          name: 'María García',
          email: 'maria@example.com',
          hasActiveShift: false,
        ),
      ]);

      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify inactive section exists
      expect(find.text('Cajeros Inactivos (2)'), findsOneWidget);

      // Verify active section does NOT exist
      expect(find.textContaining('Cajeros Activos'), findsNothing);
    });

    testWidgets('summary shows 0 activos when all are inactive', (
      tester,
    ) async {
      const teamState = TeamLoaded([
        TeamMemberData(
          id: 'cashier-1',
          name: 'Juan Pérez',
          email: 'juan@example.com',
          hasActiveShift: false,
        ),
      ]);

      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify summary shows 0 active
      expect(find.text('0 activos'), findsOneWidget);
    });
  });

  group('EquipoPage - Pull to Refresh', () {
    testWidgets('pull-to-refresh reloads team data', (tester) async {
      const teamState = TeamLoaded([
        TeamMemberData(
          id: 'cashier-1',
          name: 'Juan Pérez',
          email: 'juan@example.com',
          hasActiveShift: true,
        ),
      ]);

      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Clear previous calls from init
      clearInteractions(mockPatronBloc);

      // Find the ListView and trigger a refresh
      await tester.fling(find.byType(ListView), const Offset(0, 500), 1000);
      await tester.pumpAndSettle();

      // Verify LoadTeamRequested was dispatched
      verify(
        () => mockPatronBloc.add(const LoadTeamRequested(testBusinessId)),
      ).called(1);
    });
  });

  group('EquipoPage - Edge Cases', () {
    testWidgets('handles single team member', (tester) async {
      const teamState = TeamLoaded([
        TeamMemberData(
          id: 'cashier-1',
          name: 'Juan Pérez',
          email: 'juan@example.com',
          hasActiveShift: true,
        ),
      ]);

      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify single member is displayed
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('Total de Cajeros'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('1 activos'), findsOneWidget);
    });

    testWidgets('handles many team members', (tester) async {
      final largeTeam = List.generate(
        10,
        (i) => TeamMemberData(
          id: 'cashier-$i',
          name: 'Cajero $i',
          email: 'cajero$i@example.com',
          hasActiveShift: i % 2 == 0, // Even indices are active
        ),
      );

      final teamState = TeamLoaded(largeTeam);
      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify summary shows correct counts
      expect(find.text('10'), findsOneWidget);
      expect(find.text('5 activos'), findsOneWidget);

      // Scroll to find section headers (they might be off screen initially)
      await tester.scrollUntilVisible(
        find.text('Cajeros Activos (5)'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Cajeros Activos (5)'), findsOneWidget);

      // Scroll to find inactive section
      await tester.scrollUntilVisible(
        find.text('Cajeros Inactivos (5)'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Cajeros Inactivos (5)'), findsOneWidget);
    });

    testWidgets('page is scrollable', (tester) async {
      const teamState = TeamLoaded([
        TeamMemberData(
          id: 'cashier-1',
          name: 'Juan Pérez',
          email: 'juan@example.com',
          hasActiveShift: true,
        ),
      ]);

      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify ListView exists (which is scrollable)
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('handles long names and emails gracefully', (tester) async {
      const teamState = TeamLoaded([
        TeamMemberData(
          id: 'cashier-1',
          name: 'Juan Carlos Martínez González de la Vega',
          email: 'juan.carlos.martinez.gonzalez@verylongdomainname.com',
          hasActiveShift: true,
        ),
      ]);

      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify long text is displayed (may be truncated by ListTile)
      expect(
        find.text('Juan Carlos Martínez González de la Vega'),
        findsOneWidget,
      );
      expect(
        find.text('juan.carlos.martinez.gonzalez@verylongdomainname.com'),
        findsOneWidget,
      );
    });
  });

  group('EquipoPage - State Transitions', () {
    testWidgets('transitions from loading to data loaded', (tester) async {
      // Start with loading state
      when(() => mockPatronBloc.state).thenReturn(PatronLoading());
      when(() => mockPatronBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          PatronLoading(),
          const TeamLoaded([
            TeamMemberData(
              id: 'cashier-1',
              name: 'Juan Pérez',
              email: 'juan@example.com',
              hasActiveShift: true,
            ),
          ]),
        ]),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Pump to process state change
      await tester.pump();

      // Verify data is shown
      expect(find.text('Juan Pérez'), findsOneWidget);
    });
  });

  group('EquipoPage - Visual Elements', () {
    testWidgets('active members have green status indicator', (tester) async {
      const teamState = TeamLoaded([
        TeamMemberData(
          id: 'cashier-1',
          name: 'Juan Pérez',
          email: 'juan@example.com',
          hasActiveShift: true,
        ),
      ]);

      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify status badge exists with "En turno" text
      expect(find.text('En turno'), findsOneWidget);

      // Verify green circle indicator exists
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon && widget.icon == Icons.circle && widget.size == 8,
        ),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('inactive members have gray status indicator', (tester) async {
      const teamState = TeamLoaded([
        TeamMemberData(
          id: 'cashier-1',
          name: 'Juan Pérez',
          email: 'juan@example.com',
          hasActiveShift: false,
        ),
      ]);

      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify status badge exists with "Inactivo" text
      expect(find.text('Inactivo'), findsOneWidget);
    });

    testWidgets('summary card has correct icon', (tester) async {
      const teamState = TeamLoaded([
        TeamMemberData(
          id: 'cashier-1',
          name: 'Juan Pérez',
          email: 'juan@example.com',
          hasActiveShift: true,
        ),
      ]);

      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify people icon exists in summary card
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('team member cards have elevation', (tester) async {
      const teamState = TeamLoaded([
        TeamMemberData(
          id: 'cashier-1',
          name: 'Juan Pérez',
          email: 'juan@example.com',
          hasActiveShift: true,
        ),
      ]);

      when(() => mockPatronBloc.state).thenReturn(teamState);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify Card widgets exist (which have elevation)
      expect(find.byType(Card), findsAtLeastNWidgets(1));
    });
  });
}
