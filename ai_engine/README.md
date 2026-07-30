# Motor Core de Inteligencia Artificial (ai_engine) — Taco-Os

### Área: Ciencia de Datos & Machine Learning
**Responsable:** Leandro Puebla Martínez

---

# Descripción General

El directorio `ai_engine` contiene el motor analítico desacoplado de Taco-Os.

Su responsabilidad consiste en transformar el histórico transaccional del negocio en conocimiento accionable para el propietario mediante procesamiento estadístico con Python e inferencia asistida por Gemini.

Toda la arquitectura fue diseñada bajo principios de:

- Alta cohesión.
- Bajo acoplamiento.
- Responsabilidad única por módulo.
- Escalabilidad por dominios de negocio.
- Salida estructurada para consumo del backend.

---

# Pipeline de Procesamiento

El flujo completo del motor sigue cinco etapas bien definidas:

## 1. Ingesta de Datos

Se carga el histórico de ventas desde:

```
data/ventas_simuladas.csv
```

utilizando Pandas.

---

## 2. Procesamiento Analítico

Cada módulo calcula únicamente las métricas correspondientes a su dominio:

- agregaciones
- frecuencias
- tendencias
- desviaciones
- comparaciones históricas
- indicadores operativos

---

## 3. Inferencia Inteligente

Las métricas procesadas son incorporadas dentro de prompts especializados.

Cada agente consulta el modelo Gemini configurado mediante:

```
AIEngineConfig
```

---

## 4. Orquestación

`AIEngineFeedOrchestrator`

ejecuta secuencialmente todos los agentes registrados.

Cada uno devuelve una tarjeta independiente de conocimiento.

---

## 5. Contrato de Salida

El orquestador transforma todas las tarjetas en un único JSON compatible con el backend de Taco-Os.

La salida es serializada por:

```
ejecutar_orquestador_ia()
```

---

# Arquitectura Modular

Cada archivo representa un dominio independiente del negocio.

| Archivo | Responsabilidad |
|---------|-----------------|
| `config.py` | Configuración general del motor y variables de entorno |
| `gemini_client.py` | Cliente Singleton para Google Gemini |
| `prompt_builder.py` | Construcción de prompts y orquestación del feed |
| `schemas.py` | Contratos estructurados del motor |
| `main.py` | Punto de entrada oficial |

---

# Agentes Analíticos

## ventas_ai.py

Predicción de ventas.

---

## horarios_ai.py

Predicción de horarios de mayor demanda.

---

## productos_ai.py

Productos con mayor rotación.

Productos con menor salida.

Sugerencias comerciales.

---

## proveedores_ai.py

Proyección automática de compras.

Reposición de stock.

---

## clientes_ai.py

Retención.

Clientes inactivos.

Ticket promedio.

---

## cajeros_ai.py

Auditoría de cajeros.

Cancelaciones.

Comportamientos anómalos.

---

## gastos_ai.py

Control de gastos.

Alertas de incrementos.

---

## cierre_caja_ai.py

Resumen inteligente del cierre diario.

---

## eventos_ai.py

Predicción basada en eventos y calendario.

---

## geografia_ai.py

Comportamiento por zonas.

Productos preferidos por ubicación.

---

## fraude_ai.py

Detección de anomalías operativas.

Caídas inesperadas de ventas.

---

# Punto de Entrada

La ejecución oficial del motor se realiza mediante:

```python
ejecutar_orquestador_ia()
```

Retorna:

```python
str
```

conteniendo un JSON serializado UTF-8.

---

# Contrato JSON

```json
{
  "schema_version": "1.0.0",
  "generated_at": "TIMESTAMP_ISO_8601",
  "hallazgos": [
    {
      "id_hallazgo": "HALLAZGO_001",
      "tipo": "PREDICCION",
      "descripcion_hecho": "...",
      "evidencia": {
        "periodo_historico": "...",
        "ocurrencias_similares": 92,
        "comportamiento_repetido": "VERDE",
        "fuente_datos": "ventas_simuladas.csv"
      }
    }
  ],
  "directivas_accion": [
    {
      "id_directiva": "ACCION_001",
      "vinculo_hallazgo": "HALLAZGO_001",
      "target_scope": "VENTAS",
      "prioridad_sistema": "VERDE",
      "orden_operativa": "Incrementar preventivamente el stock..."
    }
  ]
}
```

---

# Flujo Interno

```
CSV

↓

Pandas

↓

Agentes Analíticos

↓

Gemini

↓

AIEngineFeedOrchestrator

↓

BusinessKnowledgeResponse

↓

Backend

↓

Flutter
```

---

# Estado Actual del Motor

- Motor completamente modular.
- 11 agentes analíticos implementados.
- Cliente único para Google Gemini.
- Orquestador funcional.
- Contrato JSON unificado.
- Integración con backend preparada.
- Procesamiento sobre histórico de ventas.
- Arquitectura desacoplada.
- Salida compatible con Flutter y Spring Boot.

---

# Historial de Cambios Relevantes

- Eliminación del antiguo módulo de morosidad heredado de pruebas.
- Migración completa al dominio gastronómico.
- Incorporación del contrato estructurado `BusinessKnowledgeResponse`.
- Implementación del orquestador central.
- Integración con Google Gemini mediante SDK oficial.
- Unificación de los once módulos analíticos en un único feed de conocimiento.

---

# Estado del Proyecto

**Motor IA completamente operativo.**

El motor procesa el histórico de ventas, ejecuta los once agentes analíticos, consolida el conocimiento generado y produce un contrato JSON único listo para ser consumido por el backend de Taco-Os.