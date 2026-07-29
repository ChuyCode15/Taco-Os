# Maqueta de Persistencia Histórica Inmutable (App & Backend)

Este documento define la estructura de datos obligatoria para garantizar que el historial de Taco'Os sea auditable, inmutable y eficiente en consultas SQL/NoSQL.

## Principio de Diseño: "Snapshot de Totales"
Ningún reporte debe calcular sumas en tiempo de ejecución para datos históricos. Los totales se calculan **una sola vez** al momento de persistir el objeto (Nota o Corte) y se guardan como valores fijos. Esto protege el historial ante cambios de precios en el catálogo.

---

## 1. Entidad: `SaleDetail` (Detalle de Venta)
*Representa cada línea individual dentro de un ticket.*

| Atributo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | UUID | ID único del detalle. |
| `note_id` | UUID | FK a la Nota de Venta. |
| `product_name` | String | Nombre del producto (Snapshot del momento). |
| `quantity` | Int | Cantidad de unidades. |
| `unit_price` | Double | Precio unitario aplicado en la transacción. |
| `total_price` | Double | **Persistido:** `quantity * unit_price`. |
| `status` | String | "ACTIVE" o "DELETED". |

---

## 2. Entidad: `SaleNote` (Nota de Venta)
*La transacción completa con el cliente.*

| Atributo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | UUID | ID único de la transacción. |
| `folio` | Long | Consecutivo numérico por negocio. |
| `tenant_id` | UUID | Identificador del dueño/empresa. |
| `corte_id` | UUID | FK al Corte/Turno activo. |
| `total_products` | Int | **Persistido:** Suma de cantidades en detalles. |
| `total_amount` | Double | **Persistido:** Suma de totales en detalles. |
| `payment_method` | String | "CASH" o "CARD". |
| `voucher_path` | String? | Ruta local de la foto (si fue tarjeta). |
| `timestamp` | Long | Momento exacto del cobro. |
| `status` | String | "ACTIVE", "CANCELLED". |

---

## 3. Entidad: `Corte` (Cierre de Turno / Arqueo)
*La foto final de la responsabilidad del cajero.*

| Atributo | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | UUID | ID único del corte. |
| `tenant_id` | UUID | FK de la empresa. |
| `cashier_id` | String | ID del responsable del turno. |
| `opened_at` | Long | Timestamp de apertura. |
| `closed_at` | Long | Timestamp de cierre. |
| `initial_cash` | Double | Fondo de caja inicial. |
| `total_sales_amount` | Double | **Persistido:** Suma de `total_amount` de todas sus notas. |
| `total_sales_cash` | Double | **Persistido:** Suma de notas cobradas en efectivo. |
| `total_sales_card` | Double | **Persistido:** Suma de notas cobradas con tarjeta. |
| `total_expenses_amount`| Double | **Persistido:** Suma de todos los gastos en el turno. |
| `expected_cash` | Double | **Persistido:** `initial_cash + total_sales_cash - total_expenses`. |
| `real_cash_counted` | Double | Monto físico contado al cierre. |
| `difference` | Double | **Persistido:** `real_cash_counted - expected_cash`. |
| `status` | String | "CLOSED". |

---

## Flujo de Datos Hacia el Backend (Spring Boot)

1.  **App Móvil:** Genera el `Corte` y sus `SaleNotes` localmente con todos los campos calculados.
2.  **SyncWorker:** Envía el objeto `Corte` completo (incluyendo su lista de notas y gastos) en un solo JSON masivo al finalizar el turno.
3.  **Backend (Java):** Recibe el JSON, valida que las sumas coincidan con los totales enviados (doble chequeo) y persiste en tablas relacionales SQL o colecciones MongoDB.
4.  **Resultados:** Al consultar el historial, el Backend simplemente hace `SELECT total_amount FROM sales` sin tener que unir tablas de productos o recalcular precios viejos.

**Documento maquetado para la implementación de la Fase de Persistencia Profunda.**
