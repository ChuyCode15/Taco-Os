"""
Contrato técnico de datos del motor analítico de Taco-Os.
Define las estructuras inmutables y los tipos de datos generados por el pipeline de IA.
"""

from enum import Enum
from typing import List
from pydantic import BaseModel, Field

# ==============================================================================
# ENUMS DEL DOMINIO ANALÍTICO (RESTRICCIONES OPERATIVAS)
# ==============================================================================

class PrioridadSistema(str, Enum):
    """Nivel de urgencia basado en la severidad del desvío detectado."""
    ALTA = "ALTA"
    MEDIA = "MEDIA"
    BAJA = "BAJA"

class TargetScope(str, Enum):
    """Área o segmento del negocio gastronómico afectado por el hallazgo."""
    VENTAS = "VENTAS"
    CAJA = "CAJA"
    LOGISTICA = "LOGISTICA"
    FINANZAS = "FINANZAS"
    INFRAESTRUCTURA = "INFRAESTRUCTURA"

class TipoHallazgo(str, Enum):
    """Clasificación temporal del conocimiento generado por el análisis."""
    ANOMALIA = "ANOMALIA"   # Desvío histórico detectado en los datos
    PREDICCION = "PREDICCION" # Proyección estimada hacia el futuro

# ==============================================================================
# MODELOS DE CONTRATO (ESTRUCTURAS DE DATOS PYDANTIC)
# ==============================================================================

class EvidenciaAnalitica(BaseModel):
    """Respaldo cuantitativo calculado localmente mediante el procesamiento con Pandas."""
    periodo_historico: str = Field(description="Rango de tiempo de la muestra de datos evaluada (ej: '6 meses').")
    ocurrencias_similares: int = Field(description="Cantidad factual de registros que confirman el patrón.")
    comportamiento_repetido: str = Field(description="Frecuencia o severidad cualitativa del hecho (ej: 'Alto', 'Crítico').")
    fuente_datos: str = Field(description="Origen genérico de la información (ej: 'ventas', 'gastos').")

class HallazgoAnalitico(BaseModel):
    """Conocimiento analítico generado (Evidencia empírica y diagnóstico objetivo)."""
    id_hallazgo: str = Field(description="Código único inmutable de la alerta analítica (ej: 'DESVIO_ANULACIONES_CAJA').")
    tipo: TipoHallazgo = Field(description="Dirección temporal del hallazgo (ANOMALIA o PREDICCION).")
    descripcion_hecho: str = Field(description="Declaración del comportamiento fuera de patrón detectado en los datos, libre de tecnicismos matemáticos.")
    evidencia: EvidenciaAnalitica = Field(description="Bloque encapsulado de respaldo cuantitativo.")

class DirectivaAccion(BaseModel):
    """Acción comercial sugerida y adaptada semánticamente por la IA."""
    id_directiva: str = Field(description="Identificador único de la acción prescrita (ej: 'REVISAR_OPERACIONES_NOCHE').")
    vinculo_hallazgo: str = Field(description="ID del HallazgoAnalitico de origen para asegurar trazabilidad y causalidad.")
    target_scope: TargetScope = Field(description="Dominio del local donde se debe aplicar la acción.")
    prioridad_sistema: PrioridadSistema = Field(description="Nivel de urgencia de la directiva para mitigar pérdidas o potenciar ingresos.")
    orden_operativa: str = Field(description="Directiva clara y accionable en lenguaje natural simple para el usuario.")

class BusinessKnowledgeResponse(BaseModel):
    """Payload de conocimiento consolidado. Interfaz oficial de egreso del motor analítico."""
    schema_version: str = Field(default="1.0.0", description="Versión del contrato para control de evolución del modelo.")
    generated_at: str = Field(description="Marca de tiempo ISO 8601 (UTC) de la generación del informe.")
    hallazgos: List[HallazgoAnalitico] = Field(description="Colección de evidencias cuantitativas y conocimiento generado.")
    directivas_accion: List[DirectivaAccion] = Field(description="Colección de recomendaciones y acciones sugeridas derivadas.")
