# Reporte de Incidencias y Requerimientos Backend - Taco'Os POC

Este documento lista las discrepancias encontradas entre las necesidades de la App (Frontend) y los endpoints actuales del Backend.

## 🔴 Incidencias Críticas (Bloqueantes)
1.  **Enlace por Número de Celular:**
    *   *Requerimiento:* El cajero debe poder ingresar un número de celular para notificar al patrón que requiere asignación.
    *   *Estado:* No existe endpoint que reciba `celular_admin` y `usuario_id_cajero` para generar una notificación sin conocer el `negocioId`.
    *   *Propuesta:* `POST /api/v1/business/request-link-by-phone`.

## 🟡 Requerimientos de Mejora (Optimización)
1.  **Validación de Sesión (12h):**
    *   *Requerimiento:* El sistema debe permitir un "Soft Login" basado en el token de Google que dure 12 horas.
    *   *Estado:* El endpoint `/auth/refresh` existe, pero necesitamos confirmar si el backend valida la expiración de 12 horas o si es controlada puramente por el cliente.
2.  **Reporte Masivo de Sincronización (Sync Batch):**
    *   *Requerimiento:* Sincronizar ventas, gastos y cancelaciones en un solo objeto JSON cada 5-10 min.
    *   *Estado:* El endpoint `/sync` existe. Se requiere definir el esquema JSON final para que incluya múltiples tipos de entidades en un solo viaje.

## 🟢 Sugerencias de Arquitectura
1.  **Estado de Caja:**
    *   *Requerimiento:* El Admin y el Cajero necesitan saber si la caja está "Abierta" o "Cerrada" al entrar al Dashboard.
    *   *Estado:* Se requiere que el endpoint `/business/{id}` o uno nuevo devuelva el estado actual de la sesión de caja activa.

---
*Fecha de última actualización: 26/06/2026*
