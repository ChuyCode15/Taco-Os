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
El dueño gestiona su negocio con una pantalla limpia:

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
- Corte no cierra sesión. El turno sigue hasta cierre manual o 12hr en segundo plano.

### 5. Anti-Fraude (Cancelación)
- Ventana de 5 minutos para cancelar
- Foto obligatoria del producto devuelto
- Notificación 🔔 inmediata al Patrón

---

## Modelo de Negocio

| Plan | Negocios | Cajeros/Empleados | IA      | Trial |
|------|----------|-------------------|---------|-------|
| **Free** | 1 | 2 cajeros | ❌       | — |
| **Premium** | 2 | 5 cajeros | ✅       | 14 días |
| **Business** | 5 | 25 empleados | ✅       | 14 días |

- Free es perpetuo y funcional. El negocio opera mejor que con libreta desde el día 1.
- 14 días trial con funciones del plan superior para incentivar la conversión.

---

## Stack Técnico

| Capa | Tecnología | Rol |
|------|-----------|-----|
| **App** | Flutter + SQLite/Room | Base maestra local. 100% operable sin internet. |
| **Backend** | Spring Boot + PostgreSQL | Consolidación, reportes, licencias, notificaciones. |
| **Sync** | REST batch cada 5 min | Worker en segundo plano. Servidor es esclavo. |
| **Auth** | Google Sign-In + JWT | Sesión larga (turno). 12hr en segundo plano requiere re-login. |
| **Arquitectura** | Multi-tenant por business_id | Datos aislados para IA futura. |

---

## Fases del Proyecto

| Fase | Enfoque | Estado |
|------|---------|--------|
| **I — Control Operativo** | Transacciones, corte, reportes básicos | ✅ En desarrollo |
| **II — Lealtad y WhatsApp CRM** | Recibos, puntos, QR premios | ⏳ Pendiente |
| **III — IA y Reportes Avanzados** | Insights, proyecciones, alertas | ⏳ Pendiente |
| **IV — QR Digital y Menú** | Pedidos en mesa, inventario | ⏳ Pendiente |
| **V — Materias Primas** | Abasto inteligente con IA | ⏳ Pendiente |
