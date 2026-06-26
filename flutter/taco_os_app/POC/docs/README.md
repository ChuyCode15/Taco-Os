# Taco'Os POC - Enterprise Edition 🌮

## 📌 0. Introducción
Taco'Os es una solución nativa de punto de venta (POS) y administración financiera diseñada para micronegocios informales. El sistema prioriza la simplicidad extrema (KISS), la seguridad a través de Google y una interfaz de alta calidad inspirada en los estándares de iOS.

## 🎯 1. Objetivo
Proporcionar una herramienta profesional y confiable para que los dueños de negocios ("Administradores") y sus empleados ("Cajeros") gestionen ventas, gastos y reportes de manera eficiente y segura.

## 🛠 2. Tecnologías Clave
*   **Lenguaje:** Kotlin 1.9.24
*   **UI Framework:** Jetpack Compose (Moderno, Declarativo)
*   **Base de Datos:** Room (Local, Offline-First)
*   **Networking:** Retrofit + GSON (Conexión con Backend Spring Boot)
*   **Arquitectura:** MVVM + Repository (Clean Architecture)
*   **Sync:** WorkManager (Sincronización en segundo plano)

## 📂 3. Estructura del Proyecto
*   `app/src/main/kotlin/com/tacoos/poc/ui`: Componentes de interfaz y temas.
*   `app/src/main/kotlin/com/tacoos/poc/data`: Repositorios y fuentes de datos (Local/Remoto).
*   `app/src/main/kotlin/com/tacoos/poc/sync`: Lógica de sincronización.
*   `docs/`: Documentación detallada del proyecto.

---
© 2026 Taco'Os - Operaciones de Alimentos
