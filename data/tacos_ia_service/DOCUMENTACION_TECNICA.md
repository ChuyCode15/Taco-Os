# 🌮 Taco-Os AI Engine - Guía Técnica de Integración

Este documento proporciona una descripción detallada del funcionamiento, los endpoints y la estrategia de integración para el motor de Inteligencia Artificial de Taco-Os.

---

## 🚀 1. Descripción Paso a Paso del Funcionamiento

El servicio opera como un agente inteligente especializado en analítica gastronómica:

1.  **Ingesta de Datos**: Los servicios de Backend (Java) o aplicaciones móviles envían datos crudos de ventas, gastos o deudas en formato JSON.
2.  **Procesamiento Estadístico**: Utilizando la librería `pandas`, el motor agrupa transacciones, calcula volúmenes por producto, identifica tendencias horarias (almuerzo/cena) y mide la estacionalidad (fines de semana vs semana).
3.  **Contextualización de IA**: Los resultados estadísticos se insertan en un "System Prompt" diseñado para actuar como Gerente Financiero o Agente de Cobros.
4.  **Inferencia (OpenRouter)**: Se realiza una petición a OpenRouter (Gemini/GPT) con parámetros de estabilidad (`temperature: 0.7`) para evitar bucles o respuestas vacías.
5.  **Entrega de Insights**: Se devuelve un objeto estructurado que contiene tanto las métricas calculadas como el análisis en lenguaje natural generado por la IA.

---

## 🛠 2. Documentación de Endpoints

### **Health Check**
-   **Método**: `GET /`
-   **Descripción**: Verifica el estado del servicio.

### **Reporte Analítico Financiero**
-   **Método**: `POST /api/v1/analytics/report`
-   **Descripción**: Recibe una lista de ventas y genera un análisis del "Producto Estrella" y recomendaciones de stock.
-   **Payload**: `{ "ventas": [...] }`

### **Cierre Diario de Caja**
-   **Método**: `POST /api/v1/analytics/daily-closing`
-   **Descripción**: Procesa transacciones y devuelve el total recaudado día por día. Ideal para gráficos de tendencias.

### **Agente de Cobros (Morosidad)**
-   **Método**: `POST /api/v1/analytics/debt-alerts`
-   **Descripción**: Analiza facturas pendientes y redacta mensajes de WhatsApp personalizados según el nivel de riesgo.

### **Generador de Simulación**
-   **Método**: `GET /api/v1/simulation/mock-data?dias=7`
-   **Descripción**: Genera datos de prueba automáticos para testing.

---

## 🏗 3. Integración en Arquitectura de Microservicios

Para integrar este servicio en un ecosistema robusto:
-   **Contenerización**: Desplegar el servicio usando el `Dockerfile` proporcionado (puerto 8000).
-   **API Gateway**: Se recomienda un Gateway (Spring Cloud Gateway o Nginx) para centralizar el acceso y manejar la seguridad.
-   **Sincronización**: Al ser un análisis pesado, se puede usar un patrón **Asíncrono** (Java envía datos -> IA procesa -> Notifica vía Webhook) para no bloquear el hilo de ejecución principal en cargas masivas.

---

## ☕ 4. Consumo desde Backend (Spring Boot)

En Spring Boot, utiliza `RestTemplate` o `WebClient` para consumir los endpoints.

```java
@Service
public class TacoAiClient {

    private final RestTemplate restTemplate = new RestTemplate();
    private final String AI_URL = "http://localhost:8000/api/v1/analytics/report";

    public String obtenerReporteIA(List<VentaDTO> listaVentas) {
        Map<String, Object> requestBody = new HashMap<>();
        requestRequest.put("ventas", listaVentas);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);

        ResponseEntity<Map> response = restTemplate.postForEntity(AI_URL, request, Map.class);
        return response.getBody().get("reporte_ai").toString();
    }
}
```

---

## 📱 5. Consumo desde Frontend (Kotlin / Android)

Para aplicaciones móviles en Kotlin, recomendamos **Retrofit** con **Coroutines**.

```kotlin
// Definición del Servicio
interface TacoAiApi {
    @POST("api/v1/analytics/report")
    suspend fun getAnalyticsReport(@Body payload: AnalyticsPayload): Response<AiResponse>
}

// Implementación en el Repositorio o ViewModel
fun fetchAiInsights(ventas: List<VentaItem>) {
    viewModelScope.launch(Dispatchers.IO) {
        try {
            val response = apiService.getAnalyticsReport(AnalyticsPayload(ventas))
            if (response.isSuccessful) {
                _reportState.value = response.body()?.reporte_ai
            }
        } catch (e: Exception) {
            // Manejar error de conexión
        }
    }
}
```

---

**Taco-Os AI Engine** | Integración y Documentación Técnica v1.3.2 🚀
