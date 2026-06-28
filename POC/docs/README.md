# Taco OS POC - Sistema de Control de Finanzas

## Visión del Producto
Taco OS es una herramienta de administración para micronegocios informales (puestos de tacos, hamburguesas, etc.) diseñada bajo el principio **KISS (Keep It Simple, Stupid)**. La interfaz busca la elegancia y simplicidad de iOS con la robustez y seguridad de los servicios de Google.

## Pilares del Diseño
- **Simplicidad:** Máximo 3 opciones principales por pantalla.
- **Confianza:** Colores azules profundos y blancos limpios (Psicología financiera).
- **Agilidad:** Funcionamiento offline con sincronización automática.

## Estado Actual
- Implementación de pantallas básicas en Kotlin/Compose (Estilo Apple/iOS).
- **Módulo de Seguridad:** Integración real con Google Sign-In y Backend Spring Boot.
- **Persistencia:** Registro exitoso de Negocios y Usuarios con tokens de 12 horas.
- **Red:** Interceptor de seguridad OkHttp y parseo de errores técnicos (NetworkUtils).
- **Rama de Desarrollo:** `poc/app-kotlin/`
