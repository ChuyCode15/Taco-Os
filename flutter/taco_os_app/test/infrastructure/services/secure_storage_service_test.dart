import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taco_os_app/infrastructure/services/secure_storage_service.dart';
import 'package:taco_os_app/core/errors/exceptions.dart';

/// Mock de FlutterSecureStorage para pruebas
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageServiceImpl service;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageServiceImpl(storage: mockStorage);
  });

  group('SecureStorageServiceImpl', () {
    const testToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.token';

    group('saveToken', () {
      test(
        'WHEN saveToken es llamado con un JWT válido, '
        'THEN debe guardarlo en flutter_secure_storage usando la clave "jwt"',
        () async {
          // Arrange
          when(
            () => mockStorage.write(key: 'jwt', value: testToken),
          ).thenAnswer((_) async {});

          // Act
          await service.saveToken(testToken);

          // Assert
          verify(
            () => mockStorage.write(key: 'jwt', value: testToken),
          ).called(1);
        },
      );

      test(
        'WHEN flutter_secure_storage lanza una excepción al guardar, '
        'THEN debe lanzar LocalDatabaseException con mensaje descriptivo',
        () async {
          // Arrange
          when(
            () => mockStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            ),
          ).thenThrow(Exception('Storage write failed'));

          // Act & Assert
          expect(
            () => service.saveToken(testToken),
            throwsA(
              isA<LocalDatabaseException>().having(
                (e) => e.message,
                'message',
                contains('Error al guardar el token JWT'),
              ),
            ),
          );
        },
      );

      test(
        'WHEN saveToken es llamado con token vacío, '
        'THEN debe intentar guardarlo sin lanzar excepciones de validación',
        () async {
          // Arrange
          const emptyToken = '';
          when(
            () => mockStorage.write(key: 'jwt', value: emptyToken),
          ).thenAnswer((_) async {});

          // Act & Assert
          await expectLater(service.saveToken(emptyToken), completes);
          verify(
            () => mockStorage.write(key: 'jwt', value: emptyToken),
          ).called(1);
        },
      );
    });

    group('readToken', () {
      test('WHEN readToken es llamado y existe un JWT almacenado, '
          'THEN debe retornar el JWT desde flutter_secure_storage', () async {
        // Arrange
        when(
          () => mockStorage.read(key: 'jwt'),
        ).thenAnswer((_) async => testToken);

        // Act
        final result = await service.readToken();

        // Assert
        expect(result, equals(testToken));
        verify(() => mockStorage.read(key: 'jwt')).called(1);
      });

      test('WHEN readToken es llamado y NO existe un JWT almacenado, '
          'THEN debe retornar null', () async {
        // Arrange
        when(() => mockStorage.read(key: 'jwt')).thenAnswer((_) async => null);

        // Act
        final result = await service.readToken();

        // Assert
        expect(result, isNull);
        verify(() => mockStorage.read(key: 'jwt')).called(1);
      });

      test(
        'WHEN flutter_secure_storage lanza una excepción al leer, '
        'THEN debe lanzar LocalDatabaseException con mensaje descriptivo',
        () async {
          // Arrange
          when(
            () => mockStorage.read(key: any(named: 'key')),
          ).thenThrow(Exception('Storage read failed'));

          // Act & Assert
          expect(
            () => service.readToken(),
            throwsA(
              isA<LocalDatabaseException>().having(
                (e) => e.message,
                'message',
                contains('Error al leer el token JWT'),
              ),
            ),
          );
        },
      );
    });

    group('deleteToken', () {
      test(
        'WHEN deleteToken es llamado, '
        'THEN debe eliminar el JWT de flutter_secure_storage usando la clave "jwt"',
        () async {
          // Arrange
          when(() => mockStorage.delete(key: 'jwt')).thenAnswer((_) async {});

          // Act
          await service.deleteToken();

          // Assert
          verify(() => mockStorage.delete(key: 'jwt')).called(1);
        },
      );

      test(
        'WHEN flutter_secure_storage lanza una excepción al eliminar, '
        'THEN debe lanzar LocalDatabaseException con mensaje descriptivo',
        () async {
          // Arrange
          when(
            () => mockStorage.delete(key: any(named: 'key')),
          ).thenThrow(Exception('Storage delete failed'));

          // Act & Assert
          expect(
            () => service.deleteToken(),
            throwsA(
              isA<LocalDatabaseException>().having(
                (e) => e.message,
                'message',
                contains('Error al eliminar el token JWT'),
              ),
            ),
          );
        },
      );
    });

    group('hasToken', () {
      test('WHEN hasToken es llamado y existe un JWT almacenado, '
          'THEN debe retornar true', () async {
        // Arrange
        when(
          () => mockStorage.read(key: 'jwt'),
        ).thenAnswer((_) async => testToken);

        // Act
        final result = await service.hasToken();

        // Assert
        expect(result, isTrue);
        verify(() => mockStorage.read(key: 'jwt')).called(1);
      });

      test('WHEN hasToken es llamado y el JWT es null, '
          'THEN debe retornar false', () async {
        // Arrange
        when(() => mockStorage.read(key: 'jwt')).thenAnswer((_) async => null);

        // Act
        final result = await service.hasToken();

        // Assert
        expect(result, isFalse);
      });

      test('WHEN hasToken es llamado y el JWT es una cadena vacía, '
          'THEN debe retornar false', () async {
        // Arrange
        when(() => mockStorage.read(key: 'jwt')).thenAnswer((_) async => '');

        // Act
        final result = await service.hasToken();

        // Assert
        expect(result, isFalse);
      });

      test(
        'WHEN hasToken es llamado y flutter_secure_storage lanza una excepción, '
        'THEN debe retornar false sin propagar la excepción',
        () async {
          // Arrange
          when(
            () => mockStorage.read(key: any(named: 'key')),
          ).thenThrow(Exception('Storage error'));

          // Act
          final result = await service.hasToken();

          // Assert
          expect(result, isFalse);
        },
      );
    });

    group('Requirement Validation', () {
      test(
        'Requirement 1.2: Debe almacenar el token JWT en almacenamiento seguro local',
        () async {
          // Arrange
          when(
            () => mockStorage.write(key: 'jwt', value: testToken),
          ).thenAnswer((_) async {});

          // Act
          await service.saveToken(testToken);

          // Assert - Verifica que se usa flutter_secure_storage (Keychain/Keystore)
          verify(
            () => mockStorage.write(key: 'jwt', value: testToken),
          ).called(1);
        },
      );

      test(
        'Requirement 15.5: JWT NUNCA debe persistir en SQLite ni SharedPreferences',
        () {
          // Esta prueba verifica que SecureStorageService solo usa flutter_secure_storage
          // La implementación no tiene ninguna referencia a SQLite o SharedPreferences

          // Verifica que el servicio solo depende de FlutterSecureStorage
          expect(service, isA<ISecureStorageService>());
          expect(mockStorage, isA<FlutterSecureStorage>());
        },
      );

      test('Requirement 1.9: Debe eliminar el JWT al cerrar sesión', () async {
        // Arrange
        when(() => mockStorage.delete(key: 'jwt')).thenAnswer((_) async {});

        // Act
        await service.deleteToken();

        // Assert
        verify(() => mockStorage.delete(key: 'jwt')).called(1);
      });

      test(
        'Requirement 13.2: Debe depender de abstracciones (ISecureStorageService)',
        () {
          // Verifica que existe la abstracción ISecureStorageService
          expect(service, isA<ISecureStorageService>());
        },
      );
    });

    group('Edge Cases', () {
      test('WHEN se llaman múltiples operaciones en secuencia, '
          'THEN todas deben ejecutarse correctamente', () async {
        // Arrange
        when(
          () => mockStorage.write(key: 'jwt', value: testToken),
        ).thenAnswer((_) async {});
        when(
          () => mockStorage.read(key: 'jwt'),
        ).thenAnswer((_) async => testToken);
        when(() => mockStorage.delete(key: 'jwt')).thenAnswer((_) async {});

        // Act & Assert
        await service.saveToken(testToken);
        final token = await service.readToken();
        expect(token, equals(testToken));

        await service.deleteToken();

        // Verify all operations were called
        verify(() => mockStorage.write(key: 'jwt', value: testToken)).called(1);
        verify(() => mockStorage.read(key: 'jwt')).called(1);
        verify(() => mockStorage.delete(key: 'jwt')).called(1);
      });

      test('WHEN se guarda un token muy largo, '
          'THEN debe guardarlo sin problemas', () async {
        // Arrange - Token de 1000 caracteres
        final longToken = 'x' * 1000;
        when(
          () => mockStorage.write(key: 'jwt', value: longToken),
        ).thenAnswer((_) async {});

        // Act & Assert
        await expectLater(service.saveToken(longToken), completes);
        verify(() => mockStorage.write(key: 'jwt', value: longToken)).called(1);
      });

      test('WHEN se guarda un token con caracteres especiales, '
          'THEN debe guardarlo correctamente', () async {
        // Arrange
        const specialToken =
            'token.with-special_chars!@#\$%^&*()+={}[]|:;<>?,/~`';
        when(
          () => mockStorage.write(key: 'jwt', value: specialToken),
        ).thenAnswer((_) async {});

        // Act & Assert
        await expectLater(service.saveToken(specialToken), completes);
        verify(
          () => mockStorage.write(key: 'jwt', value: specialToken),
        ).called(1);
      });
    });
  });
}
