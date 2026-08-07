package com.jmcsoft.taco_os.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.jmcsoft.taco_os.domain.analiticsIA.dto.AnaliticsPayloadDto;
import com.jmcsoft.taco_os.domain.analiticsIA.dto.AnalyticsReportDto;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;

@Slf4j
@Service
public class TacosIAClient {

    private final RestClient restClient;
    private final ObjectMapper mapper;


    public TacosIAClient() {
        HttpComponentsClientHttpRequestFactory factory = new HttpComponentsClientHttpRequestFactory();

        this.restClient = RestClient.builder()
                .baseUrl("http://localhost:8000")
                .requestFactory(factory)
                .build();

        this.mapper = new ObjectMapper();
        this.mapper.registerModule(new JavaTimeModule());
    }

    public AnalyticsReportDto obtenerReporteIA(AnaliticsPayloadDto payload) {
        try {
            // Log del JSON que se envía a FastAPI
            log.info("Payload enviado a FastAPI: {}", mapper.writeValueAsString(payload));
        } catch (Exception e) {
            log.error("Error serializando payload", e);
        }

        return restClient.post()
                .uri("/api/v1/analytics/report") // <-- Ruta correcta
                .contentType(MediaType.APPLICATION_JSON)
                .accept(MediaType.APPLICATION_JSON)
                .body(payload)
                .retrieve()
                .body(AnalyticsReportDto.class);
    }
}
