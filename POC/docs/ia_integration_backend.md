# Implementación: Integración de IA (Spring Boot <-> FastAPI)

Este documento detalla la estructura del backend para consultar ventas locales por `negocioId`, procesarlas en el microservicio de Data Science (Python/FastAPI) y devolver un insight para la aplicación móvil.

## 1. DTOs y Records (Modelos de Datos)

Utilizamos `record` para inmutabilidad y simplicidad en la transferencia de datos.

```java
// Payload enviado hacia FastAPI (Microservicio Python)
public record AnaliticsPayloadDto(
        List<VentaItemDto> ventas
) {}

// Elemento individual de venta (debe coincidir con lo que espera el modelo de IA)
public record VentaItemDto(
        int transaction_id,
        String date,
        int cashier_id,
        String product_name,
        String category,
        int quantity,
        double total_price
) {}

// Respuesta recibida desde FastAPI
public record AnalyticsReportDto(
        String status,
        Object insights, 
        String reporte_ai // Este es el mensaje que se mostrará en AiInsightCard.kt
) {}

// Respuesta de error estandarizada para el Móvil
public record ErrorResponse(
        String message,
        String details,
        long timestamp
) {
    public ErrorResponse(String message, String details) {
        this(message, details, System.currentTimeMillis());
    }
}
```

## 2. Cliente de Inter-comunicación (Feign Client)

Si usas Spring Cloud, esta es la forma más limpia de llamar a FastAPI.

```java
@FeignClient(name = "tacos-ia-service", url = "${microservice.ia.url}")
public interface TacosIAClient {
    @PostMapping("/predict") 
    AnalyticsReportDto obtenerReporteIA(@RequestBody AnaliticsPayloadDto payload);
}
```

## 3. Servicio de Lógica de Negocio

Buscamos las ventas del negocio en nuestra base de datos SQL y las enviamos a la IA.

```java
@Service
@Slf4j
public class AnalyticsService {

    private final VentaRepository ventaRepository;
    private final TacosIAClient tacosIAClient;

    public AnalyticsService(VentaRepository ventaRepository, TacosIAClient tacosIAClient) {
        this.ventaRepository = ventaRepository;
        this.tacosIAClient = tacosIAClient;
    }

    public AnalyticsReportDto generarReporteParaNegocio(String negocioId) {
        // 1. Obtener ventas del día actual
        LocalDateTime inicio = LocalDate.now().atStartOfDay();
        LocalDateTime fin = LocalDateTime.now();

        List<VentaItemDto> ventas = ventaRepository.findVentasByNegocioId(negocioId, inicio, fin)
                .stream()
                .map(v -> new VentaItemDto(
                        v.getId(),
                        v.getFecha().toString(),
                        v.getCajeroId(),
                        v.getProductoNombre(),
                        v.getCategoria(),
                        v.getCantidad(),
                        v.getTotal()
                ))
                .toList();

        if (ventas.isEmpty()) {
            return new AnalyticsReportDto("empty", null, "Aún no hay suficientes ventas hoy para generar un análisis.");
        }

        // 2. Enviar a FastAPI
        AnaliticsPayloadDto payload = new AnaliticsPayloadDto(ventas);
        return tacosIAClient.obtenerReporteIA(payload);
    }
}
```

## 4. Controlador REST (Endpoint para el Móvil)

```java
@Slf4j
@RestController
@RequestMapping("/api/v1/analytics")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    public AnalyticsController(AnalyticsService analyticsService) {
        this.analyticsService = analyticsService;
    }

    @GetMapping("/report/{negocioId}")
    public ResponseEntity<?> obtenerReporte(@PathVariable String negocioId) {
        log.info("Solicitud de IA recibida para negocio ID: {}", negocioId);
        try {
            AnalyticsReportDto reporte = analyticsService.generarReporteParaNegocio(negocioId);
            return ResponseEntity.ok(reporte);
        } catch (Exception e) {
            log.error("Falla al conectar con el microservicio de IA: {}", e.getMessage());
            return ResponseEntity.status(502).body(
                    new ErrorResponse("El servicio de IA no está disponible", e.getMessage())
            );
        }
    }
}
```
