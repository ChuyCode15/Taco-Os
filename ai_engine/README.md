# Motor Core de Inteligencia Artificial (ai_engine) — Taco-Os
### Área: IA & Machine Learning | Software Architect: Leandro Puebla Martinez

Este directorio aloja el motor inteligente desacoplado de Taco-Os. La arquitectura está diseñada bajo principios de **Responsabilidad Única (SOLID)** y aislamiento modular. El sistema no asume reglas fijas de un solo negocio, sino que computa un pipeline analítico aplicable a micro-comercios gastronómicos.

## 📊 Pipeline de Procesamiento de Datos
El flujo de ejecución síncrono consta de 4 capas de abstracción:
1. **Capa de Ingesta:** Pandas devora el histórico `.csv` en milisegundos en el servidor local.
2. **Capa Cuantitativa:** Se ejecutan operaciones matemáticas agregadas, promedios móviles y desviaciones estándar.
3. **Capa Semántica:** Las métricas limpias se inyectan en prompts especializados dirigidos al modelo `gemini-2.0-flash`.
4. **Capa de Contrato Uniforme:** El motor obliga a la API de Google a responder estrictamente en un formato JSON estructurado inmutable.

## 🗂️ Desglose Modular de Agentes Analíticos
Cada script de Python opera como un microservicio independiente del negocio:
*   `config.py`: Administrador inmutable de variables globales y carga híbrida de entornos sin secretos hardcodeados.
*   `gemini_client.py`: Cliente Singleton que gestiona los sockets HTTP con Google AI Studio y fuerza el tipo MIME a JSON.
*   `prompt_builder.py`: Factoría de instrucciones del sistema y orquestador maestro del feed unificado del Módulo 13.
*   `ventas_ai.py` (Módulo 2): Series temporales para predicción macro financiera.
*   `horarios_ai.py` (Módulo 3): Densidad horaria para aislar las horas pico de mostrador vs delivery.
*   `productos_ai.py` (Módulo 4): Ingeniería de menú y optimización de combos de alta rentabilidad.
*   `proveedores_ai.py` (Módulo 5): Planificación logística de órdenes de compra automáticas basadas en consumo real.
*   `clientes_ai.py` (Módulo 6): Análisis de retención y alertas automáticas de abandono de usuarios.
*   `cajeros_ai.py` (Módulo 7): Auditoría de personal de caja y métricas de desempeño neto.
*   `gastos_ai.py` (Módulo 8): Control y variaciones de egresos imprevistos (Facturas de Luz).
*   `cierre_caja_ai.py` (Módulo 9): Balance de cierre diario redactado en lenguaje natural simplificado para el dueño.
*   `eventos_ai.py` (Módulo 10): Elasticidad contextual de la demanda por clima y calendario deportivo.
*   `geografia_ai.py` (Módulo 11): Inteligencia geográfica por cuadrantes urbanos y densidades de entrega.
*   `fraude_ai.py` (Módulo 12): Detección avanzada de anomalías y alertas ante caídas imprevistas de facturación diaria.

## 📱 Contrato Estricto de Interfaz de Usuario (Flutter Feed)
Para evitar texto libre roto, todos los agentes devuelven siempre este formato JSON fijo, permitiendo a la app móvil pintar las tarjetas inteligentes por prioridad de color en la pantalla del Patrón:

```json
{
  "titulo": "Nombre oficial de la alerta",
  "prioridad": "verde (buena noticia) | amarilla (prevención) | roja (riesgo crítico/fraude)",
  "confianza": Valor entero del porcentaje de certeza estadística (0-100),
  "mensaje": "Directiva analítica completamente masticada y libre de tecnicismos para el Patrón",
  "accion": "Acción comercial inmediata sugerida por el sistema para ganar dinero o mitigar fugas"
}
```

## 🔄 Historial de Refactorización Técnica
*   **Sanitización de Dominio:** Se removió el módulo obsoleto de 'Morosidad/Cuentas por Cobrar' heredado por error de plantillas previas de pruebas. Toda la lógica analítica fue migrada hacia el dominio core gastronómico del punto de venta, transformándose en el módulo de **Detección de Anomalías Financieras y Caídas de Facturación (`fraude_ai.py`)**.

> **Estado del Módulo: Sincronizado, Homologado y Operacional al 100%.**
