# Documentación Técnica - Taco'Os POC

## 1. Arquitectura Modular (SOLID)
La aplicación sigue los principios SOLID para garantizar un código mantenible y escalable:
*   **Single Responsibility (SRP):** Los componentes de UI están separados de la lógica de negocio y los modelos de datos.
*   **Open/Closed (OCP):** Uso de componentes genéricos como `TacoDialog` que permiten extender la funcionalidad sin modificar la base.
*   **Inyección de Dependencias:** La navegación y los estados se inyectan a través de parámetros y callbacks, facilitando las pruebas y el desacoplamiento.

## 2. Estructura de Archivos
*   `com.tacoos.poc.ui.components`: Contiene componentes reutilizables (`TacoDialog`, `AppleToggle`, `ActionButton`).
*   `com.tacoos.poc.ui.screens`: Pantallas principales de la aplicación.
*   `SalesState.kt`: Centraliza los modelos de datos y la gestión de estado global (`ShiftManager`).

## 3. Persistencia y Sincronización
*   **Local DB (SQLite/Room):** Almacenamiento inmutable tras el cierre de corte.
*   **Sincronización:** Cada 15 minutos vía `SyncWorker`.
*   **Estado de Sesión:** El `ShiftManager` persiste los datos de ventas y gastos durante la ejecución de la app mientras el turno esté abierto.

## 4. Interfaz de Usuario
*   **Estética:** Apple-like con bordes redondeados (`28.dp`) y transparencias.
*   **Altura Dinámica:** Todos los diálogos operativos implementan una altura dinámica (30% min - 90% max) para adaptarse al contenido y al tamaño de pantalla.
*   **Modo Oscuro:** Soporte nativo unificado a través de `TacoOsTheme`.

## 5. Módulos Operativos (POS)
*   **Gestión de Turnos:** Apertura de caja con fondo inicial y cierre con reporte detallado.
*   **Ventas:** Registro inmutable después de 5 minutos.
*   **Gastos:** Registro con captura de evidencia fotográfica (cámara).
