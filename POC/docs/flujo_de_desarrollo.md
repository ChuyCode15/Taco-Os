# Flujo de Desarrollo - Taco'Os POC

## 🔄 0. Ciclo de Vida del Usuario
El sistema se centra en la seguridad de Google. Todo usuario debe autenticarse para interactuar con la plataforma.

### 0.1. Autenticación (Google First)
1.  **Vista de Bienvenida (1.0.0):** Imagen alegórica, botones de Login y Registro.
2.  **Selección de Google ID (1.0.1):** Integración nativa con cuentas de Google.
3.  **Verificación de Rol (1.0.2):** Consulta al backend para determinar si el usuario es Administrador, Cajero o Nuevo.

## 👥 1. Flujos por Rol

### 1.1. Administrador (Admin)
*   **1.1.1. Registro de Negocio:** Formulario inicial para usuarios sin negocio asignado.
*   **1.1.2. Dashboard Admin:** Resumen visual, acceso a Ventas, Reportes y Gestión de Cajeros.
*   **1.1.3. Gestión de Equipo:** Generación de códigos QR/Invitaciones para cajeros.

### 1.2. Cajero
*   **1.2.1. Asignación:** Ingreso de código, alerta al patrón o escaneo QR.
*   **1.2.2. Dashboard Ventas:** POS simplificado (KISS) para registro rápido de transacciones.

## 🏗 2. Reglas de Diseño y Rendimiento (KISS & High Performance)
*   **Simplicidad:** Máximo 3 opciones principales por pantalla.
*   **Rendimiento Local:** Toda operación de venta/cobro se realiza en la DB local (Room) para latencia cero.
*   **Sincronización:** Cada 5-10 minutos en segundo plano (si hay red).
*   **Resiliencia:** Soporta hasta 5 horas (o más) sin internet sin afectar la operación.

## 🔐 3. Seguridad y Licenciamiento
*   **Sesión Activa:** El token de Google dura 12 horas. Login obligatorio al inicio del turno.
*   **Check de Licencia:** Reporte obligatorio al Servidor Maestro cada 24 horas.
*   **Bloqueo Preventivo:** Si la app no se sincroniza con el servidor central en >24 horas, se bloquean las funciones de venta hasta validar licencia.
*   **Cero Interrupciones:** Una vez logueado, el usuario no vuelve a ver pantallas de seguridad durante su turno de 12 horas.
