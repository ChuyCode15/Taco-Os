# ai_engine/config.py
import os
from dataclasses import dataclass
from dotenv import load_dotenv

load_dotenv()

@dataclass(frozen=True)
class AIEngineConfig:
    """
    Configuración global inmutable para el motor de Inteligencia Artificial.
    Al usar 'frozen=True', garantizamos que ningún otro módulo pueda alterar 
    los parámetros operacionales del modelo de forma accidental en ejecución.
    """
    
    # Intenta leer la clave de acceso desde las variables del Sistema Operativo.
    # Al no escribirla directamente acá, protegemos la cuenta contra filtraciones en Git.
    api_key: str = os.environ.get("GEMINI_API_KEY", "")
    
    # El modelo fundacional de Google de alta velocidad y razonamiento estructurado avanzado.
    model_name: str = "gemini-3.5-flash"
    
    # Hiperparámetros lógicos para el control de la inferencia analítica de datos
    temperature: float = 0.1  # Temperatura ultra baja para forzar respuestas exactas y matemáticas (evita inventos)
    top_p: float = 0.95       # Filtro probabilístico de selección semántica de palabras nucleares
    max_output_tokens: int = 1024  # Límite máximo del tamaño del paquete de datos de retorno
    
    # Configuración de resiliencia y estabilidad frente a microcortes de red
    max_retries: int = 3          # Cantidad de reintentos automáticos si falla el servidor de Google
    timeout_seconds: float = 30.0 # Tiempo de espera máximo por petición antes de disparar alerta de desconexión

    def validate_config(self) -> None:
        """
        Verifica la presencia de la credencial obligatoria en la memoria de la sesión.
        Raises:
            ValueError: Si la clave no está configurada, deteniendo el inicio del backend.
        """
        if not self.api_key:
            raise ValueError(
                "CRITICAL_CONFIG_ERROR: No se detectó la variable de entorno 'GEMINI_API_KEY'. "
                "Por favor, configure su API Key en el sistema antes de inicializar el motor analítico."
            )
