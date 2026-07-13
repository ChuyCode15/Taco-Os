# Fase 01 - Implementación 48

## Cambios Realizados

### Dashboard Administrador
- Se reemplazó la caja azul de "VENTAS HOY" por un banner rotativo de imágenes (simulado) relacionado con ventas de comida, administración y controles de negocio.

### Vista de Ventas (POS)
- **Popup "Nota de Venta":**
    - Se cambió el color del texto de los botones (Cancelar, Gasto, Venta) a negro/gris oscuro.
    - Se limitó el tamaño vertical del popup al 30% de la pantalla, permitiendo crecimiento de renglones si es necesario.
- **Popup de Gastos:**
    - Se preparó la lógica para abrir la cámara (integración con `ActivityResultLauncher`).
    - Se especificó el requerimiento de almacenamiento en bucket/mongo para imágenes de baja resolución.
- **Popup "Agregar Producto":**
    - Se renombró de "Productos" a "Agregar Producto".
    - Se limitó el tamaño vertical al 30% de la pantalla.
    - Se cambió la interacción de selección: ahora es en la misma fila con entrada de cantidad (teclado numérico) y botón "Agregar".
    - Se renombró el botón inferior a "Registrar un producto Nuevo".
    - Se actualizó el diseño de la fila: miniatura cuadrada, nombre y precio.
