package com.jmcsoft.taco_os.services.master;

import com.jmcsoft.taco_os.domain.analiticsIA.dto.AnaliticsPayloadDto;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

@Service
public class TacosIAClient {

    private final RestClient restClient;
    public TacosIAClient() {
        this.restClient = RestClient.builder()
                .baseUrl("http://localhost:8000")
                .build();
    }

    public String obtenerReporteIA(AnaliticsPayloadDto payload) {
        return restClient.post()
                .uri("api/v1/analytics/report")
                .contentType(MediaType.APPLICATION_JSON)
                .retrieve()
                .body(String.class);
    }
}
