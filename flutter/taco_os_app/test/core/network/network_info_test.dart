import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taco_os_app/core/network/network_info.dart';

// Mock class for Connectivity
class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late NetworkInfoImpl networkInfo;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
    networkInfo = NetworkInfoImpl(connectivity: mockConnectivity);
  });

  group('NetworkInfoImpl', () {
    test('should return true when device has mobile connectivity', () async {
      // arrange
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.mobile]);

      // act
      final result = await networkInfo.isConnected;

      // assert
      expect(result, true);
      verify(() => mockConnectivity.checkConnectivity()).called(1);
    });

    test('should return true when device has wifi connectivity', () async {
      // arrange
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.wifi]);

      // act
      final result = await networkInfo.isConnected;

      // assert
      expect(result, true);
      verify(() => mockConnectivity.checkConnectivity()).called(1);
    });

    test(
      'should return true when device has multiple connectivity options',
      () async {
        // arrange
        when(() => mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => [ConnectivityResult.wifi, ConnectivityResult.mobile],
        );

        // act
        final result = await networkInfo.isConnected;

        // assert
        expect(result, true);
        verify(() => mockConnectivity.checkConnectivity()).called(1);
      },
    );

    test('should return false when device has no connectivity', () async {
      // arrange
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.none]);

      // act
      final result = await networkInfo.isConnected;

      // assert
      expect(result, false);
      verify(() => mockConnectivity.checkConnectivity()).called(1);
    });

    test('should return false when connectivity list is empty', () async {
      // arrange
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => []);

      // act
      final result = await networkInfo.isConnected;

      // assert
      expect(result, false);
      verify(() => mockConnectivity.checkConnectivity()).called(1);
    });

    test('should return true when device has ethernet connectivity', () async {
      // arrange
      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.ethernet]);

      // act
      final result = await networkInfo.isConnected;

      // assert
      expect(result, true);
      verify(() => mockConnectivity.checkConnectivity()).called(1);
    });
  });
}
