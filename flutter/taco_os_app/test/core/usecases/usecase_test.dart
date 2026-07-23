import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taco_os_app/core/errors/failures.dart';
import 'package:taco_os_app/core/usecases/usecase.dart';

// Concrete implementation for testing purposes
class TestUseCase extends UseCase<String, TestParams> {
  @override
  Future<Either<Failure, String>> call(TestParams params) async {
    if (params.shouldFail) {
      return left(const ValidationFailure(message: 'Test failure'));
    }
    return right('Success: ${params.value}');
  }
}

class TestParams {
  final String value;
  final bool shouldFail;

  TestParams({required this.value, this.shouldFail = false});
}

// Test use case with NoParams
class TestNoParamsUseCase extends UseCase<int, NoParams> {
  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    return right(42);
  }
}

void main() {
  group('UseCase', () {
    late TestUseCase testUseCase;

    setUp(() {
      testUseCase = TestUseCase();
    });

    test(
      'should return Right with success value when operation succeeds',
      () async {
        // Arrange
        final params = TestParams(value: 'test data');

        // Act
        final result = await testUseCase.call(params);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (value) => expect(value, 'Success: test data'),
        );
      },
    );

    test('should return Left with Failure when operation fails', () async {
      // Arrange
      final params = TestParams(value: 'test data', shouldFail: true);

      // Act
      final result = await testUseCase.call(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Test failure');
      }, (value) => fail('Should not return success value'));
    });

    test('should work with different parameter types', () async {
      // Arrange
      final params1 = TestParams(value: 'first');
      final params2 = TestParams(value: 'second');

      // Act
      final result1 = await testUseCase.call(params1);
      final result2 = await testUseCase.call(params2);

      // Assert
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);
      result1.fold(
        (_) => fail('Should not fail'),
        (value) => expect(value, 'Success: first'),
      );
      result2.fold(
        (_) => fail('Should not fail'),
        (value) => expect(value, 'Success: second'),
      );
    });
  });

  group('NoParams', () {
    late TestNoParamsUseCase testNoParamsUseCase;

    setUp(() {
      testNoParamsUseCase = TestNoParamsUseCase();
    });

    test(
      'should work with NoParams when use case requires no parameters',
      () async {
        // Arrange
        const params = NoParams();

        // Act
        final result = await testNoParamsUseCase.call(params);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (value) => expect(value, 42),
        );
      },
    );

    test('NoParams should be const constructible', () {
      // This ensures NoParams can be used as a const for efficiency
      const params1 = NoParams();
      const params2 = NoParams();

      expect(identical(params1, params2), true);
    });
  });
}
