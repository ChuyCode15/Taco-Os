# Configuración de Google Sign-In para Taco'Os App

## 📋 Resumen

Para que Google Sign-In funcione en tu app Flutter, necesitas:
1. Crear un proyecto en Google Cloud Console
2. Habilitar Google Sign-In API
3. Crear credenciales OAuth 2.0 para Android e iOS
4. Configurar los IDs en tu app Flutter

---

## 🚀 Paso 1: Crear Proyecto en Google Cloud Console

### 1.1 Acceder a Google Cloud Console
1. Ve a: https://console.cloud.google.com/
2. Inicia sesión con tu cuenta de Google

### 1.2 Crear Nuevo Proyecto
1. Haz clic en el selector de proyectos (arriba a la izquierda)
2. Haz clic en **"Nuevo proyecto"**
3. Nombre del proyecto: `TacoOs App` (o el nombre que prefieras)
4. Organización: (opcional, puedes dejarlo vacío)
5. Haz clic en **"Crear"**
6. Espera unos segundos a que se cree el proyecto
7. Selecciona el proyecto recién creado

---

## 🔑 Paso 2: Habilitar Google Sign-In API

### 2.1 Habilitar APIs
1. En el menú lateral, ve a: **"APIs y servicios" > "Biblioteca"**
2. Busca: `Google Sign-In`
3. Haz clic en **"Google Identity Toolkit API"** o **"Google+ API"**
4. Haz clic en **"Habilitar"**

Alternativamente, puedes ir directamente a:
https://console.cloud.google.com/apis/library/identitytoolkit.googleapis.com

---

## 📱 Paso 3: Obtener Credenciales para Android

### 3.1 Obtener SHA-1 Certificate Fingerprint

#### En Windows (CMD o PowerShell):
```cmd
cd C:\Users\faner\proyectos\TacoOs App\taco_os_app\android
gradlew signingReport
```

O si tienes keytool instalado:
```cmd
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

#### Copia el SHA-1 que aparece. Se ve algo así:
```
SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
```

### 3.2 Crear OAuth 2.0 Client ID para Android

1. Ve a: **"APIs y servicios" > "Credenciales"**
   - URL directa: https://console.cloud.google.com/apis/credentials
2. Haz clic en **"+ CREAR CREDENCIALES"**
3. Selecciona **"ID de cliente de OAuth 2.0"**
4. Tipo de aplicación: **"Aplicación para Android"**
5. Nombre: `Taco'Os Android App`
6. Nombre del paquete: 
   ```
   com.tacos.taco_os_app
   ```
   (Verifica el nombre del paquete en `android/app/build.gradle` → `applicationId`)
7. Huella digital del certificado SHA-1: **Pega el SHA-1 que copiaste**
8. Haz clic en **"Crear"**
9. **Copia el Client ID** que se genera. Se ve algo así:
   ```
   123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com
   ```

---

## 🍎 Paso 4: Obtener Credenciales para iOS

### 4.1 Crear OAuth 2.0 Client ID para iOS

1. Ve a: **"APIs y servicios" > "Credenciales"**
2. Haz clic en **"+ CREAR CREDENCIALES"**
3. Selecciona **"ID de cliente de OAuth 2.0"**
4. Tipo de aplicación: **"Aplicación para iOS"**
5. Nombre: `Taco'Os iOS App`
6. ID del paquete: 
   ```
   com.tacos.tacoOsApp
   ```
   (Verifica el bundle ID en Xcode o en `ios/Runner/Info.plist` → `CFBundleIdentifier`)
7. Haz clic en **"Crear"**
8. **Copia el Client ID** que se genera

---

## 🌐 Paso 5: Crear Web Client ID (IMPORTANTE)

**CRÍTICO:** Necesitas también un Web Client ID para que el backend pueda validar el token de Google.

### 5.1 Crear OAuth 2.0 Client ID Web

1. Ve a: **"APIs y servicios" > "Credenciales"**
2. Haz clic en **"+ CREAR CREDENCIALES"**
3. Selecciona **"ID de cliente de OAuth 2.0"**
4. Tipo de aplicación: **"Aplicación web"**
5. Nombre: `Taco'Os Backend API`
6. Orígenes autorizados de JavaScript: (deja vacío por ahora)
7. URIs de redirección autorizados: (deja vacío por ahora)
8. Haz clic en **"Crear"**
9. **Copia TANTO el Client ID como el Client Secret**

---

## 📝 Paso 6: Configurar OAuth Consent Screen

### 6.1 Configurar Pantalla de Consentimiento

1. Ve a: **"APIs y servicios" > "Pantalla de consentimiento de OAuth"**
   - URL: https://console.cloud.google.com/apis/credentials/consent
2. Tipo de usuario: **"Externo"** (para testing) o **"Interno"** (solo tu organización)
3. Haz clic en **"Crear"**

### 6.2 Información de la Aplicación
- Nombre de la aplicación: `Taco'Os`
- Correo de asistencia: Tu correo electrónico
- Logo de la aplicación: (opcional, puedes agregarlo después)
- Dominios de la aplicación: (opcional por ahora)
- Correo de contacto del desarrollador: Tu correo electrónico
- Haz clic en **"Guardar y continuar"**

### 6.3 Scopes (Permisos)
- Haz clic en **"Agregar o quitar ámbitos"**
- Selecciona:
  - `email` (ver tu dirección de correo electrónico)
  - `profile` (ver tu información personal)
- Haz clic en **"Guardar y continuar"**

### 6.4 Usuarios de Prueba (si eligiste "Externo")
- Haz clic en **"+ ADD USERS"**
- Agrega tu correo electrónico para poder probar
- Haz clic en **"Guardar y continuar"**
- Haz clic en **"Volver al panel"**

---

## 🔧 Paso 7: Configurar la App Flutter

### 7.1 Crear Archivo de Configuración Android

Crea el archivo: `android/app/google-services.json`

**IMPORTANTE:** Este archivo NO debe ir al repositorio Git. Agrégalo a `.gitignore`

Estructura básica (obtendrás el real desde Firebase o Google Cloud):
```json
{
  "project_info": {
    "project_id": "tu-proyecto-id"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789:android:abcdef",
        "android_client_info": {
          "package_name": "com.tacos.taco_os_app"
        }
      },
      "oauth_client": [
        {
          "client_id": "TU_ANDROID_CLIENT_ID.apps.googleusercontent.com",
          "client_type": 3
        }
      ]
    }
  ]
}
```

### 7.2 Configurar iOS

Edita el archivo: `ios/Runner/Info.plist`

Agrega antes del tag `</dict>` final:

```xml
<!-- Google Sign-In Configuration -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Reemplaza con tu REVERSED iOS Client ID -->
            <string>com.googleusercontent.apps.TU_IOS_CLIENT_ID_INVERTIDO</string>
        </array>
    </dict>
</array>
<key>GIDClientID</key>
<string>TU_IOS_CLIENT_ID.apps.googleusercontent.com</string>
```

**Ejemplo del REVERSED Client ID:**
Si tu iOS Client ID es: `123456-abc.apps.googleusercontent.com`
El reversed sería: `com.googleusercontent.apps.123456-abc`

---

## 🌍 Paso 8: Variables de Entorno para el Backend

### 8.1 Crear Archivo `.env` en el Backend

```env
# Google OAuth 2.0 Configuration
GOOGLE_CLIENT_ID=TU_WEB_CLIENT_ID.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=TU_WEB_CLIENT_SECRET

# JWT Configuration
JWT_SECRET=tu-secret-key-muy-segura-aqui
JWT_EXPIRATION=12h
```

**IMPORTANTE:** Este archivo NO debe ir al repositorio. Agrégalo a `.gitignore`

### 8.2 Usar las Variables en el Backend

```javascript
// En Node.js/Express
const { OAuth2Client } = require('google-auth-library');
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

async function verifyGoogleToken(idToken) {
  const ticket = await client.verifyIdToken({
    idToken: idToken,
    audience: process.env.GOOGLE_CLIENT_ID,
  });
  const payload = ticket.getPayload();
  return payload;
}
```

---

## ✅ Checklist de Verificación

Antes de ejecutar la app, verifica que:

- [ ] Proyecto creado en Google Cloud Console
- [ ] Google Identity Toolkit API habilitada
- [ ] OAuth 2.0 Client ID para Android creado
- [ ] SHA-1 certificate fingerprint agregado
- [ ] OAuth 2.0 Client ID para iOS creado
- [ ] Bundle ID correcto configurado
- [ ] OAuth 2.0 Client ID Web creado (para backend)
- [ ] Pantalla de consentimiento OAuth configurada
- [ ] Usuarios de prueba agregados (si es necesario)
- [ ] `google-services.json` creado en Android (si usas Firebase)
- [ ] `Info.plist` configurado en iOS con Client ID
- [ ] Variables de entorno configuradas en el backend
- [ ] `.gitignore` actualizado para excluir secretos

---

## 🐛 Solución de Problemas Comunes

### Error: "PlatformException(sign_in_failed)"
- Verifica que el SHA-1 esté correcto
- Verifica que el nombre del paquete Android coincida
- Limpia y reconstruye: `flutter clean && flutter pub get`

### Error: "API has not been enabled"
- Ve a Google Cloud Console → APIs y servicios → Biblioteca
- Busca "Google Sign-In API" y habilítala

### Error: "The OAuth client was not found"
- Verifica que los Client IDs estén correctos en `Info.plist` (iOS)
- Verifica que `google-services.json` exista (Android)

### Error en el Backend: "Token verification failed"
- Verifica que uses el Web Client ID correcto
- Verifica que el token no haya expirado
- Verifica que la audience en el backend coincida con el Client ID

---

## 📚 Recursos Adicionales

- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Google Cloud Console](https://console.cloud.google.com/)
- [OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Flutter Android Setup](https://firebase.google.com/docs/flutter/setup?platform=android)
- [Flutter iOS Setup](https://firebase.google.com/docs/flutter/setup?platform=ios)

---

## 🔐 Seguridad

### Buenas Prácticas:
1. **NUNCA** hagas commit de:
   - `google-services.json`
   - Client Secrets
   - Archivos `.env`
   - Keystores de producción

2. **SIEMPRE** agrega a `.gitignore`:
   ```
   # Google Services
   **/google-services.json
   **/GoogleService-Info.plist
   
   # Environment variables
   .env
   .env.local
   
   # Keystores
   *.keystore
   *.jks
   ```

3. **USA** diferentes Client IDs para:
   - Desarrollo (debug)
   - Producción (release)

4. **REVOCA** Client IDs comprometidos inmediatamente en Google Cloud Console

---

## 📞 Contacto

Si tienes dudas, consulta:
- Documentación oficial de Google Sign-In
- Stack Overflow con tag [google-sign-in] + [flutter]
- Repositorio oficial: https://github.com/flutter/packages/tree/main/packages/google_sign_in

---

**Última actualización:** Enero 2025
**Versión:** 1.0
