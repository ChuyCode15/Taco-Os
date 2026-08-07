package com.makingcode.taco_os.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI tacoOsAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Taco'Os API")
                        .description("API del sistema de punto de venta para micro-negocios. Competimos contra la libreta, no contra SAP.")
                        .version("v1")
                        .contact(new Contact()
                                .name("Jesus Medina")
                                .email("chuytec15@gmail.com")));
    }
}
