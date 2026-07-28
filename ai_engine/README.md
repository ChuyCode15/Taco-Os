# Motor de Inteligencia Artificial — Taco-Os
### Área: IA & Machine Learning | Arquitecto de Software: Leandro Puebla Martinez

Este directorio aloja el núcleo inteligente de Taco-Os. La arquitectura está diseñada bajo principios de desacoplamiento modular: no asume reglas fijas de un solo rubro, sino que procesa un modelo de datos genérico aplicable a micro-comercios gastronómicos de alta rotación (Taquerías, Pizzerías, Hamburgueserías).

## 📊 Arquitectura del Motor y Flujo de Datos
El sistema procesa la información en un pipeline síncrono de cuatro capas:
1. **Ingesta de Datos:** Pandas devora el histórico de transacciones en milisegundos en el backend.
2. **Cómputo Cuantitativo:** Se extraen métricas agrupadas, desvíos estadísticos y segmentaciones operacionales.
3. **Orquestación Semántica:** Se inyectan las métricas procesadas al modelo `gemini-2.0-flash` mediante prompts especializados.
4. **Contrato Uniforme:** El motor fuerza una salida nativa en formato JSON estructurado listo para ser interpretado por Flutter.

## 🗂️ Desglose de Responsabilidad Única (Estructura de Archivos)
Cada archivo `.py` es responsable independiente de una única tarea analítica del negocio:
*   `__init__.py`: Inicializador oficial que registra la carpeta como un paquete importable en Python.
*   `config.py`: Administrador inmutable de configuraciones globales y carga segura de API Keys del sistema.
*   `gemini_client.py`: Conector central implementado como *Singleton* que gestiona la comunicación HTTP con Google AI Studio y fuerza la respuesta en JSON.
*   `prompt_builder.py`: Factoría de instrucciones del sistema y orquestador del feed unificado que empaqueta las tarjetas.
*   `ventas_ai.py`: Módulo de series temporales encargado de la predicción financiera macro.
*   `horarios_ai.py`: Análisis de densidad temporal encargado de aislar las horas pico de mostrador frente a delivery.
*   `productos_ai.py`: Ingeniería de menú encargada de evaluar el mix de productos y sugerir combos de alta rentabilidad.
*   `proveedores_ai.py`: Modelo logístico encargado de calcular la orden de compra predictiva de insumos (+15% estacional).
*   `clientes_ai.py`: Segmentación RFM encargada de auditar la retención y gatillar alertas de abandono de usuarios.
*   `cajeros_ai.py`: Auditoría de personal encargada de evaluar rendimientos netos y alertar desvíos en terminales de caja.
*   `gastos_ai.py`: Control automático encargado de medir variaciones y subas imprevistas en las boletas de servicios (Luz).
*   `cierre_caja_ai.py`: Balance diario en lenguaje natural que compara el rendimiento contra ayer y la semana previa.
*   `eventos_ai.py`: Modelo contextual que mide la elasticidad financiera frente al clima (lluvias) y el calendario (partidos/feriados).
*   `geografia_ai.py`: Inteligencia geográfica encargada de aislar el cuadrante urbano líder y sus preferencias de consumo.
*   `fraude_ai.py`: Detección de anomalías financieras encargado de alertar ante caídas repentinas o bajones inusuales de la facturación diaria.

## 📱 Contrato de Salida de Datos (Flutter JSON Feed)
Todas las respuestas devuelven de forma estricta la siguiente estructura para pintar las tarjetas inteligentes en el celular del Patrón:
```json
{
  "titulo": "Nombre del módulo analítico",
  "prioridad": "verde (buena noticia) | amarilla (prevención) | roja (urgencia/riesgo)",
  "confianza": Nivel de certeza estadística entre 0 y 100,
  "mensaje": "Directiva analítica clara y resumida en lenguaje simple para el Patrón",
  "accion": "Acción inmediata sugerida para ganar dinero o mitigar pérdidas"
}
```

## 🔄 Nota de Refactorización Histórica (Sanitización del Repositorio)
*   **Corrección de Dominio:** Se eliminó por completo el módulo obsoleto de 'Morosidad/Cuentas por Cobrar' heredado por error de plantillas previas de pruebas. El sistema fue refacturado al 100% hacia el dominio core gastronómico del POS, mutando dicha lógica analítica hacia el nuevo componente de **Detección de Anomalías Financieras y Caídas Repentinas de Facturación (`fraude_ai.py`)**.

> **Estado actual del Core: Sincronizado, Modular y Operacional al 100%.**
