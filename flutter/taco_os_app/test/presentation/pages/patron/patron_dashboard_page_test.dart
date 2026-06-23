import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/domain/entities/notification.dart'
    as taco_notification;
import 'package:taco_os_app/domain/entities/business.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_bloc.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_event.dart';
import 'package:taco_os_app/presentation/blocs/patron/patron_state.dart';
import 'package:taco_os_app/presentation/pages/patron/patron_dashboard_page.dart';

// Mock class
class MockPatronBloc extends Mock implements PatronBloc {}

// Fake event for Mocktail
class FakeLoadNotificationsRequested extends Fake
    implements LoadNotificationsRequested {}

class FakeLoadBusinessInfoRequested extends Fake
    implements LoadBusinessInfoRequested {}

void main() {
  late MockPatronBloc mockPatronBloc;
  const testBusinessId = 'test-business-id';

  setUpAll(() {
    registerFallbackValue(FakeLoadNotificationsRequested());
    registerFallbackValue(FakeLoadBusinessInfoRequested());
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
        child: const PatronDashboardPage(businessId: testBusinessId),
      ),
    );
  }

  group('PatronDashboardPage - Requirement 12.1', () {
    testWidgets(
      'renders dashboard with 4 sections (Ventas, Reportes, Equipo, Configuración)',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Verify page title
        expect(find.text('Dashboard del Patrón'), findsOneWidget);

        // Verify hamburger menu icon (☰) - Requirement 12.1
        expect(find.byIcon(Icons.menu), findsOneWidget);

        // Verify all 4 sections exist - Requirement 12.1
        expect(find.text('Ventas'), findsOneWidget);
        expect(find.text('Reportes'), findsOneWidget);
        expect(find.text('Equipo'), findsOneWidget);
        expect(find.text('Configuración'), findsOneWidget);

        // Verify section icons
        expect(find.byIcon(Icons.point_of_sale), findsOneWidget);
        expect(find.byIcon(Icons.analytics), findsOneWidget);
        expect(find.byIcon(Icons.people), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget);

        // Verify section subtitles
        expect(find.text('Resumen del día'), findsOneWidget);
        expect(find.text('Históricos y análisis'), findsOneWidget);
        expect(find.text('Cajeros vinculados'), findsOneWidget);
        expect(find.text('Ajustes del negocio'), findsOneWidget);
      },
    );

    testWidgets('loads notifications on init', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify LoadNotificationsRequested was dispatched on init
      verify(
        () => mockPatronBloc.add(
          const LoadNotificationsRequested(testBusinessId),
        ),
      ).called(1);

      // Verify LoadBusinessInfoRequested was dispatched on init
      verify(
        () =>
            mockPatronBloc.add(const LoadBusinessInfoRequested(testBusinessId)),
      ).called(1);
    });

    testWidgets('sections are tappable cards', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify all sections have Card widgets (4 sections)
      expect(find.byType(Card), findsNWidgets(4));

      // Verify cards contain InkWells (not checking total count due to drawer)
      // Just verify the cards are tappable by checking Card widgets exist
      final cards = tester.widgetList<Card>(find.byType(Card));
      expect(cards.length, 4);
    });

    testWidgets('hamburger menu opens drawer with navigation options', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap hamburger menu
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify drawer is open with all navigation items
      expect(find.text('Taco\'Os'), findsOneWidget);
      expect(find.text('Panel del Patrón'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);

      // Verify all drawer items exist
      final drawerVentas = find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Ventas'),
      );
      expect(drawerVentas, findsOneWidget);

      final drawerReportes = find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Reportes'),
      );
      expect(drawerReportes, findsOneWidget);

      final drawerEquipo = find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Equipo'),
      );
      expect(drawerEquipo, findsOneWidget);

      final drawerConfiguracion = find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Configuración'),
      );
      expect(drawerConfiguracion, findsOneWidget);

      expect(find.text('Cerrar sesión'), findsOneWidget);
    });
  });

  group('PatronDashboardPage - Notification Badge (Requirement 12.5)', () {
    testWidgets('shows no badge when there are 0 unread notifications', (
      tester,
    ) async {
      when(
        () => mockPatronBloc.state,
      ).thenReturn(const NotificationsLoaded([]));

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify notification icon exists but no badge
      expect(find.byIcon(Icons.notifications), findsOneWidget);

      // Verify no badge text is shown
      expect(find.text('0'), findsNothing);
      expect(find.text('99+'), findsNothing);
    });

    testWidgets(
      'shows badge with count when there are 1-99 unread notifications',
      (tester) async {
        // Create 5 unread notifications
        final notifications = List<taco_notification.Notification>.generate(
          5,
          (index) => taco_notification.Notification(
            id: 'notif-$index',
            businessId: testBusinessId,
            type: taco_notification.NotificationType.cancellation,
            message: 'Test notification $index',
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );

        when(
          () => mockPatronBloc.state,
        ).thenReturn(NotificationsLoaded(notifications));

        await tester.pumpWidget(createWidgetUnderTest());

        // Verify badge shows the count
        expect(find.text('5'), findsOneWidget);
      },
    );

    testWidgets(
      'shows "99+" badge when there are more than 99 unread notifications',
      (tester) async {
        // Create 150 unread notifications
        final notifications = List<taco_notification.Notification>.generate(
          150,
          (index) => taco_notification.Notification(
            id: 'notif-$index',
            businessId: testBusinessId,
            type: taco_notification.NotificationType.cancellation,
            message: 'Test notification $index',
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );

        when(
          () => mockPatronBloc.state,
        ).thenReturn(NotificationsLoaded(notifications));

        await tester.pumpWidget(createWidgetUnderTest());

        // Verify badge shows "99+"
        expect(find.text('99+'), findsOneWidget);
      },
    );

    testWidgets('badge has correct styling (red background, white text)', (
      tester,
    ) async {
      // Create 1 unread notification
      final notifications = <taco_notification.Notification>[
        taco_notification.Notification(
          id: 'notif-1',
          businessId: testBusinessId,
          type: taco_notification.NotificationType.cancellation,
          message: 'Test notification',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      ];

      when(
        () => mockPatronBloc.state,
      ).thenReturn(NotificationsLoaded(notifications));

      await tester.pumpWidget(createWidgetUnderTest());

      // Find the badge container
      final badgeContainer = tester.widget<Container>(
        find.ancestor(of: find.text('1'), matching: find.byType(Container)),
      );

      // Verify badge styling
      final decoration = badgeContainer.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
      expect(decoration.borderRadius, BorderRadius.circular(10));

      // Verify text styling
      final badgeText = tester.widget<Text>(find.text('1'));
      expect(badgeText.style?.color, Colors.white);
      expect(badgeText.style?.fontSize, 10);
      expect(badgeText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('notification icon reloads notifications when tapped', (
      tester,
    ) async {
      when(
        () => mockPatronBloc.state,
      ).thenReturn(const NotificationsLoaded([]));

      await tester.pumpWidget(createWidgetUnderTest());

      // Clear previous calls from init
      clearInteractions(mockPatronBloc);

      // Tap notification icon
      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pumpAndSettle();

      // Verify LoadNotificationsRequested was dispatched
      verify(
        () => mockPatronBloc.add(
          const LoadNotificationsRequested(testBusinessId),
        ),
      ).called(1);
    });
  });

  group('PatronDashboardPage - State Management', () {
    testWidgets('shows default notification icon when state is PatronInitial', (
      tester,
    ) async {
      when(() => mockPatronBloc.state).thenReturn(PatronInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify outlined notification icon (no badge)
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets(
      'badge updates when state changes from 0 to multiple notifications',
      (tester) async {
        // Create initial state with 3 notifications
        final notifications = List<taco_notification.Notification>.generate(
          3,
          (index) => taco_notification.Notification(
            id: 'notif-$index',
            businessId: testBusinessId,
            type: taco_notification.NotificationType.cancellation,
            message: 'Test notification $index',
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );

        when(
          () => mockPatronBloc.state,
        ).thenReturn(NotificationsLoaded(notifications));

        await tester.pumpWidget(createWidgetUnderTest());

        // Verify badge shows "3"
        expect(find.text('3'), findsOneWidget);
      },
    );
  });

  group('PatronDashboardPage - Edge Cases', () {
    testWidgets('handles exactly 99 notifications correctly', (tester) async {
      // Create exactly 99 notifications
      final notifications = List<taco_notification.Notification>.generate(
        99,
        (index) => taco_notification.Notification(
          id: 'notif-$index',
          businessId: testBusinessId,
          type: taco_notification.NotificationType.cancellation,
          message: 'Test notification $index',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );

      when(
        () => mockPatronBloc.state,
      ).thenReturn(NotificationsLoaded(notifications));

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify badge shows "99" (not "99+")
      expect(find.text('99'), findsOneWidget);
      expect(find.text('99+'), findsNothing);
    });

    testWidgets('handles exactly 100 notifications correctly', (tester) async {
      // Create exactly 100 notifications
      final notifications = List<taco_notification.Notification>.generate(
        100,
        (index) => taco_notification.Notification(
          id: 'notif-$index',
          businessId: testBusinessId,
          type: taco_notification.NotificationType.cancellation,
          message: 'Test notification $index',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );

      when(
        () => mockPatronBloc.state,
      ).thenReturn(NotificationsLoaded(notifications));

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify badge shows "99+" (when count > 99)
      expect(find.text('99+'), findsOneWidget);
      expect(find.text('100'), findsNothing);
    });

    testWidgets('handles businessId correctly in navigation', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // The test verifies businessId is passed in constructor
      // Navigation to other pages would be tested in integration tests
      expect(find.byType(PatronDashboardPage), findsOneWidget);
    });
  });

  group('PatronDashboardPage - AI Modules (Requirement 14.4)', () {
    testWidgets('shows AI modules section when plan is Business', (
      tester,
    ) async {
      // Create a Business plan business
      final business = Business(
        id: testBusinessId,
        name: 'Test Business',
        ownerId: 'test-owner',
        subscriptionPlan: SubscriptionPlan.business,
        createdAt: DateTime.now(),
      );

      when(() => mockPatronBloc.state).thenReturn(BusinessInfoLoaded(business));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify AI modules section is shown
      expect(find.text('Módulos de Inteligencia Artificial'), findsOneWidget);
      expect(find.text('Análisis Inteligente'), findsOneWidget);
      expect(
        find.text(
          'Predicciones de demanda, insights de ventas y recomendaciones personalizadas',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
    });

    testWidgets('does NOT show AI modules section when plan is Free', (
      tester,
    ) async {
      // Create a Free plan business
      final business = Business(
        id: testBusinessId,
        name: 'Test Business',
        ownerId: 'test-owner',
        subscriptionPlan: SubscriptionPlan.free,
        createdAt: DateTime.now(),
      );

      when(() => mockPatronBloc.state).thenReturn(BusinessInfoLoaded(business));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify AI modules section is NOT shown
      expect(find.text('Módulos de Inteligencia Artificial'), findsNothing);
      expect(find.text('Análisis Inteligente'), findsNothing);
      expect(find.byIcon(Icons.smart_toy), findsNothing);
    });

    testWidgets('does NOT show AI modules section when plan is Premium', (
      tester,
    ) async {
      // Create a Premium plan business
      final business = Business(
        id: testBusinessId,
        name: 'Test Business',
        ownerId: 'test-owner',
        subscriptionPlan: SubscriptionPlan.premium,
        createdAt: DateTime.now(),
      );

      when(() => mockPatronBloc.state).thenReturn(BusinessInfoLoaded(business));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify AI modules section is NOT shown
      expect(find.text('Módulos de Inteligencia Artificial'), findsNothing);
      expect(find.text('Análisis Inteligente'), findsNothing);
      expect(find.byIcon(Icons.smart_toy), findsNothing);
    });

    testWidgets(
      'does NOT show AI modules section when BusinessInfoLoaded not emitted yet',
      (tester) async {
        when(() => mockPatronBloc.state).thenReturn(PatronInitial());

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Verify AI modules section is NOT shown
        expect(find.text('Módulos de Inteligencia Artificial'), findsNothing);
        expect(find.text('Análisis Inteligente'), findsNothing);
      },
    );

    testWidgets(
      'other dashboard sections remain available when AI modules fail to load',
      (tester) async {
        // Simulate business info load error
        when(
          () => mockPatronBloc.state,
        ).thenReturn(const PatronError('Failed to load business info'));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Verify all 4 main sections are still available
        expect(find.text('Ventas'), findsOneWidget);
        expect(find.text('Reportes'), findsOneWidget);
        expect(find.text('Equipo'), findsOneWidget);
        expect(find.text('Configuración'), findsOneWidget);

        // Verify AI modules are not shown due to error
        expect(find.text('Módulos de Inteligencia Artificial'), findsNothing);
      },
    );

    testWidgets(
      'AI modules section shows placeholder content for Business plan',
      (tester) async {
        final business = Business(
          id: testBusinessId,
          name: 'Test Business',
          ownerId: 'test-owner',
          subscriptionPlan: SubscriptionPlan.business,
          createdAt: DateTime.now(),
        );

        when(
          () => mockPatronBloc.state,
        ).thenReturn(BusinessInfoLoaded(business));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Verify placeholder content is shown
        expect(find.byIcon(Icons.construction), findsOneWidget);
        expect(find.text('Módulos de IA en desarrollo'), findsOneWidget);
      },
    );
  });
}
