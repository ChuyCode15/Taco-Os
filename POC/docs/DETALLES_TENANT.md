# Detalles del Concepto de Tenant (Multi-Tenancy)

El **Tenant** es la entidad de más alto nivel en Taco OS. Representa a la organización, cadena o cuenta maestra que agrupa todos los recursos.

## 1. Propósito del Tenant
El `tenantId` es el eje central para la **aislación de datos** y la **agregación de reportes**:
- **Aislación:** Ninguna consulta debe mezclar datos de diferentes Tenants. Un cajero de una cadena no debe tener acceso a las ventas de otra cadena, incluso si ambas usan la misma infraestructura en la nube.
- **Agregación:** El Dueño (Owner) del Tenant puede ver reportes consolidados de todas sus sucursales (Business) simplemente filtrando por su `tenantId`.

## 2. Jerarquía de Datos
1. **Tenant** (La Empresa/Dueño)
   - **Business 1** (Sucursal Centro)
     - Usuarios (Cajeros vinculados)
     - Inventario / Productos
     - Cortes / Ventas
   - **Business 2** (Sucursal Norte)
     - ... (Mismos recursos aislados por `businessId`)

## 3. Atributos del Tenant (Clase `Tenant`)
- `id`: Identificador único (UUID) generado en el backend.
- `nombre`: Nombre comercial de la cadena (ej: "Tacos El Pastorcito").
- `plan`: Nivel de suscripción. Controla los límites del sistema:
  - **Gratis:** 1 sucursal, 2 cajeros, reportes de 30 días.
  - **Pro:** Hasta 5 sucursales, cajeros ilimitados, reportes de 1 año.
  - **Premium:** Sucursales ilimitadas, reportes históricos totales, soporte prioritario.
- `rfc`: Datos fiscales para facturación del servicio.
- `logoUrl`: Branding personalizado que aparecerá en los tickets de venta generados por el app.

## 4. Lógica de Negocio en App y Backend
- Al iniciar la App, si el usuario es "Dueño", se descarga la información del Tenant para configurar límites locales.
- Todas las peticiones al endpoint `/api/v1/sync` llevan el `tenantId` en la cabecera del JSON para que el servidor sepa dónde guardar cada registro de forma segura.

---
*Este documento define la estructura de gobernanza de datos para Taco OS POC.*
