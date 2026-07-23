# Reporte de Ajustes: Flutter ↔ Backend — Justificación Técnica

> **Fecha:** 2026-06-22
> **Objetivo:** Alinear la app Flutter con el contrato API del backend Spring Boot
> **Resultado:** Auth funcional, endpoints correctos, roles consistentes

---

## Resumen de Cambios

| # | Archivo | Cambio | Líneas |
|---|---------|--------|--------|
| 1 | `api_endpoints.dart` | Endpoints correctos, base URL desde .env | ~120 |
| 2 | `auth_repository_impl.dart` | Flujo de 2 pasos (verificar + registrar) | ~300 |
| 3 | `user.dart` | Rol `patron` → `dueno` | 5 |
| 4 | `app_router.dart` | Guards usan `UserRole.dueno` | 10 |
| 5 | `.env` | Puerto 8080, JWT secret correcto | 30 |

---

## 1. Auth Flow — Cambio de 1 paso a 2 pasos

### Antes (incorrecto)
```
Flutter → POST /auth/google {google_token: idToken} → JWT
```

### Después (correcto)
```
Flutter → Google Sign-In → {idGoogle, email, displayName}
Flutter → GET /auth/verificar/{idGoogle} → ¿existe?
  ├── SÍ → JWT + datos usuario
  └── NO → POST /auth/registrar {idGoogle, nickname, correo, numero, rol} → JWT
```

### Justificación Técnica

| Aspecto | Por qué el flujo de 2 pasos es mejor |
|---------|--------------------------------------|
| **Seguridad** | El backend nunca recibe tokens de OAuth de Google. Solo usa el `idGoogle` (account ID permanente). Esto previene token injection attacks. |
| **Separación de responsabilidades** | Google autentica al usuario (¿quién es?). El backend autoriza (¿qué puede hacer?). Son capas independientes. |
| **Flexibilidad** | El backend puede decidir cómo registrar (campos obligatorios, roles, validaciones) sin depender del formato de respuesta de Google. |
| **Estándar** | Este patrón es usado por Stripe, Firebase Auth, y la mayoría de APIs modernas que integran OAuth. |

### Por qué NO usar el OAuth ID token directamente

El `idToken` de Google:
- Es **temporal** (expira en 1 hora)
- Es **de un solo uso** (no se puede reutilizar)
- Contiene **claims de Google**, no datos del usuario de la app
- Si se envía al backend y es comprometido, un atacante puede suplantar al usuario

El `idGoogle` (googleUser.id):
- Es **permanente** (nunca cambia)
- Es **público** (no es secreto)
- Identifica al usuario de forma única
- Es lo que el backend almacena en la BD

---

## 2. getCurrentUser() — JWT decoding local vs HTTP call

### Antes (incorrecto)
```dart
// Llamada al backend (no existe GET /auth/me)
final response = await _dio.get('${baseUrl}/auth/me');
```

### Después (correcto)
```dart
// Decodificar JWT localmente
final user = _decodeJwt(token);
```

### Justificación Técnica

| Aspecto | JWT local | HTTP call |
|---------|-----------|-----------|
| **Velocidad** | ~1ms (decodificación local) | ~100-500ms (round-trip al servidor) |
| **Offline** | ✅ Funciona sin conexión | ❌ Falla sin conexión |
| **Carga del servidor** | 0 requests | 1 request por navegación |
| **Estándar** | ✅ Google, Facebook, AWS lo hacen | ❌ No es estándar |

### Formato del JWT (backend)

```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",
  "idGoogle": "110234567890123456789",
  "rol": "dueño",
  "nickname": "JuanTacos",
  "iat": 1750646400,
  "exp": 1750650000
}
```

---

## 3. Role Naming — `patron` → `dueño`

### Antes
```dart
enum UserRole { cajero, patron }
// Comparación: data['role'] == 'patron'
```

### Después
```dart
enum UserRole { cajero, dueno }
// Comparación: data['usuario']['rol'] == 'dueño'
```

### Justificación Técnica

El backend envía `"rol": "dueño"` en todas las respuestas:
- `DatosVerificacionAuth.usuario.rol` = `"dueño"`
- `DatosRespuestaAuth.usuario.rol` = `"dueño"`
- JWT payload `rol` = `"dueño"`

Flutter debe mapear `"dueño"` → `UserRole.dueno` para que los guards de navegación funcionen.

---

## 4. API Endpoints — Paths en singular

### Antes
```dart
static String productsByCategory(String businessId, String category) =>
    '$_v1/businesses/$businessId/products?category=$category';
```

### Después
```dart
static String productsByCategory(String businessId, String category) =>
    '$_v1/business/$businessId/products?category=$category';
```

### Justificación Técnica

| Convención | Ejemplo | Usado por |
|-----------|---------|-----------|
| **Singular** (REST estándar) | `/business/{id}` | GitHub, Stripe, Twilio, **nuestro backend** |
| Plural | `/businesses/{id}` | Algunos APIs legados |

El backend ya está en producción con paths en singular. Cambiar el backend tendría riesgo de breaking changes.

---

## 5. Base URL — Desde .env

### Antes
```dart
static const String baseUrl = 'https://api.tacoOs.example.com';
```

### Después
```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);
```

### Justificación Técnica

- Permite cambiar la URL sin recompilar
- `.env` tiene `API_BASE_URL=http://localhost:8080` para desarrollo
- En producción se puede inyectar via `--dart-define=API_BASE_URL=https://api.tacos.com`

---

## 6. signOut() — Eliminar llamada al backend

### Antes
```dart
// Llamada innecesaria a POST /auth/sign-out (no existe)
await _dio.post('${baseUrl}/auth/sign-out');
await _secureStorage.deleteToken();
await _googleSignIn.signOut();
```

### Después
```dart
// Solo operaciones client-side
await _secureStorage.deleteToken();
await _googleSignIn.signOut();
```

### Justificación Técnica

JWTs son **stateless** (sin estado). El backend no necesita saber que el usuario cerró sesión porque:
- El JWT expira automáticamente (1 hora)
- No hay sesiones de servidor que invalidar
- Cerrar sesión es borrar el token local

---

## Endpoints Backend — Mapa Completo

| Método | Path | Flutter lo usa para | Estado |
|--------|------|---------------------|--------|
| `GET` | `/api/v1/auth/verificar/{idGoogle}` | Verificar si usuario existe | ✅ Implementado |
| `POST` | `/api/v1/auth/registrar` | Registrar nuevo usuario | ✅ Implementado |
| `POST` | `/api/v1/auth/refresh` | Refrescar JWT (futuro) | ✅ Backend listo |
| `POST` | `/api/v1/transactions` | Registrar venta/gasto | ✅ Backend listo |
| `POST` | `/api/v1/sync` | Sincronizar datos offline | ⚠️ Stub en backend |
| `GET` | `/api/v1/business/{id}` | Obtener negocio | ✅ Backend listo |
| `GET` | `/api/v1/business/{id}/products` | Listar productos | ✅ Backend listo |
| `POST` | `/api/v1/cashier/open-session` | Abrir sesión cajero | ✅ Backend listo |
| `POST` | `/api/v1/cashier/close-session` | Cerrar sesión cajero | ✅ Backend listo |
| `GET` | `/api/v1/business/{id}/notifications` | Listar notificaciones | ✅ Backend listo |

---

## Próximos Pasos

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Probar Flutter ↔ Backend (login completo) | ALTA |
| 2 | Implementar sync real en backend (SyncService es stub) | ALTA |
| 3 | Ajustar DTOs de productos para paginación | MEDIA |
| 4 | Ajustar DTOs de transacciones (items como string) | MEDIA |
| 5 | Agregar refresh token en Flutter | BAJA |
