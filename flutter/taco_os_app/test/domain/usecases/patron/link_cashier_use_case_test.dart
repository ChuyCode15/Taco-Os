import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/domain/entities/business.dart';
import 'package:taco_os_app/domain/entities/user.dart';
import 'package:taco_os_app/domain/repositories/i_business_repository.dart';
import 'package:taco_os_app/domain/usecases/patron/link_cashier_use_case.dart';

class MockBusinessRepository extends Mock implements IBusinessRepository {}

class FakeBusiness extends Fake implements Business {}

void main() {
  late LinkCashierUseCase useCase;
  late MockBusinessRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeBusiness());
  });

  setUp(() {
    mockRepository = MockBusinessRepository();
    useCase = LinkCashierUseCase(mockRepository);
  });

  group('LinkCashierUseCase', () {
    const businessId = 'business-123';
    const cashierId = 'cashier-456';
    final testDate = DateTime(2024, 1, 1);

    User createCashier(String id) {
      return User(
        id: id,
        email: 'cashier$id@example.com',
        displayName: 'Cajero $id',
        role: UserRole.cajero,
        businessId: businessId,
        createdAt: testDate,
      );
    }

    test('should link cashier when Free plan has 1 cashier', () async {
      // Arrange
      final params = LinkCashierParams(
        cashierId: cashierId,
        businessId: businessId,
      );

      final business = Business(
        id: businessId,
        name: 'Mi Taquería',
        ownerId: 'owner-123',
        subscriptionPlan: SubscriptionPlan.free,
        createdAt: testDate,
      );

      final existingCashiers = [createCashier('1')];

      when(
        () => mockRepository.getBusinessById(businessId),
      ).thenAnswer((_) async => right(business));

      when(
        () => mockRepository.getCashiersByBusiness(businessId),
      ).thenAnswer((_) async => right(existingCashiers));

      when(
        () => mockRepository.linkCashierToBusiness(
          cashierId: cashierId,
          businessId: businessId,
        ),
      ).thenAnswer((_) async => right(null));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.getBusinessById(businessId)).called(1);
      verify(() => mockRepository.getCashiersByBusiness(businessId)).called(1);
      verify(
        () => mockRepository.linkCashierToBusiness(
          cashierId: cashierId,
          businessId: businessId,
        ),
      ).called(1);
    });

    test(
      'should return LicenseLimitFailure when Free plan has 2 cashiers',
      () async {
        // Arrange
        final params = LinkCashierParams(
          cashierId: cashierId,
          businessId: businessId,
        );

        final business = Business(
          id: businessId,
          name: 'Mi Taquería',
          ownerId: 'owner-123',
          subscriptionPlan: SubscriptionPlan.free,
          createdAt: testDate,
        );

        final existingCashiers = [createCashier('1'), createCashier('2')];

        when(
          () => mockRepository.getBusinessById(businessId),
        ).thenAnswer((_) async => right(business));

        when(
          () => mockRepository.getCashiersByBusiness(businessId),
        ).thenAnswer((_) async => right(existingCashiers));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<LicenseLimitFailure>());
          final limitFailure = failure as LicenseLimitFailure;
          expect(limitFailure.currentPlan, SubscriptionPlan.free);
          expect(limitFailure.message, contains('2 cajero(s)'));
          expect(limitFailure.message, contains('Free'));
          expect(limitFailure.message, contains('Premium'));
        }, (_) => fail('Expected failure but got success'));

        verify(() => mockRepository.getBusinessById(businessId)).called(1);
        verify(
          () => mockRepository.getCashiersByBusiness(businessId),
        ).called(1);
        verifyNever(
          () => mockRepository.linkCashierToBusiness(
            cashierId: any(named: 'cashierId'),
            businessId: any(named: 'businessId'),
          ),
        );
      },
    );

    test('should link cashier when Premium plan has 4 cashiers', () async {
      // Arrange
      final params = LinkCashierParams(
        cashierId: cashierId,
        businessId: businessId,
      );

      final business = Business(
        id: businessId,
        name: 'Mi Taquería',
        ownerId: 'owner-123',
        subscriptionPlan: SubscriptionPlan.premium,
        createdAt: testDate,
      );

      final existingCashiers = List.generate(
        4,
        (index) => createCashier('${index + 1}'),
      );

      when(
        () => mockRepository.getBusinessById(businessId),
      ).thenAnswer((_) async => right(business));

      when(
        () => mockRepository.getCashiersByBusiness(businessId),
      ).thenAnswer((_) async => right(existingCashiers));

      when(
        () => mockRepository.linkCashierToBusiness(
          cashierId: cashierId,
          businessId: businessId,
        ),
      ).thenAnswer((_) async => right(null));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.getBusinessById(businessId)).called(1);
      verify(() => mockRepository.getCashiersByBusiness(businessId)).called(1);
      verify(
        () => mockRepository.linkCashierToBusiness(
          cashierId: cashierId,
          businessId: businessId,
        ),
      ).called(1);
    });

    test(
      'should return LicenseLimitFailure when Premium plan has 5 cashiers',
      () async {
        // Arrange
        final params = LinkCashierParams(
          cashierId: cashierId,
          businessId: businessId,
        );

        final business = Business(
          id: businessId,
          name: 'Mi Taquería',
          ownerId: 'owner-123',
          subscriptionPlan: SubscriptionPlan.premium,
          createdAt: testDate,
        );

        final existingCashiers = List.generate(
          5,
          (index) => createCashier('${index + 1}'),
        );

        when(
          () => mockRepository.getBusinessById(businessId),
        ).thenAnswer((_) async => right(business));

        when(
          () => mockRepository.getCashiersByBusiness(businessId),
        ).thenAnswer((_) async => right(existingCashiers));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<LicenseLimitFailure>());
          final limitFailure = failure as LicenseLimitFailure;
          expect(limitFailure.currentPlan, SubscriptionPlan.premium);
          expect(limitFailure.message, contains('5 cajero(s)'));
          expect(limitFailure.message, contains('Premium'));
          expect(limitFailure.message, contains('Business'));
        }, (_) => fail('Expected failure but got success'));

        verify(() => mockRepository.getBusinessById(businessId)).called(1);
        verify(
          () => mockRepository.getCashiersByBusiness(businessId),
        ).called(1);
        verifyNever(
          () => mockRepository.linkCashierToBusiness(
            cashierId: any(named: 'cashierId'),
            businessId: any(named: 'businessId'),
          ),
        );
      },
    );

    test('should link cashier when Business plan has 24 cashiers', () async {
      // Arrange
      final params = LinkCashierParams(
        cashierId: cashierId,
        businessId: businessId,
      );

      final business = Business(
        id: businessId,
        name: 'Mi Taquería',
        ownerId: 'owner-123',
        subscriptionPlan: SubscriptionPlan.business,
        createdAt: testDate,
      );

      final existingCashiers = List.generate(
        24,
        (index) => createCashier('${index + 1}'),
      );

      when(
        () => mockRepository.getBusinessById(businessId),
      ).thenAnswer((_) async => right(business));

      when(
        () => mockRepository.getCashiersByBusiness(businessId),
      ).thenAnswer((_) async => right(existingCashiers));

      when(
        () => mockRepository.linkCashierToBusiness(
          cashierId: cashierId,
          businessId: businessId,
        ),
      ).thenAnswer((_) async => right(null));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.getBusinessById(businessId)).called(1);
      verify(() => mockRepository.getCashiersByBusiness(businessId)).called(1);
      verify(
        () => mockRepository.linkCashierToBusiness(
          cashierId: cashierId,
          businessId: businessId,
        ),
      ).called(1);
    });

    test(
      'should return LicenseLimitFailure when Business plan has 25 cashiers',
      () async {
        // Arrange
        final params = LinkCashierParams(
          cashierId: cashierId,
          businessId: businessId,
        );

        final business = Business(
          id: businessId,
          name: 'Mi Taquería',
          ownerId: 'owner-123',
          subscriptionPlan: SubscriptionPlan.business,
          createdAt: testDate,
        );

        final existingCashiers = List.generate(
          25,
          (index) => createCashier('${index + 1}'),
        );

        when(
          () => mockRepository.getBusinessById(businessId),
        ).thenAnswer((_) async => right(business));

        when(
          () => mockRepository.getCashiersByBusiness(businessId),
        ).thenAnswer((_) async => right(existingCashiers));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<LicenseLimitFailure>());
          final limitFailure = failure as LicenseLimitFailure;
          expect(limitFailure.currentPlan, SubscriptionPlan.business);
          expect(limitFailure.message, contains('25 cajero(s)'));
          expect(limitFailure.message, contains('Business'));
        }, (_) => fail('Expected failure but got success'));

        verify(() => mockRepository.getBusinessById(businessId)).called(1);
        verify(
          () => mockRepository.getCashiersByBusiness(businessId),
        ).called(1);
        verifyNever(
          () => mockRepository.linkCashierToBusiness(
            cashierId: any(named: 'cashierId'),
            businessId: any(named: 'businessId'),
          ),
        );
      },
    );

    test(
      'should propagate LocalDatabaseFailure from getBusinessById',
      () async {
        // Arrange
        final params = LinkCashierParams(
          cashierId: cashierId,
          businessId: businessId,
        );

        when(
          () => mockRepository.getBusinessById(businessId),
        ).thenAnswer((_) async => left(const LocalDatabaseFailure()));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<LocalDatabaseFailure>()),
          (_) => fail('Expected failure but got success'),
        );

        verify(() => mockRepository.getBusinessById(businessId)).called(1);
        verifyNever(() => mockRepository.getCashiersByBusiness(any()));
        verifyNever(
          () => mockRepository.linkCashierToBusiness(
            cashierId: any(named: 'cashierId'),
            businessId: any(named: 'businessId'),
          ),
        );
      },
    );

    test(
      'should propagate LocalDatabaseFailure from getCashiersByBusiness',
      () async {
        // Arrange
        final params = LinkCashierParams(
          cashierId: cashierId,
          businessId: businessId,
        );

        final business = Business(
          id: businessId,
          name: 'Mi Taquería',
          ownerId: 'owner-123',
          subscriptionPlan: SubscriptionPlan.free,
          createdAt: testDate,
        );

        when(
          () => mockRepository.getBusinessById(businessId),
        ).thenAnswer((_) async => right(business));

        when(
          () => mockRepository.getCashiersByBusiness(businessId),
        ).thenAnswer((_) async => left(const LocalDatabaseFailure()));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<LocalDatabaseFailure>()),
          (_) => fail('Expected failure but got success'),
        );

        verify(() => mockRepository.getBusinessById(businessId)).called(1);
        verify(
          () => mockRepository.getCashiersByBusiness(businessId),
        ).called(1);
        verifyNever(
          () => mockRepository.linkCashierToBusiness(
            cashierId: any(named: 'cashierId'),
            businessId: any(named: 'businessId'),
          ),
        );
      },
    );
  });
}
