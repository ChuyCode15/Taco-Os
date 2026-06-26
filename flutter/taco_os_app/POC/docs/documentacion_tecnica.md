# Documentación Técnica - Taco'Os POC

## 🏛 1. Arquitectura de Software
El proyecto sigue el patrón **MVVM (Model-View-ViewModel)** combinado con un **Repository Pattern**.

### 1.1. Capa de Presentación (UI)
*   **1.1.1. Tema:** Implementado en `ui/theme`. Utiliza `Material3` con una paleta personalizada de "Confianza" (Navy/Blue).
*   **1.1.2. Screens:** Cada vista es un Composable independiente.
*   **1.1.3. Navigation:** `NavHost` centralizado en `MainActivity`.

### 1.2. Capa de Datos (Data)
*   **1.2.1. Local Storage (Room):**
    *   `User`: Datos del perfil y rol.
    *   `Business`: Configuración del negocio.
    *   `Sale`: Registro de transacciones (Offline-first).
*   **1.2.2. API Remota (Retrofit):**
    *   Endpoints base en `TacoApi`.
    *   Modelos de datos compartidos en `Models`.

## 🔒 2. Seguridad y Autenticación
*   **2.1. Google ID:** Identificador único global del usuario.
*   **2.2. JWT (Pendiente):** Para asegurar las peticiones al backend.

## 📡 3. Sincronización y Resiliencia (Offline-First)
*   **3.1. WorkManager:** Ejecuta `SyncWorker` cada 15 minutos (mínimo de Android) con reintentos inteligentes.
*   **3.2. Agilidad de Datos:**
    *   Ventas se registran inmediatamente en Room para evitar colas de espera.
    *   La app mantiene al menos 3 días de operaciones localmente para consulta rápida.
    *   Sincronización batch con el servidor cada 5-10 minutos si hay red.
*   **3.3. Modo Desconectado:** La app permite operar hasta por varias horas sin conexión. Si no hay internet por >5 horas, no hay interrupción del servicio.

## 🔐 4. Seguridad y Licenciamiento (Reglas de Oro)
*   **4.1. Token de Google (12h):** Cada 12 horas el usuario debe re-autenticarse con Google para asegurar la identidad.
*   **4.2. Validación de Licencia (24h):** La app debe reportarse con el "Servidor Maestro" al menos una vez cada 24 horas para validar el estado de la suscripción.
*   **4.3. Experiencia de Usuario:** Una vez validado el inicio del turno, no se solicitan contraseñas ni autenticaciones adicionales durante el cobro para maximizar la velocidad de atención.

## 🗺️ 5. Mapa de Endpoints (Backend Local 8080)

| Módulo | Método | Ruta | Descripción |
| :--- | :--- | :--- | :--- |
| **Auth** | GET | `/auth/verificar/{idGoogle}` | Verificar existencia de usuario |
| | POST | `/auth/registrar` | Registro (Admin/Cajero) |
| | POST | `/auth/refresh` | Refrescar token JWT |
| **Negocio** | POST | `/business` | Crear nuevo negocio |
| | GET | `/business/{id}` | Detalle de negocio |
| | PUT | `/business/{id}` | Actualizar negocio |
| | GET | `/business/{id}/cajeros` | Listar cajeros |
| **Enlace** | POST | `/business/invitation` | Generar código QR |
| | POST | `/business/link` | Enlazar cajero |
| **Productos**| POST | `/business/{id}/products` | Crear producto |
| | GET | `/business/{id}/products` | Listar productos |
| **Caja** | POST | `/cashier/open-session` | Abrir sesión |
| | POST | `/cashier/close-session` | Cerrar sesión |
| **Operación**| POST | `/transactions` | Registrar venta/gasto |
| | POST | `/sync` | Sincronización masiva |
| **Licencia** | GET | `/business/{negocioId}/license` | Estado de licencia (24h Check) |

---
*Nota: Todos los endpoints se acceden mediante la URL base configurada en `TacoApi.kt`.*
