import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/domain/entities/business.dart';
import 'package:taco_os_app/domain/repositories/i_business_repository.dart';
import 'package:taco_os_app/domain/usecases/patron/add_business_use_case.dart';

class MockBusinessRepository extends Mock implements IBusinessRepository {}

class FakeBusiness extends Fake implements Business {}

void main() {
  late AddBusinessUseCase useCase;
  late MockBusinessRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeBusiness());
  });

  setUp(() {
    mockRepository = MockBusinessRepository();
    useCase = AddBusinessUseCase(mockRepository);
  });

  group('AddBusinessUseCase', () {
    const ownerId = 'owner-123';
    const businessName = 'Mi Taquería';
    final testDate = DateTime(2024, 1, 1);

    test('should create business when Free plan has 0 businesses', () async {
      // Arrange
      final params = AddBusinessParams(
        name: businessName,
        ownerId: ownerId,
        subscriptionPlan: SubscriptionPlan.free,
      );

      when(
        () => mockRepository.getBusinessesByOwner(ownerId),
      ).thenAnswer((_) async => right(<Business>[]));

      when(() => mockRepository.createBusiness(any())).thenAnswer((
        invocation,
      ) async {
        final business = invocation.positionalArguments[0] as Business;
        return right(business);
      });

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected success but got failure'), (
        business,
      ) {
        expect(business.name, businessName);
        expect(business.ownerId, ownerId);
        expect(business.subscriptionPlan, SubscriptionPlan.free);
      });

      verify(() => mockRepository.getBusinessesByOwner(ownerId)).called(1);
      verify(() => mockRepository.createBusiness(any())).called(1);
    });

    test(
      'should return LicenseLimitFailure when Free plan has 1 business',
      () async {
        // Arrange
        final params = AddBusinessParams(
          name: businessName,
          ownerId: ownerId,
          subscriptionPlan: SubscriptionPlan.free,
        );

        final existingBusiness = Business(
          id: 'business-1',
          name: 'Existing Business',
          ownerId: ownerId,
          subscriptionPlan: SubscriptionPlan.free,
          createdAt: testDate,
        );

        when(
          () => mockRepository.getBusinessesByOwner(ownerId),
        ).thenAnswer((_) async => right([existingBusiness]));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<LicenseLimitFailure>());
          final limitFailure = failure as LicenseLimitFailure;
          expect(limitFailure.currentPlan, SubscriptionPlan.free);
          expect(limitFailure.message, contains('1 negocio(s)'));
          expect(limitFailure.message, contains('Free'));
          expect(limitFailure.message, contains('Premium'));
        }, (business) => fail('Expected failure but got success'));

        verify(() => mockRepository.getBusinessesByOwner(ownerId)).called(1);
        verifyNever(() => mockRepository.createBusiness(any()));
      },
    );

    test('should create business when Premium plan has 1 business', () async {
      // Arrange
      final params = AddBusinessParams(
        name: businessName,
        ownerId: ownerId,
        subscriptionPlan: SubscriptionPlan.premium,
      );

      final existingBusiness = Business(
        id: 'business-1',
        name: 'Existing Business',
        ownerId: ownerId,
        subscriptionPlan: SubscriptionPlan.premium,
        createdAt: testDate,
      );

      when(
        () => mockRepository.getBusinessesByOwner(ownerId),
      ).thenAnswer((_) async => right([existingBusiness]));

      when(() => mockRepository.createBusiness(any())).thenAnswer((
        invocation,
      ) async {
        final business = invocation.positionalArguments[0] as Business;
        return right(business);
      });

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.getBusinessesByOwner(ownerId)).called(1);
      verify(() => mockRepository.createBusiness(any())).called(1);
    });

    test(
      'should return LicenseLimitFailure when Premium plan has 2 businesses',
      () async {
        // Arrange
        final params = AddBusinessParams(
          name: businessName,
          ownerId: ownerId,
          subscriptionPlan: SubscriptionPlan.premium,
        );

        final existingBusinesses = [
          Business(
            id: 'business-1',
            name: 'Business 1',
            ownerId: ownerId,
            subscriptionPlan: SubscriptionPlan.premium,
            createdAt: testDate,
          ),
          Business(
            id: 'business-2',
            name: 'Business 2',
            ownerId: ownerId,
            subscriptionPlan: SubscriptionPlan.premium,
            createdAt: testDate,
          ),
        ];

        when(
          () => mockRepository.getBusinessesByOwner(ownerId),
        ).thenAnswer((_) async => right(existingBusinesses));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<LicenseLimitFailure>());
          final limitFailure = failure as LicenseLimitFailure;
          expect(limitFailure.currentPlan, SubscriptionPlan.premium);
          expect(limitFailure.message, contains('2 negocio(s)'));
          expect(limitFailure.message, contains('Premium'));
          expect(limitFailure.message, contains('Business'));
        }, (business) => fail('Expected failure but got success'));

        verify(() => mockRepository.getBusinessesByOwner(ownerId)).called(1);
        verifyNever(() => mockRepository.createBusiness(any()));
      },
    );

    test(
      'should create business when Business plan has 4 businesses',
      () async {
        // Arrange
        final params = AddBusinessParams(
          name: businessName,
          ownerId: ownerId,
          subscriptionPlan: SubscriptionPlan.business,
        );

        final existingBusinesses = List.generate(
          4,
          (index) => Business(
            id: 'business-$index',
            name: 'Business $index',
            ownerId: ownerId,
            subscriptionPlan: SubscriptionPlan.business,
            createdAt: testDate,
          ),
        );

        when(
          () => mockRepository.getBusinessesByOwner(ownerId),
        ).thenAnswer((_) async => right(existingBusinesses));

        when(() => mockRepository.createBusiness(any())).thenAnswer((
          invocation,
        ) async {
          final business = invocation.positionalArguments[0] as Business;
          return right(business);
        });

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
        verify(() => mockRepository.getBusinessesByOwner(ownerId)).called(1);
        verify(() => mockRepository.createBusiness(any())).called(1);
      },
    );

    test(
      'should return LicenseLimitFailure when Business plan has 5 businesses',
      () async {
        // Arrange
        final params = AddBusinessParams(
          name: businessName,
          ownerId: ownerId,
          subscriptionPlan: SubscriptionPlan.business,
        );

        final existingBusinesses = List.generate(
          5,
          (index) => Business(
            id: 'business-$index',
            name: 'Business $index',
            ownerId: ownerId,
            subscriptionPlan: SubscriptionPlan.business,
            createdAt: testDate,
          ),
        );

        when(
          () => mockRepository.getBusinessesByOwner(ownerId),
        ).thenAnswer((_) async => right(existingBusinesses));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<LicenseLimitFailure>());
          final limitFailure = failure as LicenseLimitFailure;
          expect(limitFailure.currentPlan, SubscriptionPlan.business);
          expect(limitFailure.message, contains('5 negocio(s)'));
          expect(limitFailure.message, contains('Business'));
        }, (business) => fail('Expected failure but got success'));

        verify(() => mockRepository.getBusinessesByOwner(ownerId)).called(1);
        verifyNever(() => mockRepository.createBusiness(any()));
      },
    );

    test('should propagate LocalDatabaseFailure from repository', () async {
      // Arrange
      final params = AddBusinessParams(
        name: businessName,
        ownerId: ownerId,
        subscriptionPlan: SubscriptionPlan.free,
      );

      when(
        () => mockRepository.getBusinessesByOwner(ownerId),
      ).thenAnswer((_) async => left(const LocalDatabaseFailure()));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<LocalDatabaseFailure>()),
        (business) => fail('Expected failure but got success'),
      );

      verify(() => mockRepository.getBusinessesByOwner(ownerId)).called(1);
      verifyNever(() => mockRepository.createBusiness(any()));
    });
  });
}
