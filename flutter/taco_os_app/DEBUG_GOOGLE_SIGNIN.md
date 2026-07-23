# 🐛 Guía de Depuración - Google Sign-In

Este documento explica cómo probar y depurar el flujo de autenticación con Google Sign-In en la app Taco'Os.

## 📋 Preparación

### 1. Verifica que el dispositivo/emulador esté conectado

```bash
flutter devices
```

Deberías ver algo como:
```
sdk gphone16k x86 64 (mobile) • emulator-5554 • android-x86 • Android 15 (API 35) (emulator)
```

### 2. Asegúrate de que la app compile

```bash
flutter build apk --debug
```

## 🚀 Ejecutar la App con Logs Detallados

### Opción 1: Ejecutar en emulador existente

Si ya tienes un emulador corriendo (por ejemplo, `emulator-5554`):

```bash
flutter run -d emulator-5554
```

### Opción 2: Ejecutar en cualquier dispositivo disponible

```bash
flutter run
```

Flutter te preguntará qué dispositivo usar si hay varios disponibles.

## 📱 Probar el Flujo de Autenticación

Una vez que la app esté corriendo:

1. **Espera a que aparezca el Splash Screen** (2.5 segundos)
2. **Verás la pantalla de Login** con dos botones:
   - **"Quiero ser cliente"** (Botón azul) = Registro
   - **"Soy cliente"** (Botón blanco) = Login

### Prueba 1: Registrar nuevo usuario

1. Toca el botón **"Quiero ser cliente"**
2. En la terminal verás:
   ```
   ═══════════════════════════════════════════════════════════
   🚀 INICIANDO GOOGLE SIGN-IN
      Tipo: REGISTRO
   ═══════════════════════════════════════════════════════════
   ```
3. Se abrirá la UI de Google Sign-In
4. Selecciona una cuenta de Google
5. Observa los logs en la terminal

### Prueba 2: Login con usuario existente

1. Toca el botón **"Soy cliente"**
2. En la terminal verás:
   ```
   ═══════════════════════════════════════════════════════════
   🚀 INICIANDO GOOGLE SIGN-IN
      Tipo: LOGIN
   ═══════════════════════════════════════════════════════════
   ```
3. Se abrirá la UI de Google Sign-In
4. Selecciona una cuenta de Google
5. Observa los logs en la terminal

## 📊 Interpretando los Logs

Los logs están organizados con emojis para facilitar la lectura:

### Logs de Éxito ✅

```
═══════════════════════════════════════════════════════════
🚀 INICIANDO GOOGLE SIGN-IN
   Tipo: LOGIN
═══════════════════════════════════════════════════════════
📋 Verificando bloqueo por intentos fallidos...
✅ No hay bloqueo activo
📱 Obteniendo instancia de GoogleSignIn...
✅ Instancia obtenida: Instance of 'GoogleSignIn'
🔐 Llamando a authenticate() - mostrando UI de Google...
✅ authenticate() completado
   Usuario obtenido: tu.email@gmail.com
👤 Datos del usuario de Google:
   Email: tu.email@gmail.com
   Nombre: Tu Nombre
   ID: 123456789
🔑 Obteniendo authentication tokens...
   idToken: eyJhbGciOiJSUzI1NiIs...

🌐 LLAMADA AL BACKEND:
   Endpoint: http://tu-backend.com/api/v1/auth/google-signin
   Payload: {google_token: "eyJhbGciOiJSUzI1NiIs...", isRegistration: false}
📡 RESPUESTA DEL BACKEND:
   Status Code: 200
   Headers: ...
   Body: {token: ..., userId: ..., role: ...}
✅ Respuesta exitosa del servidor
🎟️  JWT recibido: eyJhbGciOiJIUzI1NiIs...
💾 Guardando JWT en almacenamiento seguro...
✅ JWT guardado correctamente

✅ USUARIO CREADO:
   ID: user_123
   Email: tu.email@gmail.com
   Nombre: Tu Nombre
   Rol: UserRole.patron
   Business ID: business_456
🔄 Contador de intentos reseteado
═══════════════════════════════════════════════════════════
🎉 AUTENTICACIÓN EXITOSA
═══════════════════════════════════════════════════════════
```

### Logs de Error ❌

#### Error: Usuario cancela el sign-in

```
🔐 Llamando a authenticate() - mostrando UI de Google...
❌ ERROR en authenticate(): PlatformException(sign_in_canceled, ...)
   Tipo de error: PlatformException
ℹ️  El usuario canceló el flujo de autenticación
```

#### Error: No se obtiene el idToken

```
🔑 Obteniendo authentication tokens...
   idToken: NULL
❌ ERROR: idToken es NULL
```

#### Error: Backend no responde

```
🌐 LLAMADA AL BACKEND:
   Endpoint: http://tu-backend.com/api/v1/auth/google-signin
   Payload: {google_token: "...", isRegistration: false}

❌ DIO EXCEPTION:
   Tipo: DioExceptionType.connectionError
   Mensaje: Failed to connect to tu-backend.com
   Response: null
   Status Code: null
```

#### Error: Backend devuelve error

```
📡 RESPUESTA DEL BACKEND:
   Status Code: 401
   Headers: ...
   Body: {message: "Invalid Google token"}
🚫 ERROR DE AUTENTICACIÓN:
   Status: 401
   Mensaje: {message: Invalid Google token}
```

## 🔍 Problemas Comunes y Soluciones

### Problema 1: "No se pudo obtener el token de Google"

**Síntoma:**
```
❌ ERROR: idToken es NULL
```

**Causas posibles:**
1. La configuración de OAuth en Google Cloud Console está incompleta
2. El Client ID no está configurado correctamente para la plataforma (Android/iOS)
3. La app no está firmada con el certificado correcto (Android)

**Solución:**
- Verifica que los Client IDs estén correctamente configurados en:
  - `android/app/google-services.json` (Android)
  - `ios/Runner/Info.plist` (iOS)
- Revisa la configuración en Google Cloud Console

### Problema 2: "Sin conexión a internet" o "Failed to connect"

**Síntoma:**
```
❌ DIO EXCEPTION:
   Tipo: DioExceptionType.connectionError
```

**Causas posibles:**
1. El backend no está corriendo
2. La URL del backend es incorrecta
3. No hay conexión a internet

**Solución:**
1. Verifica que el backend esté corriendo
2. Verifica la URL en `lib/core/constants/api_endpoints.dart`
3. Verifica la conexión del emulador/dispositivo

### Problema 3: Backend devuelve 401 o 403

**Síntoma:**
```
🚫 ERROR DE AUTENTICACIÓN:
   Status: 401
   Mensaje: {message: Invalid Google token}
```

**Causas posibles:**
1. El backend no está validando correctamente el `idToken` con Google
2. El backend espera un formato diferente del payload
3. El token ha expirado

**Solución:**
1. Verifica que el backend valide el token con: `https://oauth2.googleapis.com/tokeninfo?id_token={idToken}`
2. Verifica que el backend espere: `{google_token: string, isRegistration: boolean}`
3. Revisa los logs del backend

### Problema 4: "PlatformException: google_sign_in, No active configuration"

**Síntoma en iOS:**
```
❌ ERROR en authenticate(): PlatformException(google_sign_in, No active configuration...)
```

**Solución:**
- Verifica que `ios/Runner/Info.plist` tenga:
  - `GIDClientID` (iOS Client ID)
  - `CFBundleURLTypes` con el reversed ID
  - `GIDServerClientID` (Web Client ID)

### Problema 5: El usuario cancela constantemente

**Síntoma:**
```
ℹ️  El usuario canceló el flujo de autenticación
```

**Posibles razones:**
1. El usuario está cerrando la ventana de Google Sign-In
2. Hay un error en la UI de Google Sign-In que no se muestra

**Solución:**
- Intenta con diferentes cuentas de Google
- Verifica que la cuenta de Google esté activa

## 📝 Notas Importantes

1. **idToken vs accessToken**: La app envía el `idToken` (no `accessToken`) al backend para autenticación
2. **Backend debe validar**: El backend DEBE validar el token con Google antes de crear el JWT
3. **Contador de intentos**: Después de 3 intentos fallidos, se bloquea por 30 segundos
4. **Logs en producción**: Estos logs detallados están pensados para debug. En producción, considera reducirlos.

## 🛠️ Comandos Útiles

### Ver solo errores en los logs

```bash
flutter run -d emulator-5554 | findstr "❌"
```

### Limpiar caché y rebuild

```bash
flutter clean
flutter pub get
flutter run -d emulator-5554
```

### Ver logs de sistema (Android)

```bash
adb logcat | findstr "flutter"
```

## 📞 Información de Contacto del Backend

Asegúrate de configurar correctamente la URL del backend en:
```dart
// lib/core/constants/api_endpoints.dart
class ApiEndpoints {
  static const String baseUrl = 'http://TU-BACKEND-URL:PUERTO';
  static const String authGoogleSignIn = '/api/v1/auth/google-signin';
  // ...
}
```

## ✅ Checklist de Verificación

Antes de reportar un problema, verifica:

- [ ] El emulador/dispositivo tiene conexión a internet
- [ ] Los Client IDs están configurados correctamente
- [ ] El backend está corriendo y accesible
- [ ] La URL del backend es correcta
- [ ] Los logs muestran exactamente dónde falla el proceso
- [ ] Has probado con diferentes cuentas de Google
- [ ] Has revisado la consola de Google Cloud para errores

¡Buena suerte con el debugging! 🚀
