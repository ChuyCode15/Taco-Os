# Flujo de Desarrollo y Navegación

## Índice de Vistas

### 1.0 Acceso y Seguridad
*   **1.1 Pantalla de Bienvenida (Landing):** Imagen alegórica, botones de Login y Registro.
*   **1.2 Login (Google Auth):** Cuadro translúcido, integración con Google Identity.
*   **1.3 Registro:** Flujo simplificado vía Google Account. Si el login falla con 404, redirige automáticamente a Selección de Rol.

### 2.0 Selección y Asignación de Rol
*   **2.1 Lógica de Verificación:** GET al backend con Google ID.
*   **2.2 Registro de Usuario:** POST a `/auth/registrar` tras elegir rol.
*   **2.3 Registro de Negocio (Dueño):** POST a `/business` usando el ID obtenido del paso anterior.
*   **2.4 Cashier Assignment (Cajero):** Registro como cajero y espera de vinculación vía QR o código.

### 3.0 Dashboard Administrador (Patrón)
*   **3.1 Dashboard Principal:** 3 botones (Ventas, Reportes, Cajeros).
*   **3.2 Menú Lateral:** Perfil, Modo Oscuro, Ajustes, Ayuda.
*   **3.3 Notificaciones:** Sistema de alertas (Campanita con badge +9).
*   **3.4 Registro de Negocio:** Formulario inicial para nuevos dueños.

### 4.0 Dashboard Ventas (POS Moderno)
*   **4.1 Vista de Ventas:** Interfaz ultra-simple para cobro rápido.
*   **4.2 Control de Caja:** Apertura y cierre de corte.

## Reglas de Interfaz
- Cada nivel de navegación no debe exceder las 3 opciones lógicas.
- El botón "Regresar" debe estar siempre accesible en sub-vistas.
