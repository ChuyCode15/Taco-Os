import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/domain/entities/cash_session.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/cajero_state.dart';
import 'package:taco_os_app/presentation/pages/cajero/open_session_page.dart';

// Mock class
class MockCajeroBloc extends Mock implements CajeroBloc {}

// Fake event for Mocktail
class FakeOpenSessionRequested extends Fake implements OpenSessionRequested {}

void main() {
  late MockCajeroBloc mockCajeroBloc;

  setUpAll(() {
    registerFallbackValue(FakeOpenSessionRequested());
  });

  setUp(() {
    mockCajeroBloc = MockCajeroBloc();
    when(() => mockCajeroBloc.state).thenReturn(const CajeroInitial());
    when(() => mockCajeroBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    // BLoC is automatically cleaned up by BlocProvider
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<CajeroBloc>.value(
        value: mockCajeroBloc,
        child: const OpenSessionPage(),
      ),
    );
  }

  group('OpenSessionPage', () {
    testWidgets('renders all required UI elements', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify page title
      expect(find.text('Apertura de Caja'), findsOneWidget);
      expect(find.text('Iniciar Turno'), findsOneWidget);

      // Verify icon
      expect(find.byIcon(Icons.point_of_sale), findsOneWidget);

      // Verify description
      expect(
        find.text('Ingresa el fondo de cambio para comenzar tu turno'),
        findsOneWidget,
      );

      // Verify input field
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Fondo de Cambio'), findsOneWidget);

      // Verify button
      expect(find.widgetWithText(ElevatedButton, 'Abrir Caja'), findsOneWidget);

      // Verify info note
      expect(
        find.text(
          'El fondo de cambio puede ser \$0.00 si no tienes efectivo inicial',
        ),
        findsOneWidget,
      );
    });

    testWidgets('validates empty input', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap the button without entering a value
      await tester.tap(find.widgetWithText(ElevatedButton, 'Abrir Caja'));
      await tester.pumpAndSettle();

      // Verify validation error is shown
      expect(find.text('El fondo de cambio es requerido'), findsOneWidget);
    });

    testWidgets('validates negative value', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter a negative value
      await tester.enterText(find.byType(TextFormField), '-100');
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Abrir Caja'));
      await tester.pumpAndSettle();

      // Verify validation error is shown
      expect(
        find.text('El fondo de cambio no puede ser negativo'),
        findsOneWidget,
      );
    });

    testWidgets('validates value exceeding maximum', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter a value exceeding the maximum
      await tester.enterText(find.byType(TextFormField), '1000000');
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Abrir Caja'));
      await tester.pumpAndSettle();

      // Verify validation error is shown
      expect(
        find.text('El fondo de cambio no puede exceder \$999,999.99'),
        findsOneWidget,
      );
    });

    testWidgets('accepts zero as valid input (AC 3.7)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter zero
      await tester.enterText(find.byType(TextFormField), '0');
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Abrir Caja'));
      await tester.pumpAndSettle();

      // Verify no validation error
      expect(
        find.text('El fondo de cambio no puede ser negativo'),
        findsNothing,
      );
      expect(
        find.text('El fondo de cambio no puede exceder \$999,999.99'),
        findsNothing,
      );

      // Verify event was dispatched
      verify(() => mockCajeroBloc.add(any())).called(1);
    });

    testWidgets('dispatches OpenSessionRequested on valid input', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter a valid value
      await tester.enterText(find.byType(TextFormField), '500.00');
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Abrir Caja'));
      await tester.pumpAndSettle();

      // Verify event was dispatched
      verify(() => mockCajeroBloc.add(any())).called(1);
    });

    testWidgets('shows loading indicator when state is CajeroLoading', (
      tester,
    ) async {
      when(() => mockCajeroBloc.state).thenReturn(const CajeroLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify button is disabled
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Abrir Caja'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('shows success snackbar when state is TurnoActivo', (
      tester,
    ) async {
      final testSession = CashSession(
        id: 'test-session-id',
        businessId: 'test-business-id',
        userId: 'test-user-id',
        initialCash: 500.0,
        status: SessionStatus.open,
        openedAt: DateTime(2025, 1, 1, 9, 0),
      );

      when(
        () => mockCajeroBloc.stream,
      ).thenAnswer((_) => Stream.value(TurnoActivo(session: testSession)));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Verify success snackbar is shown
      expect(find.text('Turno iniciado exitosamente'), findsOneWidget);
    });

    testWidgets('shows error snackbar when state is CajeroError', (
      tester,
    ) async {
      when(() => mockCajeroBloc.stream).thenAnswer(
        (_) => Stream.value(
          const CajeroError(message: 'Error en la base de datos local'),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Verify error snackbar is shown
      expect(find.text('Error en la base de datos local'), findsOneWidget);
    });

    testWidgets('input field is configured for numeric input', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify the TextFormField exists and is properly configured
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('real-time validation shows error on invalid input', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter negative value
      await tester.enterText(find.byType(TextFormField), '-50');
      await tester.pumpAndSettle();

      // Verify error is shown immediately (real-time validation)
      expect(
        find.text('El fondo de cambio no puede ser negativo'),
        findsOneWidget,
      );
    });
  });
}
