# Taco'Os — Asistente de Ventas para Micro-Negocios

> **Misión:** Democratizar la inteligencia financiera para micro-negocios informales.
> **Filosofía:** "Finanzas como el alma del negocio". El sistema es un aliado silencioso: analiza, alerta y sugiere sin abrumar.
> **Competimos contra la libreta, no contra sistemas contables.**

---

## El Ecosistema

### 1. Interfaz Radical (Modo Cajero)
Tres botones. Sin aprendizaje. Sin distracciones.

| Botón | Acción |
|-------|--------|
| **Ventas** | Cobro rápido con catálogo fijo (Comida, Bebidas, Postres) + teclado numérico 9 dígitos |
| **Gastos** | Registro veloz de salidas del turno (ej: servilletas, hielo) |
| **¿Cómo voy?** | Vista previa al corte: total de ventas, gastos, métodos de pago |

### 2. Dashboard Patrón (3+1+1+🔔)

| Elemento | Función |
|----------|---------|
| **Ventas** | Toggle directo a Modo Cajero (el dueño también cobra) |
| **Reportes** | Cajas Abiertas, Lista de Cortes, Estadísticas comparativas |
| **Equipo** | Lista de cajeros, generar QR de enlace, desvincular con seguridad |
| **⚙️** | Productos, Sucursales (con upsell), Mi Plan |
| **☰** | Perfil, Dark Mode, Ayuda |
| **🔔** | Notificaciones: cancelaciones, sobrantes/faltantes, auto-cierres |

### 3. Onboarding Mágico (QR Handshake)
- Cajero elige rol → cámara se abre automáticamente
- Patrón genera QR desde "Equipo"
- Escaneo → enlace instantáneo con datos de perfil Google
- Cajero va directo a cobrar. Sin formularios.

### 4. Corte y Cierre de Caja
- Confirmación → Resumen (ventas, efectivo, tarjeta, gastos, fondo)
- Conteo manual del efectivo físico → sobrante o faltante
- Ticket digital imprimible/compartible
- Auto-cierre: hora configurada + 180 min → notificación 🔔

### 5. Anti-Fraude (Cancelación)
- Ventana de 5 minutos para cancelar
- Foto obligatoria del producto devuelto
- Notificación 🔔 inmediata al Patrón

---

## Modelo de Negocio

| Plan | Negocios | Cajeros | IA | Trial |
|------|----------|---------|-----|-------|
| **Free** | 1 | 2 | 1 consejo semanal gratis | — |
| **Premium** | 2 | 5 | IA limitada | 14 días |
| **Business** | 5 | 25 | IA completa | 14 días |

- Free es perpetuo y funcional. El negocio opera mejor que con libreta desde el día 1.
- Free incluye 1 consejo semanal de IA (reporte básico de tendencias).
- Premium tiene IA limitada (insights diarios, proyecciones básicas).
- Business tiene IA completa (insights, proyecciones, alertas, predicciones).
- 14 días trial con funciones del plan superior para incentivar la conversión.

---

## Stack Técnico

| Capa | Tecnología | Rol |
|------|-----------|-----|
| **App** | Flutter + SQLite/Room | Base maestra local. 100% operable sin internet. |
| **Backend** | Spring Boot 3.5 + H2 (dev) / PostgreSQL (prod) | Consolidación, reportes, licencias, notificaciones. |
| **Sync** | REST batch cada 5 min | Worker en segundo plano. Servidor es esclavo. |
| **Auth** | Google Sign-In + token base64 (placeholder) | Sesión larga (turno). 12hr en segundo plano requiere re-login. JWT pendiente. |
| **ORM** | JPA + Hibernate + Flyway | Migraciones + ddl-auto: update |

---

## Equipo

| Persona | Rol |
|---------|-----|
| Jesús Medina | Backend (Spring Boot) |
| Fanner | Flutter + Frontend |
| Leandro | Data Science (Fase III+) |

---

## Convenciones del Proyecto

- **Package base:** `com.jmcsoft.taco_os`
- **Idioma:** Español en clases, métodos, variables, DTOs
- **URLs:** Inglés en endpoints (ej: `/api/v1/auth/verificar/{idGoogle}`)
- **Controller:** Máximo 4 líneas por método
- **DTOs:** Java records con `@JsonProperty` para sincronizar nombres del contrato
- **Mapper:** MapStruct `componentModel = "spring"`
- **Entidades:** Lombok `@Data`
- **Dinero:** `BigDecimal`, nunca `Double`
- **IDs:** `UUID` con `GenerationType.UUID`
- **Tablas separadas por rol:** `negocios`, `administradores`, `cajeros` (no tabla única de usuarios)

---

## Fases del Proyecto

| Fase | Enfoque | Estado |
|------|---------|--------|
| **I — Control Operativo** | Transacciones, corte, reportes básicos | ✅ Completo |
| **II — Lealtad y WhatsApp CRM** | Recibos, puntos, QR premios | ⏳ Pendiente |
| **III — IA y Reportes Avanzados** | Insights, proyecciones, alertas | ⏳ Pendiente |
| **IV — QR Digital y Menú** | Pedidos en mesa, inventario | ⏳ Pendiente |
| **V — Materias Primas** | Abasto inteligente con IA | ⏳ Pendiente |
