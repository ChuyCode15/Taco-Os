import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/infrastructure/datasources/local/app_database.dart';
import 'package:taco_os_app/presentation/pages/patron/configuracion/configuracion_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/native.dart';

// Mock class
class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late AppDatabase database;
  const testBusinessId = 'test-business-id';

  setUp(() async {
    // Create an in-memory database for testing
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: RepositoryProvider<AppDatabase>.value(
        value: database,
        child: const ConfiguracionPage(businessId: testBusinessId),
      ),
    );
  }

  group('ConfiguracionPage - Requirement 12.6', () {
    testWidgets('renders page with correct title', (tester) async {
      // Insert test business data
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Test Business',
              ownerId: 'test-owner',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify page title
      expect(find.text('Configuración'), findsOneWidget);
    });

    testWidgets('displays business name section', (tester) async {
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Taquería El Paisa',
              ownerId: 'test-owner',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify business name section
      expect(find.text('Nombre del Negocio'), findsOneWidget);
      expect(find.text('Taquería El Paisa'), findsOneWidget);
      expect(find.text('Editar Nombre'), findsOneWidget);
    });

    testWidgets('displays QR code section', (tester) async {
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Test Business',
              ownerId: 'test-owner',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify QR code section
      expect(find.text('Código QR de Vinculación'), findsOneWidget);
      expect(
        find.text(
          'Los cajeros deben escanear este código para vincularse al negocio',
        ),
        findsOneWidget,
      );
      expect(find.text('Regenerar Código QR'), findsOneWidget);
    });

    testWidgets('displays subscription plan section with Free plan', (
      tester,
    ) async {
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Test Business',
              ownerId: 'test-owner',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify subscription plan section
      expect(find.text('Plan de Suscripción'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);
      expect(find.text('Negocios: '), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Cajeros: '), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('displays subscription plan section with Premium plan', (
      tester,
    ) async {
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Test Business',
              ownerId: 'test-owner',
              plan: 'premium',
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify subscription plan section for Premium
      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // 2 businesses
      expect(find.text('5'), findsOneWidget); // 5 cashiers
    });

    testWidgets(
      'displays subscription plan section with Business plan and AI modules',
      (tester) async {
        await database
            .into(database.businesses)
            .insert(
              BusinessesCompanion.insert(
                id: testBusinessId,
                name: 'Test Business',
                ownerId: 'test-owner',
                plan: 'business',
                createdAt: DateTime.now(),
              ),
            );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Verify subscription plan section for Business
        expect(find.text('Business'), findsOneWidget);
        expect(find.text('5'), findsOneWidget); // 5 businesses
        expect(find.text('25'), findsOneWidget); // 25 cashiers
        expect(find.text('Módulos de Inteligencia Artificial'), findsOneWidget);
      },
    );

    testWidgets('displays product catalog section', (tester) async {
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Test Business',
              ownerId: 'test-owner',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify product catalog section
      expect(find.text('Catálogo de Productos'), findsOneWidget);
      expect(
        find.text(
          'Gestiona los productos de tu negocio organizados por categoría',
        ),
        findsOneWidget,
      );

      // Verify all three categories are shown
      expect(find.text('Comida'), findsOneWidget);
      expect(find.text('Bebidas'), findsOneWidget);
      expect(find.text('Postres'), findsOneWidget);
    });

    testWidgets('shows error state when business not found', (tester) async {
      // Don't insert any business data

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify error state
      expect(find.text('No se encontró el negocio'), findsOneWidget);
    });
  });

  group('ConfiguracionPage - Business Name Editing', () {
    testWidgets('can open edit business name dialog', (tester) async {
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Test Business',
              ownerId: 'test-owner',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap edit button
      await tester.tap(find.text('Editar Nombre'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Editar Nombre del Negocio'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);
    });

    testWidgets('validates empty business name', (tester) async {
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Test Business',
              ownerId: 'test-owner',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Open edit dialog
      await tester.tap(find.text('Editar Nombre'));
      await tester.pumpAndSettle();

      // Clear the text field
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pumpAndSettle();

      // Try to save
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('El nombre no puede estar vacío'), findsOneWidget);
    });

    testWidgets('validates business name max length (60 characters)', (
      tester,
    ) async {
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Test Business',
              ownerId: 'test-owner',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Open edit dialog
      await tester.tap(find.text('Editar Nombre'));
      await tester.pumpAndSettle();

      // Enter a name longer than 60 characters
      final longName = 'A' * 61;
      await tester.enterText(find.byType(TextFormField), longName);
      await tester.pumpAndSettle();

      // Try to save
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(
        find.text('El nombre no puede exceder 60 caracteres'),
        findsOneWidget,
      );
    });
  });

  group('ConfiguracionPage - Product Catalog Management', () {
    testWidgets('displays products grouped by category', (tester) async {
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Test Business',
              ownerId: 'test-owner',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      // Insert test products
      await database
          .into(database.products)
          .insert(
            ProductsCompanion.insert(
              id: 'product-1',
              businessId: testBusinessId,
              name: 'Taco de Pastor',
              price: 15.00,
              category: 'comida',
              updatedAt: DateTime.now(),
            ),
          );
      await database
          .into(database.products)
          .insert(
            ProductsCompanion.insert(
              id: 'product-2',
              businessId: testBusinessId,
              name: 'Coca Cola',
              price: 20.00,
              category: 'bebidas',
              updatedAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify products are shown
      expect(find.text('Taco de Pastor'), findsOneWidget);
      expect(find.text('\$15.00'), findsOneWidget);
      expect(find.text('Coca Cola'), findsOneWidget);
      expect(find.text('\$20.00'), findsOneWidget);

      // Verify category counts
      expect(
        find.text('1 productos'),
        findsNWidgets(2),
      ); // One for each category with products
    });

    testWidgets('can expand and collapse category sections', (tester) async {
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Test Business',
              ownerId: 'test-owner',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find ExpansionTile for Comida category
      final comidaTile = find.ancestor(
        of: find.text('Comida'),
        matching: find.byType(ExpansionTile),
      );

      expect(comidaTile, findsOneWidget);

      // Tap to expand (if not already expanded)
      await tester.tap(comidaTile);
      await tester.pumpAndSettle();

      // Verify "Agregar Producto" button is visible
      expect(find.text('Agregar Producto'), findsWidgets);
    });

    testWidgets('shows "Agregar Producto" button for each category', (
      tester,
    ) async {
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Test Business',
              ownerId: 'test-owner',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Expand all categories
      await tester.tap(find.text('Comida'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bebidas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Postres'));
      await tester.pumpAndSettle();

      // Verify "Agregar Producto" buttons (one per category)
      expect(find.text('Agregar Producto'), findsNWidgets(3));
    });

    testWidgets('shows empty state for categories without products', (
      tester,
    ) async {
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Test Business',
              ownerId: 'test-owner',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Expand Comida category (no products)
      await tester.tap(find.text('Comida'));
      await tester.pumpAndSettle();

      // Verify empty state message
      expect(find.text('No hay productos en esta categoría'), findsOneWidget);
    });
  });

  group('ConfiguracionPage - QR Code Regeneration', () {
    testWidgets('shows confirmation snackbar after regenerating QR', (
      tester,
    ) async {
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Test Business',
              ownerId: 'test-owner',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap regenerate button
      await tester.tap(find.text('Regenerar Código QR'));
      await tester.pumpAndSettle();

      // Verify snackbar is shown
      expect(find.text('Código QR regenerado exitosamente'), findsOneWidget);
    });
  });

  group('ConfiguracionPage - Requirement 14.3', () {
    testWidgets('shows correct limits for Free plan', (tester) async {
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Test Business',
              ownerId: 'test-owner',
              plan: 'free',
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify Free plan limits
      expect(find.text('Free'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // 1 business
      expect(find.text('2'), findsOneWidget); // 2 cashiers
    });

    testWidgets('shows correct limits for Premium plan', (tester) async {
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Test Business',
              ownerId: 'test-owner',
              plan: 'premium',
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify Premium plan limits
      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // 2 businesses
      expect(find.text('5'), findsOneWidget); // 5 cashiers
    });

    testWidgets('shows correct limits for Business plan', (tester) async {
      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              id: testBusinessId,
              name: 'Test Business',
              ownerId: 'test-owner',
              plan: 'business',
              createdAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify Business plan limits
      expect(find.text('Business'), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // 5 businesses
      expect(find.text('25'), findsOneWidget); // 25 cashiers

      // Verify AI modules feature is shown
      expect(find.text('Módulos de Inteligencia Artificial'), findsOneWidget);
    });
  });
}
