# Diccionario de Datos Detallado - Taco'Os POC

Este documento describe campo por campo cada tabla existente y las proyectadas, garantizando que el diseño de persistencia sea robusto y escalable.

---

## 1. Tablas EXISTENTES (Implementadas en Room v7 / Backend Parcial)

### 1.1 Tabla: `users`
*Maneja el perfil del usuario activo.*

| Campo | Tipo | Nivel | Descripción |
| :--- | :--- | :--- | :--- |
| `id` | String (UUID) | Ambos | ID maestro generado por el servidor. |
| `idGoogle` | String | Ambos | ID único de la cuenta de Google. |
| `nombre` | String | Ambos | Nombre completo o nickname del usuario. |
| `email` | String | Ambos | Correo electrónico de contacto. |
| `rol` | String | Ambos | "dueño", "administrador" o "cajero". |
| `negocioId` | String? | Ambos | Vínculo con la tabla establishment/business. |

### 1.2 Tabla: `business`
*Datos del establecimiento comercial.*

| Campo | Tipo | Nivel | Descripción |
| :--- | :--- | :--- | :--- |
| `id` | String (UUID) | Ambos | ID único del negocio. |
| `nombre` | String | Ambos | Nombre comercial del local. |
| `direccion` | String | Ambos | Ubicación física. |
| `telefono` | String | Ambos | Teléfono de contacto. |
| `moneda` | String | Ambos | Siglas de moneda (ej: MXN, USD). |
| `dineroBase` | Double | Ambos | Fondo de caja estándar sugerido. |

### 1.3 Tabla: `sales`
*Registro detallado de transacciones de venta.*

| Campo | Tipo | Nivel | Descripción |
| :--- | :--- | :--- | :--- |
| `id` | Long (Auto) | Local | ID único incremental en el celular. |
| `amount` | Double | Ambos | Monto total cobrado. |
| `userId` | String | Ambos | ID del cajero que realizó la venta (para reportes). |
| `productsJson` | String (Text) | Ambos | Lista serializada de productos vendidos en esa nota. |
| `method` | String | Ambos | "Efectivo" o "Tarjeta". |
| `status` | String | Ambos | "ACTIVE" (Cobrada) o "CANCELLED". |
| `imagePath` | String? | Local | Ruta al archivo JPG del voucher (solo tarjeta). |
| `timestamp` | Long | Ambos | Fecha y hora exacta de la transacción. |
| `negocioId` | String | Ambos | ID del negocio para filtrado maestro. |
| `isSynced` | Boolean | Local | Marca para el SyncWorker. |

### 1.4 Tabla: `expenses`
*Egresos operativos del turno.*

| Campo | Tipo | Nivel | Descripción |
| :--- | :--- | :--- | :--- |
| `id` | String (UUID) | Ambos | ID único del gasto. |
| `detail` | String | Ambos | Concepto del gasto (ej: "Compra de limones"). |
| `amount` | Double | Ambos | Monto del egreso. |
| `cashier` | String | Ambos | Nombre o ID de quien registró el gasto. |
| `imagePath` | String? | Local | Ruta al archivo JPG del ticket de compra. |
| `timestamp` | Long | Ambos | Fecha y hora del registro. |
| `negocioId` | String | Ambos | Vínculo con el negocio. |
| `isSynced` | Boolean | Local | Control de sincronización. |

### 1.5 Tabla: `products`
*Catálogo de artículos en venta.*

| Campo | Tipo | Nivel | Descripción |
| :--- | :--- | :--- | :--- |
| `id` | String (UUID) | Ambos | ID único del producto. |
| `name` | String | Ambos | Nombre del producto (ej: "Taco Pastor"). |
| `price` | Double | Ambos | Precio unitario actual. |
| `category` | String | Ambos | "Comidas", "Bebidas", "Postres". |
| `imagePath` | String? | Local | Ruta a la foto personalizada en el disco del cel. |
| `negocioId` | String | Ambos | Propietario del catálogo. |

### 1.6 Tabla: `app_metadata`
*Control técnico y licencias.*

| Campo | Tipo | Nivel | Descripción |
| :--- | :--- | :--- | :--- |
| `id` | Int (Primary) | Local | Siempre 1 (Single Row). |
| `lastLoginTimestamp` | Long | Local | Para forzar logout tras 12h. |
| `lastMasterSyncTimestamp` | Long | Local | Última vez que validó licencia (24h offline). |
| `isLicenseValid` | Boolean | Local | Estado de suscripción. |

---

## 2. Tablas FALTANTES (Diseño para Próxima Implementación)

### 2.1 Tabla: `cash_sessions` (CORTES)
*Sustituye al ShiftManager actual de memoria por persistencia física.*

| Campo | Tipo | Nivel | Descripción |
| :--- | :--- | :--- | :--- |
| `id` | String (UUID) | Ambos | ID único del turno/corte. |
| `openUserId` | String | Ambos | ID del cajero que abrió la caja. |
| `openTimestamp` | Long | Ambos | Fecha/Hora de apertura. |
| `initialCash` | Double | Ambos | Fondo de caja inicial ingresado. |
| `closeTimestamp` | Long? | Ambos | Fecha/Hora de cierre. |
| `totalSalesCash` | Double | Ambos | Suma de ventas en efectivo. |
| `totalSalesCard` | Double | Ambos | Suma de ventas con tarjeta. |
| `totalExpenses` | Double | Ambos | Suma de gastos realizados. |
| `realCash` | Double | Ambos | Dinero físico contado por el cajero al cerrar. |
| `difference` | Double | Ambos | Sobrante o faltante detectado. |
| `status` | String | Ambos | "OPEN" o "CLOSED". |
| `negocioId` | String | Ambos | ID del establecimiento. |

### 2.2 Tabla: `incident_logs`
*Para diagnóstico de soporte técnico.*

| Campo | Tipo | Nivel | Descripción |
| :--- | :--- | :--- | :--- |
| `id` | String (UUID) | Local | ID único del error. |
| `errorCode` | Int | Local | Código HTTP (403, 404, 500). |
| `errorMessage` | String | Local | Mensaje descriptivo del error. |
| `endpoint` | String | Local | URL que falló. |
| `timestamp` | Long | Local | Momento del fallo. |
| `isReported` | Boolean | Local | Si el usuario ya pulsó "Reportar Fallo". |

### 2.3 Tabla: `support_tickets`
*Mensajería de asistencia al cliente.*

| Campo | Tipo | Nivel | Descripción |
| :--- | :--- | :--- | :--- |
| `id` | String (UUID) | Ambos | ID del hilo de soporte. |
| `userId` | String | Ambos | Usuario que solicita ayuda. |
| `subject` | String | Ambos | Título del problema. |
| `status` | String | Ambos | "OPEN", "IN_PROGRESS", "CLOSED". |
| `lastMessage` | String | Ambos | Previsualización del último mensaje. |
| `unreadCount` | Int | Local | Contador de mensajes nuevos del soporte. |

### 2.4 Tabla: `categories`
*Estructura dinámica de categorías (actualmente estática).*

| Campo | Tipo | Nivel | Descripción |
| :--- | :--- | :--- | :--- |
| `id` | String | Ambos | ID de la categoría. |
| `name` | String | Ambos | Nombre (ej: "Salsas y Guarniciones"). |
| `iconName` | String | Ambos | Nombre del icono Material a mostrar. |
| `negocioId` | String | Ambos | Pertenece al catálogo del negocio. |
