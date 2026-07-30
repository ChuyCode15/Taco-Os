# Motor Core de Inteligencia Artificial (ai_engine) — Taco-Os
### Área: Ciencia de Datos & ML Engine | Data Scientist: Leandro Puebla Martinez

Este directorio aloja el motor analítico desacoplado de Taco-Os. La arquitectura está diseñada bajo principios de alta cohesión y aislamiento modular por dominios de negocio. El sistema procesa el histórico transaccional mediante Python para alimentar la inferencia estratégica del modelo fundacional.

## 📊 Pipeline de Procesamiento de Datos
El flujo de ejecución síncrono consta de 4 etapas de abstracción:
1. **Ingesta de Datos:** Pandas procesa el histórico transaccional bruto (`.csv`) de forma local en milisegundos.
2. **Cómputo Cuantitativo:** Se ejecutan operaciones estadísticas agregadas, desvíos paramétricos y promedios móviles fijos.
3. **Inferencia Semántica:** Los vectores de datos limpios se inyectan en plantillas específicas dirigidas al modelo `gemini-3.5-flash`.
4. **Capa de Contrato Estricto:** El motor restringe las opciones de muestreo del LLM mediante un esquema rígido de Pydantic.

## 🗂️ Desglose Modular de Agentes Analíticos
Cada script de Python opera de forma independiente sobre una dimensión específica del negocio:
*   `config.py`: Administrador inmutable de variables operacionales y carga segura de variables de entorno.
*   `gemini_client.py`: Cliente Singleton que gestiona el canal activo con Google GenAI y fuerza la validación del esquema.
*   `prompt_builder.py`: Factoría de instrucciones del sistema y orquestador encargado de compilar el feed unificado.
*   `ventas_ai.py` (Módulo 2): Series temporales para predicción macro de facturación.
*   `horarios_ai.py` (Módulo 3): Densidad horaria para aislar ventanas pico de mostrador vs delivery.
*   `productos_ai.py` (Módulo 4): Ingeniería de menú y optimización de combos de rentabilidad.
*   `proveedores_ai.py` (Módulo 5): Planificación logística de stock basada en consumo e inercia real.
*   `clientes_ai.py` (Módulo 6): Métricas de retención y alertas de inactividad de usuarios.
*   `cajeros_ai.py` (Módulo 7): Auditoría de personal de caja y control de tickets anulados.
*   `gastos_ai.py` (Módulo 8): Control y variaciones de egresos fijos del establecimiento.
*   `cierre_caja_ai.py` (Módulo 9): Balance de cierre diario traducido a lenguaje natural simple.
*   `eventos_ai.py` (Módulo 10): Elasticidad contextual de la demanda por variables climáticas y de calendario.
*   `geografia_ai.py` (Módulo 11): Inteligencia geográfica por cuadrantes urbanos y densidades de ruteo.
*   `fraude_ai.py` (Módulo 12): Detección avanzada de anomalías operacionales y caídas imprevistas de ingresos diarios.

## 🔄 Contrato de Interfaz de Inferencia (Structured Outputs)
El motor analítico define su estructura de salida mediante un contrato rígido gestionado por código a través de `schemas.py`. La API de Gemini restringe la capa de decodificación utilizando este esquema de Pydantic, garantizando que todo el pipeline de inferencia entregue variables alineadas estrictamente al dominio de los datos del negocio.

### 🔌 Punto de Entrada del Módulo (`main.py`)
Para centralizar el flujo de procesamiento e ingesta de datos, se expone la siguiente función pública unificada en la raíz del paquete de Python:
*   **Función:** `ejecutar_orquestador_ia() -> str`
*   **Retorno:** String JSON serializado (UTF-8) que encapsula el objeto de datos de la clase core `BusinessKnowledgeResponse`.

### 📑 Estructura del Payload de Salida (JSON Contract)
La recopilación de hallazgos analíticos y acciones sugeridas se estructura bajo las siguientes llaves fijas obligatorias:

```json
{
  "schema_version": "1.0.0",
  "generated_at": "TIMESTAMP_ISO_8601",
  "hallazgos": [
    {
      "id_hallazgo": "Código identificador de la alerta analítica (String)",
      "tipo": "ANOMALIA | PREDICCION (Enum)",
      "descripcion_hecho": "Declaración del comportamiento fuera de patrón detectado en los datos (String)",
      "evidencia": {
        "periodo_historico": "Rango de tiempo de la muestra evaluada (String)",
        "ocurrencias_similares": Cantidad factual de registros del patrón (Integer),
        "comportamiento_repetido": "Severidad cualitativa del hecho (String)",
        "fuente_datos": "Origen genérico del dataset analizado: ventas, gastos (String)"
      }
    }
  ],
  "directivas_accion": [
    {
      "id_directiva": "Identificador único de la acción prescrita (String)",
      "vinculo_hallazgo": "ID del HallazgoAnalitico de origen para asegurar trazabilidad (String)",
      "target_scope": "VENTAS | CAJA | LOGISTICA | FINANZAS | INFRAESTRUCTURA (Enum)",
      "prioridad_sistema": "ALTA | MEDIA | BAJA (Enum)",
      "orden_operativa": "Directiva clara y accionable en lenguaje natural simple para el usuario (String)"
    }
  ]
}
```

## 🔄 Historial de Refactorización Técnica
*   **Sanitización de Dominio:** Se removió el módulo obsoleto de 'Morosidad/Cuentas por Cobrar' heredado por error de plantillas previas de pruebas. Toda la lógica analítica fue migrada hacia el dominio core gastronómico del punto de venta, transformándose en el módulo de **Detección de Anomalías Financieras y Caídas de Facturación (`fraude_ai.py`)**.

> **Estado de la Infraestructura de IA: Saneada, Documentada y 100% Operacional.**

