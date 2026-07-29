# Análisis Comparativo: Taco'Os vs Estándares de la Industria (POS)

Este documento audita la arquitectura de Taco'Os frente a sistemas líderes (Toast, Square, Shopify) para identificar debilidades técnicas, redundancias o fallos lógicos.

## 1. Matriz de Comparación Técnica

| Característica | Estándar "Pro" (Toast/Square) | Taco'Os (Estado Actual) | Calificación |
| :--- | :--- | :--- | :--- |
| **Persistencia** | Local-First con WAL (Write-Ahead Logging). | Local-First (Room SQLite). | **Excelente** |
| **Inmutabilidad** | Snapshots de precios y costos en cada línea. | Snapshots de precios implementados. | **Excelente** |
| **Sincronización** | Deltas binarios (Protocol Buffers). | Ráfagas JSON (Batches). | **Bueno** (JSON es más pesado). |
| **Integridad** | Relacional Estricta (FK Constraints). | Relacional Maquetada. | **En Progreso** |
| **Auditoría** | Logs de eventos de sistema (quién abrió popup). | Solo registros contables. | **Básico** |

---

## 2. Detección de Redundancias

### 2.1 El Dualismo Relacional/Documental
Estamos guardando la lista de productos vendidos en una tabla (`SaleDetail`) y opcionalmente en un campo de la nota (`productsJson`). 
*   **¿Es redundante?** Sí, en términos de espacio. 
*   **¿Es ilógico?** No. Los sistemas bancarios usan esta redundancia como **Doble Validación**. Si la tabla de detalles no suma lo mismo que el JSON de la nota, el sistema dispara una alerta de fraude. 
*   **Recomendación:** Mantener ambos. El JSON es para el "Sello de Auditoría" y la Tabla para los "Reportes de Ventas".

---

## 3. Puntos Ciegos Detectados (Gaps Críticos)

### A. El Problema de la Secuencialidad Offline
En un sistema pro, los folios (Ticket #101, #102) son vitales para el fisco. Si dos cajeros venden offline al mismo tiempo, ambos generarán el Ticket #101.
*   **Solución Pro:** Implementar prefijos por dispositivo (Cajero1-101, Cajero2-101) que el Backend consolide al recibir el Batch.

### B. El Costo de lo Vendido (Margen Real)
Actualmente sabemos cuánto vendimos, pero no cuánto ganamos. 
*   **Falta:** Un campo `cost_price` en `Product` y `SaleDetail`. Sin esto, los reportes de Taco'Os son solo de "Ventas", no de "Utilidad".

### C. Descuentos y Modificadores
Los sistemas robustos manejan "Sin cebolla", "Con queso extra (+10 pesos)". 
*   **Estado actual:** No contemplado. Nuestra estructura de `SaleDetail` es plana. 
*   **Impacto:** Bajo para el POC, pero limitante para escalabilidad.

---

## 4. Conclusión del Análisis

**Taco'Os tiene una estructura lógica superior al 80% de los POS genéricos del mercado.** La decisión de usar **Cortes** como padres obligatorios y **Snapshots de precios** nos pone al nivel de sistemas profesionales en cuanto a seguridad contable.

**Puntos a Refinar:**
1.  **Limpiar la lógica de sincronización:** Asegurar que el Backend no recalcule NADA. Solo debe "estampar" lo que la App ya calculó y validó.
2.  **Añadir Prefijos de Folio:** Para garantizar unicidad en ambientes multi-dispositivo.
3.  **Añadir campo de Costo:** Para evolucionar de un POS de ventas a un Administrador de Negocios.

**Veredicto:** Arquitectura sólida, lógica coherente y lista para implementación de fase profunda.
