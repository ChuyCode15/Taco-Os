@echo off
echo ========================================
echo  Obteniendo SHA-1 Certificate Fingerprint
echo  para Google Sign-In Configuration
echo ========================================
echo.

echo Metodo 1: Usando Gradle (Recomendado)
echo.
cd android
call gradlew signingReport
cd ..

echo.
echo ========================================
echo.
echo Metodo 2: Usando keytool directamente
echo.

keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

echo.
echo ========================================
echo.
echo INSTRUCCIONES:
echo 1. Copia el valor SHA1 que aparece arriba
echo 2. Ve a Google Cloud Console
echo 3. Pega el SHA1 en la configuracion OAuth Android
echo.
echo Presiona cualquier tecla para cerrar...
pause >nul
