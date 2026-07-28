# Taco-Os/ai_engine/prompt_builder.py
from typing import Dict, Any, List

class POSPromptBuilder:
    """
    Factoría y formateador encargado de inyectar las métricas limpias de Pandas 
    dentro de las plantillas fijas y coordinar el empaquetado del feed unificado para Flutter.
    """
    
    @staticmethod
    def build_system_instruction() -> str:
        """
        Establece el contrato de datos universal exigido por el Front-end de la aplicación móvil.
        """
        return (
            "Actúas como un Consultor Senior de Inteligencia Operativa y Negocios Gastronómicos para Taco'Os.\n"
            "Tu único objetivo es procesar la información analítica consolidada que te provee el backend y\n"
            "retornar recomendaciones tácticas empaquetadas exclusivamente en formato JSON estructurado.\n"
            "No incluyas introducciones, saludos, explicaciones técnicas de algoritmos ni texto plano fuera del bulto JSON.\n"
            "El formato final debe cumplir estrictamente con el siguiente contrato de datos exigido por Flutter:\n"
            "{\n"
            '  "titulo": "Nombre del módulo analítico (String)",\n'
            '  "prioridad": "verde (buena noticia) | amarilla (prevención) | roja (urgencia)",\n'
            '  "confianza": Nivel de certeza estadística entre 0 y 100 (Integer),\n'
            '  "mensaje": "Directiva clara, masticada y resumida en lenguaje simple para el Patrón (String)",\n'
            '  "accion": "Acción inmediata sugerida para ganar dinero o mitigar pérdidas (String)"\n'
            "}"
        )

    @staticmethod
    def inject_metrics_into_template(template: str, metrics: Dict[str, Any]) -> str:
        """
        Recibe una plantilla con llaves de formateo e inyecta de forma segura los valores.
        """
        try:
            return template.format(**metrics)
        except KeyError as k_err:
            raise ValueError(f"PROMPT_BUILDER_METRIC_ERROR: Falta una variable obligatoria en el payload: {str(k_err)}")
        except Exception as e:
            raise ValueError(f"PROMPT_BUILDER_CRITICAL_ERROR: Falló el ensamblado del prompt: {str(e)}")

class AIEngineFeedOrchestrator:
    """
    Orchestrator Pattern: Centraliza y ejecuta secuencialmente todos los módulos analíticos del POS,
    empaquetando los resultados en una única estructura indexada compatible con el feed móvil.
    """
    
    def __init__(self, engines_list: List[Any], csv_path: str, system_rules: str):
        self.engines = engines_list
        self.csv_path = csv_path
        self.system_rules = system_rules

    def compile_full_dashboard_feed(self) -> Dict[str, Any]:
        """
        Recorre todos los componentes de IA en línea, recolecta sus tarjetas estructuradas en JSON
        y consolida el payload unificado para internet.
        """
        print("[PRODUCCIÓN] Iniciando recolección síncrona del feed de Inteligencia Artificial...")
        aggregated_feed: List[Dict[str, Any]] = []
        
        # Recorremos cada motor registrado en la lista del backend
        for engine in self.engines:
            try:
                # Identificamos dinámicamente qué método de generación posee el objeto
                if hasattr(engine, 'generate_sales_prediction_card'):
                    card = engine.generate_sales_prediction_card(self.csv_path, self.system_rules)
                elif hasattr(engine, 'generate_hours_prediction_card'):
                    card = engine.generate_hours_prediction_card(self.csv_path, self.system_rules)
                elif hasattr(engine, 'generate_products_recommendation_card'):
                    card = engine.generate_products_recommendation_card(self.csv_path, self.system_rules)
                elif hasattr(engine, 'generate_supply_recommendation_card'):
                    card = engine.generate_supply_recommendation_card(self.csv_path, self.system_rules)
                elif hasattr(engine, 'generate_customer_retention_card'):
                    card = engine.generate_customer_retention_card(self.csv_path, self.system_rules)
                elif hasattr(engine, 'generate_cashier_audit_card'):
                    card = engine.generate_cashier_audit_card(self.csv_path, self.system_rules)
                elif hasattr(engine, 'generate_smart_closure_card'):
                    card = engine.generate_smart_closure_card(self.csv_path, self.system_rules)
                elif hasattr(engine, 'generate_contextual_prediction_card'):
                    card = engine.generate_contextual_prediction_card(self.csv_path, self.system_rules)
                elif hasattr(engine, 'generate_geographical_prediction_card'):
                    card = engine.generate_geographical_prediction_card(self.csv_path, self.system_rules)
                elif hasattr(engine, 'generate_fraud_prevention_card'):
                    card = engine.generate_fraud_prevention_card(self.csv_path, self.system_rules)
                else:
                    continue
                
                # Agregamos la tarjeta validada a la lista del bulto
                aggregated_feed.append(card)
                
            except Exception as e:
                # Resiliencia: si un módulo falla por datos rotos, el orquestador no se cae; salta al siguiente
                print(f"⚠️ [MÓDULO ADVERTENCIA] Se omitió un componente debido a un desvío: {str(e)}")
                continue

        # Retornamos el contrato final maestro unificado exigido por los endpoints de Flutter
        return {
            "status": "success",
            "total_alerts": len(aggregated_feed),
            "alertas_feed": aggregated_feed
        }

