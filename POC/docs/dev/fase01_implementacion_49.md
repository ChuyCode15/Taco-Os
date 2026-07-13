# Fase 01 - Implementación 49 (Corrección y Ajuste)

## Correcciones Realizadas

### Reglas de Desarrollo
- Se restablece el compromiso de NO ELIMINAR elementos ni refactorizar sin instrucción explícita.
- Se elimina la restricción de altura del 30% aplicada erróneamente al formulario de Gastos.

### Vista de Ventas (POS)
- **Botones de Acción:** Letras cambiadas a negro/gris muy oscuro para legibilidad.
- **Formulario de Gastos:**
    - Se restaura la estructura original (etiquetas de ejemplo, botones de registro).
    - Se corrige la acción del botón de cámara para que sea funcional.
- **Popup "Nota de Venta":**
    - Se aplica límite de altura del 30% vertical.
- **Módulo "Agregar Producto":**
    - Se renombra de "Productos" a "Agregar Producto".
    - Se aplica límite de altura del 30% vertical.
    - Se integra el selector de cantidad y botón de agregar dentro de la misma fila del producto (Inline).
    - Se actualiza la fila para mostrar miniatura cuadrada, nombre y precio.
    - Se renombra el botón de nuevo producto a "Registrar un producto Nuevo".
