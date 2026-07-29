# Estrategia de Sincronización Local-First (App to Server)

Este documento define el protocolo de comunicación entre la App Móvil y el Backend Java Spring para garantizar la integridad de las transacciones.

## 1. El Paquete de Sincronización (The Batch)
Para optimizar el uso de red y batería, la app enviará ráfagas de transacciones. Un solo "Batch" puede contener múltiples Notas de Venta y Gastos.

### Estructura del Multipart/FormData:
*   **Campo `data` (JSON):** Contiene el desglose de transacciones.
*   **Campos `files` (Binary):** Lista de imágenes capturadas (Vouchers y Tickets).

```json
{
  "tenant_id": "uuid-empresa-123",
  "notes": [
    {
      "id": "uuid-nota-001",
      "total_amount": 150.0,
      "payment_method": "CARD",
      "image_name": "voucher_nota_001.jpg",
      "details": [
        { "product": "Taco Pastor", "qty": 5, "price": 25.0, "total": 125.0 },
        { "product": "Coca 600ml", "qty": 1, "price": 25.0, "total": 25.0 }
      ]
    }
  ],
  "expenses": [
    {
      "id": "uuid-gasto-55",
      "amount": 40.0,
      "detail": "Compra Cilantro",
      "image_name": "ticket_gasto_55.jpg"
    }
  ]
}
```

---

## 2. Lógica de Reintento y Estado
Cada registro en la base de datos local (Room) tendrá un campo `sync_status`:

1.  **PENDING:** Recién creado, esperando envío.
2.  **SYNCING:** Siendo procesado por el Worker actualmente.
3.  **COMPLETED:** Confirmado por el servidor (ya no se envía más).
4.  **ERROR:** Fallo tras 3 intentos (requiere intervención o esperar a mejor señal).

---

## 3. Manejo de Imágenes en el Servidor
El Backend Java Spring recibirá el `Multipart`:
1.  **Storage:** Guardará las imágenes en un sistema de archivos o Bucket (S3/Cloud Storage).
2.  **Relación:** Insertará la URL final de la imagen en la tabla de Ventas/Gastos de la DB maestra.
3.  **Confirmación:** Responderá a la App con un `HTTP 200 OK` y una lista de IDs que se procesaron con éxito.

---

## 4. Beneficios Técnicos
*   **Offline Nativo:** El cajero puede vender 5 horas sin internet. Al conectar, el sistema manda el "tren" de datos completo.
*   **Eficiencia:** Es mucho más rápido enviar 10 notas en una sola conexión que abrir 10 conexiones separadas.
*   **Consistencia:** El servidor procesa la Nota y sus Detalles como una sola transacción atómica (o se guardan todos o ninguno).
