# Documentación Técnica - Arquitectura

## 1. Persistencia y Sincronización
*   **Local DB (SQLite/Room):** Almacenamiento de operaciones de los últimos 3 días (Tabla `sales`).
*   **AppMetadata:** Control de sesiones y licencias (Tabla `app_metadata`).
*   **Sincronización:** Cada 5-10 minutos hacia el servidor principal vía `TacoApi#syncBatch`.
*   **Modo Offline:** Capacidad de operar hasta 12 horas sin conexión a internet tras el login inicial.

## 2. Seguridad y Sesión
*   **Autenticación:** Google Sign-In como método único/principal.
*   **Tokens:** Duración de 12 horas (43,200,000 ms configurados en backend).
*   **Intercepción:** Interceptor de OkHttp (`TacoApp.kt`) que inyecta automáticamente el token JWT en la cabecera `Authorization: Bearer`.
*   **Manejo de Errores:** `NetworkUtils` parsea los cuerpos JSON de error del backend para mostrar mensajes precisos (`mensaje`, `campos`, etc.) al usuario.

## 3. Paleta de Colores (Inspiración iOS/Fintech)
*   **Primary (ActionBlue):** `#007AFF` (Azul iOS) para acciones principales.
*   **Background:** `#F2F2F7` (Gris claro Apple).
*   **Surface:** `#FFFFFF` (Blanco puro).
*   **Trust Navy:** `#002D72` (Para textos y títulos de confianza).

## 4. Pendientes (Incidencias)
*   [ ] Integración real de Google Sign-In SDK.
*   [ ] Implementación de Room para caché de 3 días.
*   [ ] Endpoints de validación de rol por Google ID.
