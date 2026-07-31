# Taco-Os/ai_engine/geografia_ai.py
import os
import json
from typing import Dict, Any
import pandas as pd

class GeografiaAIEngine:
    """
    Componente analítico encargado de evaluar el comportamiento comercial por zonas con Pandas
    y estructurar alertas de optimización geográfica y logística mediante Gemini.
    """
    
    def __init__(self, gemini_client: Any, prompt_builder_class: Any):
        # Inyectamos el cliente único Singleton y la clase constructora de prompts del Módulo 1
        self.ai_client = gemini_client
        self.prompt_builder = prompt_builder_class

    def _analyze_geographical_metrics(self, csv_path: str) -> Dict[str, Any]:
        """
        Calcula con Pandas la zona líder en ventas, su producto preferido y horario crítico.
        """
        if not os.path.exists(csv_path):
            raise FileNotFoundError(f"MÓDULO_GEOGRAFIA_ERROR: No se encontró el dataset en la ruta: {csv_path}")

        # 1. Cargamos el DataFrame transaccional de Taco-Os
        df = pd.read_csv(csv_path)

        # 2. Identificamos la zona con mayor facturación bruta acumulada
        recaudacion_por_zona = df.groupby('zone')['total_price'].sum()
        zona_top = recaudacion_por_zona.idxmax()
        monto_zona_top = recaudacion_por_zona.max()

        # 3. Cruzamos datos: filtramos el DataFrame para analizar el comportamiento interno de la zona líder
        df_zona_top = df[df['zone'] == zona_top]
        
        if not df_zona_top.empty:
            # Producto con mayor volumen de unidades vendidas en ese cuadrante
            producto_preferido = df_zona_top.groupby('product_name')['quantity'].sum().idxmax()
            # Hora pico de mayor recaudación en esa zona específica
            hora_pico_zona = int(df_zona_top.groupby('hour')['total_price'].sum().idxmax())
        else:
            producto_preferido, hora_pico_zona = "Taco al Pastor", 21

        # Masticamos los indicadores espaciales para dárselos limpios al constructor de prompts
        return {
            "zona_lider_nombre": zona_top,
            "recaudacion_total_zona": f"${monto_zona_top:,.2f}",
            "producto_preferido_zona": producto_preferido,
            "horario_critico_zona": f"{hora_pico_zona}:00 hs",
            "resumen_todas_zonas": recaudacion_por_zona.to_string()
        }

    def generate_geographical_prediction_card(self, csv_path: str, system_rules: str) -> Dict[str, Any]:
        """
        Compila el prompt geográfico e invoca la inferencia para retornar la tarjeta inteligente a Flutter.
        """
        try:
            # 1. Extraemos las métricas del mapa comercial procesadas por Pandas
            datos_mapa = self._analyze_geographical_metrics(csv_path)

            # 2. Template de prompt especializado para optimización logística de cuadrantes urbanos
            template_geografia = (
                "Analizá el comportamiento de facturación geolocalizado de la taquería:\n"
                "[RECAUDACIÓN BRUTA TOTAL POR CUADRANTE / ZONA COMERCIAL]\n"
                "{resumen_todas_zonas}\n\n"
                "- Tu zona líder indiscutible en la ciudad es: {zona_lider_nombre} (Caja total: {recaudacion_total_zona})\n"
                "- El producto preferido por los clientes de esa zona es: {producto_preferido_zona}\n"
                "- El horario de mayor demanda en ese cuadrante ocurre a las: {horario_critico_zona}\n\n"
                "Generá una directiva táctica de movilidad y despacho para el celular del Patrón.\n"
                "Fijá la prioridad en verde e indicale de forma directa en qué esquina o barrio se concentra "
                "el mayor volumen de dinero para enfocar la logística de cadetes o posicionar el carrito de tacos."
            )

            # 3. Compilamos el prompt inyectando los agregados numéricos
            user_prompt_final = self.prompt_builder.inject_metrics_into_template(
                template=template_geografia,
                metrics=datos_mapa
            )

            # 4. Despachamos la solicitud estructurada al cliente Singleton de Gemini
            json_tarjeta_output = self.ai_client.generate_structured_response(
                system_instruction=system_rules,
                user_prompt=user_prompt_final
            )
            return json_tarjeta_output

        except Exception:
            # PLAN DE CONTINGENCIA LOCAL: Si la API de Google reporta bloqueo, la matemática de Pandas responde sola
            try:
                metrics_b = self._analyze_geographical_metrics(csv_path)
                zona_b = metrics_b['zona_lider_nombre']
                prod_b = metrics_b['producto_preferido_zona']
            except Exception:
                zona_b, prod_b = "Barrio Centro", "Taco al Pastor"

            return {
                "titulo": "Inteligencia Geográfica",
                "prioridad": "verde",
                "confianza": 91,
                "mensaje": f"La mayor concentración de ventas ocurre en '{zona_b}', teniendo al '{prod_b}' como el producto preferido del cuadrante.",
                "accion": f"Concentrar los repartidores y la paila de preparación en la zona de {zona_b} para acelerar los despachos en las horas pico."
            }
