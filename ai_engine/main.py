# ai_engine/main.py
import os
import json
from ai_engine.config import AIEngineConfig
from ai_engine.gemini_client import GeminiXPlatClient
from ai_engine.prompt_builder import POSPromptBuilder, AIEngineFeedOrchestrator

# Importación de la suite completa de agentes analíticos existentes en la rama
from ai_engine.ventas_ai import VentasAIEngine
from ai_engine.horarios_ai import HorariosAIEngine
from ai_engine.productos_ai import ProductosAIEngine
from ai_engine.proveedores_ai import ProveedoresAIEngine
from ai_engine.clientes_ai import ClientesAIEngine
from ai_engine.cajeros_ai import CajerosAIEngine
from ai_engine.gastos_ai import GastosAIEngine
from ai_engine.cierre_caja_ai import CierreCajaAIEngine
from ai_engine.eventos_ai import EventosAIEngine
from ai_engine.geografia_ai import GeografiaAIEngine
from ai_engine.fraude_ai import FraudeAIEngine

def ejecutar_orquestador_ia() -> str:
    """
    Punto de entrada oficial del paquete para la ejecución del pipeline analítico.
    Procesa las fuentes de datos y retorna el string JSON bajo el contrato BusinessKnowledgeResponse.
    """
    # Resolución de rutas del sistema de archivos local para la ingesta de datos
    ruta_raiz = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    ruta_csv = os.path.join(ruta_raiz, "data", "ventas_simuladas.csv")
    
    # Inicialización de la infraestructura core de Inteligencia Artificial
    config = AIEngineConfig()
    cliente = GeminiXPlatClient(config=config)
    rules_sistema = POSPromptBuilder.build_system_instruction()
    
    # Registro de las instancias operacionales activas de la taquería
    motores_activos = [
        VentasAIEngine(cliente, POSPromptBuilder),
        HorariosAIEngine(cliente, POSPromptBuilder),
        ProductosAIEngine(cliente, POSPromptBuilder),
        ProveedoresAIEngine(cliente, POSPromptBuilder),
        ClientesAIEngine(cliente, POSPromptBuilder),
        CajerosAIEngine(cliente, POSPromptBuilder),
        GastosAIEngine(cliente, POSPromptBuilder),
        CierreCajaAIEngine(cliente, POSPromptBuilder),
        EventosAIEngine(cliente, POSPromptBuilder),
        GeografiaAIEngine(cliente, POSPromptBuilder),
        FraudeAIEngine(cliente, POSPromptBuilder)
    ]
    
    # Orquestación y consolidación de los hallazgos cuantitativos y semánticos
    orquestador = AIEngineFeedOrchestrator(
        engines_list=motores_activos,
        csv_path=ruta_csv,
        system_rules=rules_sistema
    )
    
    # Compilación del mapa final de conocimiento del negocio
    resultado_dict = orquestador.compile_full_dashboard_feed()
    
    # Retorno seguro del string estructurado sin escapar caracteres no-ASCII
    return json.dumps(resultado_dict, ensure_ascii=False)

if __name__ == "__main__":
    # Permite validación directa y ejecución local desde la consola de comandos
    print(ejecutar_orquestador_ia())
