# ai_engine/gemini_client.py
import json
from typing import Dict, Any, Optional
from google import genai
from google.genai import types
from google.genai import errors

# En la ejecución modular se importa de forma relativa el archivo de configuración anterior
# from ai_engine.config import AIEngineConfig

class GeminiXPlatClient:
    """
    Cliente de conexión de alta disponibilidad implementado bajo el patrón Singleton.
    Garantiza que toda la aplicación comparta un único canal activo con Google Gemini,
    evitando la sobrecarga de memoria del servidor y duplicación de peticiones HTTP.
    """
    _instance: Optional['GeminiXPlatClient'] = None

    def __new__(cls, config: Any) -> 'GeminiXPlatClient':
        # Control estructural: si la clase no ha sido creada previamente en memoria, la inicializa
        if cls._instance is None:
            cls._instance = super(GeminiXPlatClient, cls).__new__(cls)
            cls._instance._initialize_client(config)
        return cls._instance

    def _initialize_client(self, config: Any) -> None:
        """Establece la conexión de forma segura utilizando el SDK oficial de Google GenAI."""
        config.validate_config()
        self.config = config
        # Instanciación nativa recomendada para la competencia Gemini XPrize
        self.client = genai.Client(api_key=self.config.api_key)

    def generate_structured_response(self, system_instruction: str, user_prompt: str) -> Dict[str, Any]:
        """
        Envía los prompts al servidor y obliga de forma estricta a retornar un JSON legible.
        
        Args:
            system_instruction: Directiva fija de comportamiento o rol de sistema.
            user_prompt: El string enriquecido con las métricas extraídas por Pandas.
            
        Returns:
            Dict: Mapeo ordenado en formato clave-valor listo para despacharse a la API móvil.
        """
        try:
            # Configuración estructural de la llamada nativa usando las entidades de Google tipos
            generation_config = types.GenerateContentConfig(
                system_instruction=system_instruction,
                temperature=self.config.temperature,
                top_p=self.config.top_p,
                max_output_tokens=self.config.max_output_tokens,
                # ESTA VARIABLE ES MANDATORIA: Bloquea el transformador para hablar solo en JSON.
                # Evita que el modelo agregue preámbulos, saludos o marcas markdown que rompen Flutter.
                response_mime_type="application/json"
            )

            # Invocación síncrona al endpoint centralizado de Google Cloud
            response = self.client.models.generate_content(
                model=self.config.model_name,
                contents=user_prompt,
                config=generation_config
            )

            if not response.text:
                raise ValueError("El payload retornado por la infraestructura de Gemini está vacío.")

            # Convierte el string del JSON estricto que mandó Gemini a un diccionario nativo de Python
            validated_json = json.loads(response.text)
            return validated_json

        except errors.APIError as api_err:
            # Captura fallos del servidor remoto (Límites de cuotas agotados, caídas generales de red)
            raise RuntimeError(f"GOOGLE_API_STUDIO_ERROR [{api_err.code}]: {api_err.message}") from api_err
            
        except json.JSONDecodeError as json_err:
            # Captura fallos si el modelo corrompió la estructura de llaves del JSON por caracteres extraños
            raise RuntimeError("PARSE_ERROR: La salida generada por Gemini no posee una estructura JSON válida.") from json_err
            
        except Exception as e:
            # Captura preventiva de fallos genéricos del sistema analítico del POS
            raise RuntimeError(f"SYSTEM_INTEGRATION_ERROR: Fallo crítico en el motor de inferencia: {str(e)}") from e
