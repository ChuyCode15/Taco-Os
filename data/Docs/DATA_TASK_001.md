# ESPECIFICACIÓN TÉCNICA DE DATOS — DATA TASK 001
### Estado: Finalizado y Homologado | Data Scientist: Leandro Puebla Martinez
### Proyecto: Taco-Os POS Inteligente

## 1. Objetivo Operacional
Diseñar, simular e inyectar un histórico transaccional omnicanal robusto para el entrenamiento, validación y Dry Run de la suite modular de Inteligencia Artificial. El dataset simula con precisión matemática un entorno comercial gastronómico de alta rotación (taquería) a lo largo de 6 meses de actividad continua.

## 2. Diccionario de Datos (Mapeo de Atributos)
El archivo resultante `ventas_simuladas.csv` consta de 16 variables estructuradas bajo tipos de datos estrictos para su ingesta nativa con Pandas:

*   `invoice_id` (String/UUID): Identificador único inmutable de la comanda fiscal.
*   `timestamp` (DateTime): Marca horaria precisa del registro (YYYY-MM-DD HH:MM:SS).
*   `day_of_week` (Categorical): Día de la semana (Lunes a Domingo) para análisis estacional macro.
*   `hour` (Integer [0-23]): Ventana horaria de la transacción para detección de Prime Time.
*   `channel` (Categorical ['Cliente al paso', 'Envío a domicilio']): Canal de venta omnicanal.
*   `zone` (Categorical): Cuadrante geográfico urbano mapeado para inteligencia de ruteo.
*   `cashier_id` (Categorical): Identificador del operador de terminal de caja (Auditoría de personal).
*   `client_name` (String): Registro de identidad para segmentación y métricas de retención (RFM).
*   `product_name` (Categorical): Item del menú seleccionado (Taco al Pastor, Barbacoa, Carnitas, Asada, etc.).
*   `quantity` (Integer): Volumen de unidades despachadas en la comanda.
*   `total_price` (Float): Monto bruto de la transacción en pesos (Calculado: quantity * precio_unitario).
*   `is_anulada` (Boolean [0, 1]): Flag crítico de auditoría interna. Registra si la venta fue cancelada por el cajero.
*   `insumo_name` (Categorical): Materia prima crítica descontada del depósito asociada al producto estrella.
*   `insumo_qty_used` (Float): Métrica de descuento en kilogramos o unidades físicas del inventario base.
*   `context_event` (Categorical): Evento externo mapeado (Partido de Liga Local, Feriado, Fin de mes, Ninguno).
*   `weather` (Categorical): Condición climática registrada (Despejado, Lluvia, Templado).

## 3. Lógica Estocástica de Simulación
El set de datos no es plano. Incorpora desvíos paramétricos reales del negocio:
*   **Elasticidad de la Demanda:** Las ventas aumentan un 42% de forma automatizada ante eventos de partidos locales.
*   **Inyección de Anomalías:** Se introdujo un desvío estándar crítico aislado mediante Z-Score en el operador `Cajero_3_Anomalo` (615 anulaciones consecutivas) para validar la efectividad de la detección de fraudes.
