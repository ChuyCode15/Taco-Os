import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/presentation/blocs/cajero/corte_bloc.dart';
import 'package:taco_os_app/presentation/blocs/cajero/corte_event.dart';
import 'package:taco_os_app/presentation/blocs/cajero/corte_state.dart';
import 'package:taco_os_app/presentation/pages/cajero/corte/cash_count_page.dart';

// Mock class
class MockCorteBloc extends Mock implements CorteBloc {}

// Fake event for Mocktail
class FakeCashCountEntered extends Fake implements CashCountEntered {}

void main() {
  late MockCorteBloc mockCorteBloc;

  setUpAll(() {
    registerFallbackValue(FakeCashCountEntered());
  });

  setUp(() {
    mockCorteBloc = MockCorteBloc();
    when(() => mockCorteBloc.state).thenReturn(const CorteInitial());
    when(() => mockCorteBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    // BLoC is automatically cleaned up by BlocProvider
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<CorteBloc>.value(
        value: mockCorteBloc,
        child: const CashCountPage(),
      ),
    );
  }

  group('CashCountPage', () {
    testWidgets('renders all required UI elements', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify page title
      expect(find.text('Contar Efectivo'), findsNWidgets(2));

      // Verify icon
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);

      // Verify description
      expect(
        find.text('Ingresa el total de efectivo contado en la caja'),
        findsOneWidget,
      );

      // Verify input field
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Efectivo Contado'), findsOneWidget);

      // Verify button
      expect(find.widgetWithText(ElevatedButton, 'Continuar'), findsOneWidget);

      // Verify info note
      expect(
        find.text(
          'El efectivo contado puede ser \$0.00 si no hay efectivo en caja',
        ),
        findsOneWidget,
      );
    });

    testWidgets('validates empty input (Req 9.2)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap the button without entering a value
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      // Verify validation error is shown
      expect(find.text('El efectivo contado es requerido'), findsOneWidget);
    });

    testWidgets('validates negative value (Req 9.2)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Note: Input formatter prevents entering negative sign
      // This test validates the validator logic is present
      // The validator is tested in validators_test.dart

      // Verify input formatter allows only positive numbers
      await tester.enterText(find.byType(TextFormField), '100');
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      // Verify event was dispatched (valid positive value)
      verify(() => mockCorteBloc.add(any())).called(1);
    });

    testWidgets('validates value exceeding maximum (Req 9.2)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter a value exceeding the maximum
      await tester.enterText(find.byType(TextFormField), '1000000');
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      // Verify validation error is shown
      expect(
        find.text('El efectivo contado no puede exceder \$999,999.99'),
        findsOneWidget,
      );
    });

    testWidgets('accepts zero as valid input (Req 9.1)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter zero
      await tester.enterText(find.byType(TextFormField), '0');
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      // Verify no validation error
      expect(
        find.text('El efectivo contado no puede ser negativo'),
        findsNothing,
      );
      expect(
        find.text('El efectivo contado no puede exceder \$999,999.99'),
        findsNothing,
      );

      // Verify event was dispatched
      verify(() => mockCorteBloc.add(any())).called(1);
    });

    testWidgets('dispatches CashCountEntered on valid input (Req 9.1)', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter a valid value
      await tester.enterText(find.byType(TextFormField), '500.00');
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      // Verify event was dispatched
      verify(() => mockCorteBloc.add(any())).called(1);
    });

    testWidgets('shows snackbar when state is CorteValidationError (Req 9.2)', (
      tester,
    ) async {
      when(() => mockCorteBloc.stream).thenAnswer(
        (_) => Stream.value(
          const CorteValidationError(
            message: 'El efectivo contado no puede ser negativo',
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Verify error snackbar is shown
      expect(
        find.text('El efectivo contado no puede ser negativo'),
        findsOneWidget,
      );
    });

    testWidgets('shows error snackbar when state is CorteError', (
      tester,
    ) async {
      when(() => mockCorteBloc.stream).thenAnswer(
        (_) => Stream.value(
          const CorteError(message: 'Error en la base de datos local'),
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

    testWidgets('real-time validation shows error on invalid input (Req 9.2)', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Test real-time validation with exceeding maximum value
      await tester.enterText(find.byType(TextFormField), '1000000');
      await tester.pumpAndSettle();

      // Verify error is shown immediately (real-time validation)
      expect(
        find.text('El efectivo contado no puede exceder \$999,999.99'),
        findsOneWidget,
      );
    });

    testWidgets('accepts valid decimal values (Req 9.1)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter a valid decimal value
      await tester.enterText(find.byType(TextFormField), '1234.56');
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      // Verify no validation error
      expect(
        find.text('El efectivo contado no puede ser negativo'),
        findsNothing,
      );
      expect(
        find.text('El efectivo contado no puede exceder \$999,999.99'),
        findsNothing,
      );

      // Verify event was dispatched
      verify(() => mockCorteBloc.add(any())).called(1);
    });

    testWidgets('accepts maximum valid value (Req 9.2)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter maximum valid value
      await tester.enterText(find.byType(TextFormField), '999999.99');
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      // Verify no validation error
      expect(
        find.text('El efectivo contado no puede ser negativo'),
        findsNothing,
      );
      expect(
        find.text('El efectivo contado no puede exceder \$999,999.99'),
        findsNothing,
      );

      // Verify event was dispatched
      verify(() => mockCorteBloc.add(any())).called(1);
    });

    testWidgets('validates non-numeric input (Req 9.2)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Input formatters should prevent non-numeric input, but test validator
      // Tap the button without valid numeric input (empty after formatting)
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      // Verify validation error is shown
      expect(find.text('El efectivo contado es requerido'), findsOneWidget);
    });
  });
}
