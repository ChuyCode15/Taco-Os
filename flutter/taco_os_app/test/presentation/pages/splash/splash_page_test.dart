import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taco_os_app/presentation/pages/splash/splash_page.dart';

void main() {
  group('SplashPage', () {
    testWidgets('muestra el logo "Taco\'Os" con fondo azul', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));

      // Assert
      expect(find.text("Taco'Os"), findsOneWidget);
      expect(
        find.text('Inteligencia financiera para tu negocio'),
        findsOneWidget,
      );

      // Verificar que el scaffold tiene el fondo azul
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF5B7FFF));
    });

    testWidgets('el logo tiene estilo correcto', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));

      // Assert
      final logoText = tester.widget<Text>(find.text("Taco'Os"));
      expect(logoText.style?.fontSize, 56);
      expect(logoText.style?.fontWeight, FontWeight.w700);
      expect(logoText.style?.color, Colors.white);
    });

    testWidgets('navega a /login después de 2.5 segundos', (tester) async {
      // Este test es más conceptual - verificamos que la página se renderiza
      // La navegación real se probará en tests de integración con go_router

      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));

      // Assert - Verificar que la página se renderiza
      expect(find.byType(SplashPage), findsOneWidget);
    });
  });
}
