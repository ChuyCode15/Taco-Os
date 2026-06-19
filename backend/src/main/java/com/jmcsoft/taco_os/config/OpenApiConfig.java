package com.jmcsoft.taco_os.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Taco'Os API")
                        .version("1.0.0")
                        .description("API REST del sistema de gestión de tacos Taco'Os")
                        .contact(new Contact()
                                .name("JMCSoft")
                                .email("dev@jmcsoft.com"))
                        .license(new License()
                                .name("Propietario")
                                .url("https://tacoos.com")));
    }
}
