# Protocolo de Integridad y Prevención de Datos Huérfanos

Este protocolo garantiza que cada centavo registrado en Taco'Os esté vinculado a un responsable y a un turno específico.

## 1. El Objeto "Corte" como Padre Universal
Ninguna Nota de Venta (`SaleNote`) o Gasto (`Expense`) puede existir de forma independiente. Todos deben colgar de un `Corte`.

### Secuencia de Bloqueo:
1.  **Estado Inicial:** App bloqueada para ventas.
2.  **Acción:** Cajero ingresa fondo y abre turno.
3.  **Persistencia Inmediata:** Se crea `Corte { id: UUID, status: "OPEN" }` en Room.
4.  **Activación:** El `corte_id` se carga en la memoria global de la App.
5.  **Transacción:** Al cobrar, la Nota se guarda con: `note.corte_id = global.active_corte_id`.

---

## 2. Diagrama de Relaciones (E-R)

```
[ CORTE ] (1) ----\
           |       \--- (N) [ GASTOS ]
           \--- (N) [ NOTAS DE VENTA ] (1) --- (N) [ DETALLES ]
```

*   **Si el Corte muere:** Sus hijos quedan invalidados (Auditoría fallida).
*   **Si la Nota muere:** Sus detalles deben marcarse como cancelados automáticamente.

---

## 3. Manejo de Errores y Recuperación
¿Qué pasa si la App se cierra inesperadamente?

*   **Auto-Detección:** Al iniciar la App, el sistema consulta: `SELECT * FROM cortes WHERE status = 'OPEN'`.
*   **Recuperación:** Si encuentra uno, restaura el turno automáticamente. El cajero no tiene que volver a abrir caja.
*   **Consistencia:** Esto asegura que las notas generadas tras el reinicio sigan perteneciendo al mismo turno original.

---

## 4. Requerimientos para el Backend (Java Spring)
El servidor debe aplicar las mismas reglas de validación (Constraints):
*   `sale_notes.corte_id` NOT NULL.
*   `sale_details.note_id` NOT NULL.
*   Validar que el `corte_id` enviado en el Batch pertenezca al `tenant_id` que hace la petición.

**Este protocolo elimina la posibilidad de tener ventas "fantasma" que no aparecen en los cortes.**
