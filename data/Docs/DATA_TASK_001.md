# DATA TASK 001 — Estructura del Repositorio Estándar
### Estado: Finalizado | Desarrollador: Leandro Puebla Martinez

## Objetivo
Diseñar e inyectar un histórico comercial omnicanal de más de 12.000 registros para entrenar el motor predictivo de Taco-Os.

## Variables Consolidadas (Features)
- `invoice_id` (UUID) / `timestamp` (DateTime)
- `day_of_week` / `hour` (Ventanas críticas de Prime Time)
- `channel` (Calle vs Delivery) / `zone` (Geolocalización)
- `product_name` / `total_price` / `is_anulada` (Auditoría)
