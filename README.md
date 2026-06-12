# Taco'Os 🎯

**Inteligencia financiera simple para negocios independientes.**

Ser independiente es dar el siguiente paso.  
Tener control es lo que lo hace sostenible.

No competimos contra sistemas contables ni ERPs. Competimos contra la **libreta**.  
Taco'Os es una app de punto de venta diseñada para la taquería de la esquina, la nevería, la tiendita — negocios reales que mueven la economía todos los días y que ahora pueden crecer con mejores herramientas.

---

## El Problema

- Millones de negocios independientes operan sin herramientas claras para tomar decisiones.
- El control del dinero se lleva en **libretas** o de memoria — se pierden ventas, hay errores y no siempre se sabe si realmente se está ganando.
- Las soluciones actuales son caras, complejas o dependen completamente de internet.

## La Solución

Una app simple que te da control desde el primer día:

- **+ Venta** → registra ingresos en segundos
- **- Gasto** → controla lo que sale
- **¿Cómo voy?** → entiende tu negocio sin complicarte

Funciona **sin internet**, permite enviar **recibos por WhatsApp**, incluye **programa de lealtad con QR** y un sistema que impulsa el registro de cada venta de forma natural, ayudando a tener mayor control sin fricción.

---

## Stack Tecnológico

| Capa | Tecnología |
|------|-----------|
| **Frontend** | Flutter (Android + iOS) |
| **Backend** | Spring Boot (Java) |
| **Base de Datos** | PostgreSQL (nube) + SQLite/Room (local) |
| **Sincronización** | Offline-First con Batch Sync cada 5-10 min |
| **IA** | Batch Processing nocturno (Python/Java) |
| **Autenticación** | Google Login + JWT 24h |
| **Mensajería** | WhatsApp Business API |
| **Pagos** | Stripe |
| **Notificaciones** | Firebase Cloud Messaging |

---

## Equipo

| Rol | Nombre | Enfoque |
|-----|--------|---------|
| **Arquitecto / Backend** | Jesus Medina | Spring Boot, API REST, DB, Licencias, DevOps |
| **Flutter + Backend** | Fanner | App Flutter, UI/UX, Sincronización, Batch |
| **Data Science** | Leandro | Modelos de IA, Predicciones, Insights, Segmentación |

---

## Roadmap

| Fase | Enfoque | Entregable |
|------|---------|------------|
| **I** | Control Operativo (MVP) | App con 3 botones, offline, sync, reportes básicos |
| **II** | Lealtad y Anti-Fraude | WhatsApp receipts, programa de lealtad QR, cancelaciones |
| **III** | IA y Reportes | Insights, proyecciones flujo, alerta quiebra, upgrades |
| **IV** | QR Digital | Menú interactivo QR en mesa, inventario |
| **V** | Materias Primas | Reporte sobrantes, predicción IA de pedido diario |

---

## Documentación

Toda la documentación del proyecto está en la carpeta [`Docs/`](Docs/):

| Documento | Descripción |
|-----------|-------------|
| [`TacoOs_Diseno_Tecnico_Consolidado.md`](Docs/TacoOs_Diseno_Tecnico_Consolidado.md) | Diseño técnico completo: misión, arquitectura, UX, datos, monetización |
| [`TacoOs_Flujo_Desarrollo.md`](Docs/TacoOs_Flujo_Desarrollo.md) | Workflow de desarrollo por fase con tareas asignadas al equipo |
| [`contratos_api_v1.md`](Docs/contratos_api_v1.md) | Contratos JSON de la API: endpoints, requests y responses |
| [`tickets_fase1_mvp.csv`](Docs/tickets_fase1_mvp.csv) | Tickets Fase I — MVP (importable a GitHub Projects) |
| [`tickets_fase2_lealtad.csv`](Docs/tickets_fase2_lealtad.csv) | Tickets Fase II — Lealtad y WhatsApp |
| [`tickets_fase3_ia_reportes.csv`](Docs/tickets_fase3_ia_reportes.csv) | Tickets Fase III — IA, Reportes y Licencias |
| [`tickets_fase4_qr.csv`](Docs/tickets_fase4_qr.csv) | Tickets Fase IV — Menú QR Digital |
| [`tickets_fase5_materias_primas.csv`](Docs/tickets_fase5_materias_primas.csv) | Tickets Fase V — Control de Materias Primas |
| [`tickets_generales_infra.csv`](Docs/tickets_generales_infra.csv) | Tickets generales: CI/CD, Play Store, Firebase |

---

## Licencias (Multitenant)

Cada negocio es un **tenant independiente** con su propia licencia:

| Plan | Precio | Negocios | Cajeros | Features |
|------|--------|----------|---------|----------|
| **Free** | $0 | 1 | 2 | Ventas, gastos, recibos WhatsApp, lealtad QR, reportes básicos |
| **Premium** | $199/mes | 2 | 5 | Todo Free + insights IA, reportes detallados, predicción de pedidos |
| **Business** | Próximamente | Ilimitados | Ilimitados | Todo Premium + multi-sucursal |

- La licencia Free no vence. La Premium tiene fecha de expiración.
- Si un Premium vence, baja automáticamente a Free sin perder datos.
- El backend valida límites en cada operación (cajeros, negocios).

---

## Arquitectura

```


┌──────────────────────────────────────────────────┐
│                   Flutter App                    │
│  ┌──────────┐  ┌──────────┐  ┌────────────────┐  │
│  │  Venta   │  │  Gasto   │  │  ¿Cómo voy?    │  │
│  │  (+)     │  │  (-)     │  │  (Dashboard)   │  │
│  └──────────┘  └──────────┘  └────────────────┘  │
│        ↓              ↓              ↓           │
│  ┌──────────────────────────────────────────┐    │
│  │         SQLite / Room (Local DB)         │    │
│  └──────────────────────────────────────────┘    │
│        ↓ (Background Sync cada 5-10 min)         │
└──────────────────────────────────────────────────┘
        ↓
┌──────────────────────────────────────────────────┐
│            Spring Boot API (Backend)             │
│  ┌──────────┐  ┌──────────┐  ┌────────────────┐  │
│  │   Auth   │  │  Sync    │  │  Transactions  │  │
│  │   JWT    │  │  Batch   │  │  CRUD          │  │
│  └──────────┘  └──────────┘  └────────────────┘  │
│  ┌──────────┐  ┌──────────┐  ┌────────────────┐  │
│  │ License  │  │ Reports  │  │  WhatsApp API  │  │
│  │Middleware│  │          │  │                │  │
│  └──────────┘  └──────────┘  └────────────────┘  │
│        ↓              ↓              ↓           │
│  ┌──────────────────────────────────────────┐    │
│  │        PostgreSQL (Consolidated)         │    │
│  └──────────────────────────────────────────┘    │
└──────────────────────────────────────────────────┘
        ↓ (Batch nocturno)
┌──────────────────────────────────────────────────┐
│              Motor de IA (Batch)                 │
│  ┌──────────┐  ┌──────────┐  ┌────────────────┐  │
│  │ Flujo de │  │  Insight │  │   Predicción   │  │
│  │ Caja     │  │  Engine  │  │   Pedidos      │  │
│  └──────────┘  └──────────┘  └────────────────┘  │
└──────────────────────────────────────────────────┘
```

---

## Cómo Empezar

### Backend (Spring Boot)

```bash
cd backend
./mvnw spring-boot:run
```

Variables de entorno necesarias:
- `DATABASE_URL` — PostgreSQL connection string
- `GOOGLE_CLIENT_ID` — Google OAuth client ID
- `WHATSAPP_API_KEY` — WhatsApp Business API key
- `STRIPE_SECRET_KEY` — Stripe secret key
- `JWT_SECRET` — JWT signing secret

### Frontend (Flutter)

```bash
cd app
flutter pub get
flutter run
```

Variables de entorno:
- `API_BASE_URL` — Backend URL
- `GOOGLE_CLIENT_ID` — Google OAuth client ID (Android/iOS)

---

## Convenciones

- **Un endpoint para todo:** Ventas, gastos y deudas entran por `POST /transactions` con `type: sale|expense|debt`.
- **Offline first:** La app funciona sin internet. La nube es el consolidado.
- **Logs inmutables:** Nunca se borra nada. Cancelar un registro solo cambia su status.
- **API simple:** Si el JSON tiene más de 15 campos, es demasiado complejo.

---

*Competimos contra la libreta, no contra SAP.*
