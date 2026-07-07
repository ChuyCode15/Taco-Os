# Documentación Técnica - Taco'Os POC

## 1. Persistencia y Sincronización
*   **Local DB (SQLite/Room):** Almacenamiento de operaciones inmutables tras el corte.
*   **AppMetadata:** Control de sesiones y licencias (Tabla `app_metadata`).
*   **Sincronización:** Cada 5-10 minutos hacia el servidor principal vía `TacoApi#syncBatch`.
*   **Modo Offline:** Capacidad de operar hasta 12 horas sin conexión a internet tras el login inicial.
*   **Schema:** `exportSchema = false` para simplificar el despliegue en etapa POC.

## 2. Seguridad y Sesión
*   **Autenticación:** Google Sign-In como método único/principal (Bienvenidos/Latinoamérica).
*   **Tokens:** Duración de 12 horas.
*   **Manejo de Errores:** 
    *   Error 404 en Login: Indica que el usuario no existe y redirige al flujo de Registro de Rol y Negocio.
*   **Inmutabilidad:** Las ventas son inmutables después de 5 minutos de su creación o una vez realizado el Cierre de Corte.

## 3. Interfaz de Usuario (Apple-like / Clean Code)
*   **Estilo:** Basado en componentes iOS con bordes muy redondeados (20dp-32dp) y transparencias (Glassmorphism).
*   **Modo Oscuro:** Inspiración Duolingo (Fondo gris profundo `#1B1B1B` con formas vectoriales sutiles en Canvas).
*   **Navegación:** Menú lateral (Hamburger) persistente en vistas operativas para acceso a Ajustes y Modo Oscuro.
*   **Feedback:** Animación de sacudida (Shake) y sonidos de sistema para notificaciones entrantes.

## 4. Módulos Operativos (POS)
*   **Caja:** Sistema de bloqueo si la caja no ha sido abierta.
*   **Ventas:** 
    *   Registro con indicadores visuales: Verde (Efectivo), Azul (Tarjeta), Rojo (Cancelada).
    *   Módulo de Nueva Venta con selector de categorías (Comidas, Bebidas, Postres) y teclado numérico dedicado.
*   **Cierre de Corte:** Reporte consolidado de Efectivo vs Tarjeta con seguridad de doble confirmación.
*   **Soporte:** Burbuja flotante de chat con indicador de mensajes nuevos, minimizable.

## 5. Horarios de Negocio
*   **Selector Inteligente:** Permite horario único para toda la semana o desglose individual por día mediante `TimePickerDialog`.
