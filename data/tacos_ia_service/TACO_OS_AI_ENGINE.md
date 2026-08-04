# 🌮 Taco-Os AI Engine - Guía Técnica de Integración

Este documento detalla el funcionamiento del motor de Inteligencia Artificial para la plataforma Taco-Os. El servicio está diseñado bajo una arquitectura de microservicios utilizando **FastAPI** y modelos de lenguaje de última generación.

---

## 🚀 1. Descripción del Funcionamiento (Paso a Paso)

El servicio actúa como un "Cerebro Analítico" siguiendo este flujo:

1.  **Recepción de Datos**: El servicio recibe colecciones de objetos JSON (ventas, deudas o gastos) desde otros microservicios o aplicaciones móviles.
2.  **Procesamiento con Pandas**: Los datos se transforman en DataFrames para realizar cálculos estadísticos pesados (agrupaciones por producto, detección de horas pico, análisis de estacionalidad).
3.  **Contextualización del Prompt**: Se construye un "Prompt de Negocio" que combina las métricas calculadas con instrucciones de rol (System Prompt) para la IA.
4.  **Llamada a OpenRouter**: Se realiza una petición segura a OpenRouter (usando Gemini 2.0 Flash o GPT-OSS) con parámetros de estabilidad (`temperature: 0.7`).
5.  **Generación de Insights**: La IA devuelve un reporte ejecutivo masticado para el dueño del negocio.

---

## 🛠 2. Documentación de Endpoints

### **Health Check**
-   **URL**: `GET /`
-   **Descripción**: Verifica que el servicio de IA está activo y respondiendo.

### **Generador de Reporte Analítico**
-   **URL**: `POST /api/v1/analytics/report`
-   **Descripción**: Procesa una lista de ventas e identifica el "Producto Estrella", horas pico y da recomendaciones de stock.
-   **Input**: JSON con lista de `ventas`.

### **Cierre de Caja Diario**
-   **URL**: `POST /api/v1/analytics/daily-closing`
-   **Descripción**: Devuelve la recaudación total agrupada por día. Ideal para alimentar gráficos de línea en el frontend.

### **Agente de Cobros (Morosidad)**
-   **URL**: `POST /api/v1/analytics/debt-alerts`
-   **Descripción**: Analiza clientes con deudas, evalúa el riesgo y redacta un mensaje de WhatsApp personalizado según los días de retraso.

### **Simulador de Datos**
-   **URL**: `GET /api/v1/simulation/mock-data`
-   **Descripción**: Genera datos ficticios que cumplen con los requisitos de la API para realizar pruebas rápidas.

---

## 🏗 3. Integración en Arquitectura de Microservicios

Este servicio debe tratarse como un **Worker de IA**:
-   **Aislamiento**: Debe correr en su propio contenedor Docker (puerto 8000).
-   **Seguridad**: Se recomienda colocar un API Gateway al frente o validar tokens JWT si se expone a internet.
-   **Escalabilidad**: Al ser stateless, puede escalarse horizontalmente para procesar múltiples reportes en paralelo.

---

## ☕ 4. Consumo desde Backend (Java + Spring Boot)

Para integrar este servicio en un ecosistema Spring Boot, utiliza `WebClient` o `RestTemplate`.

### Implementación del Cliente:
```java
@Service
public class AiAnalyticsService {

    private final RestTemplate restTemplate = new RestTemplate();
    private final String AI_SERVICE_URL = "http://localhost:8000/api/v1/analytics/report";

    public Map<String, Object> getFinancialReport(List<VentaDTO> salesList) {
        // Estructura del payload
        Map<String, Object> payload = new HashMap<>();
        payload.put("ventas", salesList);

        // Configuración de Headers
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> request = new HttpEntity<>(payload, headers);

        // Petición POST
        ResponseEntity<Map> response = restTemplate.postForEntity(AI_SERVICE_URL, request, Map.class);
        return response.getBody();
    }
}
```

---

## 📱 5. Consumo desde Frontend (Kotlin / Android)

En Kotlin (Android o Multiplatform), la forma más eficiente es usar **Retrofit**.

### Definición del Servicio:
```kotlin
interface TacoAiService {
    @POST("api/v1/analytics/report")
    suspend fun fetchReport(@Body payload: AnalyticsPayload): Response<AiReportResponse>
}

// Data Classes
data class AnalyticsPayload(val ventas: List<VentaItem>)
data class AiReportResponse(
    val status: String,
    val insights: Map<String, String>,
    val reporte_ai: String
)
```

### Uso en el ViewModel:
```kotlin
fun loadAiInsights(ventas: List<VentaItem>) {
    viewModelScope.launch {
        val result = tacoAiService.fetchReport(AnalyticsPayload(ventas))
        if (result.isSuccessful) {
            _uiState.value = result.body()?.reporte_ai
        }
    }
}
```

---

**Taco-Os AI Engine** | Versión 1.3.2 🚀
