import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/domain/entities/product.dart';
import 'package:taco_os_app/domain/repositories/i_product_repository.dart';
import 'package:taco_os_app/domain/usecases/catalog/get_products_by_category_use_case.dart';

class MockProductRepository extends Mock implements IProductRepository {}

void main() {
  late GetProductsByCategoryUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductsByCategoryUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(ProductCategory.comida);
  });

  group('GetProductsByCategoryUseCase', () {
    final tProducts = [
      Product(
        id: 'prod-1',
        businessId: 'business-123',
        name: 'Taco al pastor',
        price: 15.0,
        category: ProductCategory.comida,
        createdAt: DateTime(2024, 1, 1),
      ),
      Product(
        id: 'prod-2',
        businessId: 'business-123',
        name: 'Taco de asada',
        price: 18.0,
        category: ProductCategory.comida,
        createdAt: DateTime(2024, 1, 1),
      ),
    ];

    test('should return products for comida category', () async {
      // Arrange
      const params = GetProductsByCategoryParams(
        businessId: 'business-123',
        category: ProductCategory.comida,
      );
      when(
        () => mockRepository.getByCategory(any(), any()),
      ).thenAnswer((_) async => Right(tProducts));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should have returned products'), (products) {
        expect(products, equals(tProducts));
        expect(products.length, equals(2));
        expect(products[0].category, equals(ProductCategory.comida));
      });
      verify(
        () => mockRepository.getByCategory(
          'business-123',
          ProductCategory.comida,
        ),
      ).called(1);
    });

    test('should return products for bebidas category', () async {
      // Arrange
      final bebidas = [
        Product(
          id: 'prod-3',
          businessId: 'business-123',
          name: 'Refresco',
          price: 20.0,
          category: ProductCategory.bebidas,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
      const params = GetProductsByCategoryParams(
        businessId: 'business-123',
        category: ProductCategory.bebidas,
      );
      when(
        () => mockRepository.getByCategory(any(), any()),
      ).thenAnswer((_) async => Right(bebidas));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should have returned products'), (products) {
        expect(products, equals(bebidas));
        expect(products[0].category, equals(ProductCategory.bebidas));
      });
      verify(
        () => mockRepository.getByCategory(
          'business-123',
          ProductCategory.bebidas,
        ),
      ).called(1);
    });

    test('should return products for postres category', () async {
      // Arrange
      final postres = [
        Product(
          id: 'prod-4',
          businessId: 'business-123',
          name: 'Flan',
          price: 25.0,
          category: ProductCategory.postres,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
      const params = GetProductsByCategoryParams(
        businessId: 'business-123',
        category: ProductCategory.postres,
      );
      when(
        () => mockRepository.getByCategory(any(), any()),
      ).thenAnswer((_) async => Right(postres));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should have returned products'), (products) {
        expect(products, equals(postres));
        expect(products[0].category, equals(ProductCategory.postres));
      });
      verify(
        () => mockRepository.getByCategory(
          'business-123',
          ProductCategory.postres,
        ),
      ).called(1);
    });

    test('should return empty list when category has no products', () async {
      // Arrange
      const params = GetProductsByCategoryParams(
        businessId: 'business-123',
        category: ProductCategory.comida,
      );
      when(
        () => mockRepository.getByCategory(any(), any()),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should have returned empty list'), (products) {
        expect(products, isEmpty);
      });
      verify(
        () => mockRepository.getByCategory(
          'business-123',
          ProductCategory.comida,
        ),
      ).called(1);
    });

    test('should return LocalDatabaseFailure when repository fails', () async {
      // Arrange
      const params = GetProductsByCategoryParams(
        businessId: 'business-123',
        category: ProductCategory.comida,
      );
      when(() => mockRepository.getByCategory(any(), any())).thenAnswer(
        (_) async =>
            Left(LocalDatabaseFailure(message: 'Error leyendo de SQLite')),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<LocalDatabaseFailure>());
        expect((failure as LocalDatabaseFailure).message, contains('SQLite'));
      }, (_) => fail('Should have returned a failure'));
      verify(
        () => mockRepository.getByCategory(
          'business-123',
          ProductCategory.comida,
        ),
      ).called(1);
    });

    test(
      'should return NetworkFailure when offline with empty catalog',
      () async {
        // Arrange
        const params = GetProductsByCategoryParams(
          businessId: 'business-123',
          category: ProductCategory.comida,
        );
        when(() => mockRepository.getByCategory(any(), any())).thenAnswer(
          (_) async => Left(
            NetworkFailure(message: 'Sin conectividad y catálogo vacío'),
          ),
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<NetworkFailure>());
          expect((failure as NetworkFailure).message, contains('conectividad'));
        }, (_) => fail('Should have returned a failure'));
        verify(
          () => mockRepository.getByCategory(
            'business-123',
            ProductCategory.comida,
          ),
        ).called(1);
      },
    );

    test(
      'should filter products by businessId (multi-tenant isolation)',
      () async {
        // Arrange
        const params1 = GetProductsByCategoryParams(
          businessId: 'business-123',
          category: ProductCategory.comida,
        );
        const params2 = GetProductsByCategoryParams(
          businessId: 'business-456',
          category: ProductCategory.comida,
        );

        final productsForBusiness123 = [
          Product(
            id: 'prod-1',
            businessId: 'business-123',
            name: 'Taco al pastor',
            price: 15.0,
            category: ProductCategory.comida,
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        final productsForBusiness456 = [
          Product(
            id: 'prod-2',
            businessId: 'business-456',
            name: 'Taco de carnitas',
            price: 20.0,
            category: ProductCategory.comida,
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        when(
          () => mockRepository.getByCategory('business-123', any()),
        ).thenAnswer((_) async => Right(productsForBusiness123));
        when(
          () => mockRepository.getByCategory('business-456', any()),
        ).thenAnswer((_) async => Right(productsForBusiness456));

        // Act
        final result1 = await useCase(params1);
        final result2 = await useCase(params2);

        // Assert
        expect(result1.isRight(), true);
        expect(result2.isRight(), true);
        result1.fold(
          (_) => fail('Should have returned products for business-123'),
          (products) {
            expect(products.length, equals(1));
            expect(products[0].businessId, equals('business-123'));
          },
        );
        result2.fold(
          (_) => fail('Should have returned products for business-456'),
          (products) {
            expect(products.length, equals(1));
            expect(products[0].businessId, equals('business-456'));
          },
        );
        verify(
          () => mockRepository.getByCategory('business-123', any()),
        ).called(1);
        verify(
          () => mockRepository.getByCategory('business-456', any()),
        ).called(1);
      },
    );
  });
}
