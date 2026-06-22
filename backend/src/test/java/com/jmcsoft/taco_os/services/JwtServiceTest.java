package com.jmcsoft.taco_os.services;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class JwtServiceTest {

    private JwtService jwtService;

    @BeforeEach
    void setUp() {
        jwtService = new JwtService();
        var secretField = org.springframework.util.ReflectionUtils.findField(JwtService.class, "secret");
        org.springframework.util.ReflectionUtils.makeAccessible(secretField);
        org.springframework.util.ReflectionUtils.setField(secretField, jwtService, "TacoOsTestSecretKey123456789");

        var expField = org.springframework.util.ReflectionUtils.findField(JwtService.class, "expirationMs");
        org.springframework.util.ReflectionUtils.makeAccessible(expField);
        org.springframework.util.ReflectionUtils.setField(expField, jwtService, 3600000L);
    }

    @Test
    @DisplayName("Generar token retorna string no nulo y no vacío")
    void generarToken_retornaTokenValido() {
        String token = jwtService.generarToken("user-1", "ggl_123", "dueño", "Juan");

        assertNotNull(token);
        assertFalse(token.isBlank());
        assertTrue(token.contains("."));
    }

    @Test
    @DisplayName("Validar token con datos correctos no lanza excepción")
    void validarToken_tokenValido_noLanzaExcepcion() {
        String token = jwtService.generarToken("user-1", "ggl_123", "dueño", "Juan");

        assertDoesNotThrow(() -> jwtService.validarToken(token));
    }

    @Test
    @DisplayName("Validar token con secret incorrecto lanza excepción")
    void validarToken_tokenInvalido_lanzaExcepcion() {
        String token = jwtService.generarToken("user-1", "ggl_123", "dueño", "Juan");

        var otroService = new JwtService();
        var secretField = org.springframework.util.ReflectionUtils.findField(JwtService.class, "secret");
        org.springframework.util.ReflectionUtils.makeAccessible(secretField);
        org.springframework.util.ReflectionUtils.setField(secretField, otroService, "OtraSecretKeyDiferente12345");

        assertThrows(Exception.class, () -> otroService.validarToken(token));
    }

    @Test
    @DisplayName("Extraer subject del JWT retorna el ID de usuario")
    void extraerIdUsuario_retornaIdCorrecto() {
        String token = jwtService.generarToken("user-1", "ggl_123", "dueño", "Juan");
        var jwt = jwtService.validarToken(token);

        assertEquals("user-1", jwtService.extraerIdUsuario(jwt));
    }

    @Test
    @DisplayName("Extraer claim rol del JWT retorna el valor correcto")
    void extraerRol_retornaRolCorrecto() {
        String token = jwtService.generarToken("user-1", "ggl_123", "cajero", "Pedro");
        var jwt = jwtService.validarToken(token);

        assertEquals("cajero", jwtService.extraerRol(jwt));
    }

    @Test
    @DisplayName("Extraer claim idGoogle del JWT")
    void extraerIdGoogle_retornaValorCorrecto() {
        String token = jwtService.generarToken("user-1", "ggl_999", "super_admin", "Admin");
        var jwt = jwtService.validarToken(token);

        assertEquals("ggl_999", jwtService.extraerIdGoogle(jwt));
    }

    @Test
    @DisplayName("Extraer claim nickname del JWT")
    void extraerNickname_retornaValorCorrecto() {
        String token = jwtService.generarToken("user-1", "ggl_123", "dueño", "Mi Apodo");
        var jwt = jwtService.validarToken(token);

        assertEquals("Mi Apodo", jwtService.extraerNickname(jwt));
    }

    @Test
    @DisplayName("Token recién creado no está expirado")
    void esTokenExpirado_tokenNuevo_retornaFalso() {
        String token = jwtService.generarToken("user-1", "ggl_123", "dueño", "Juan");
        var jwt = jwtService.validarToken(token);

        assertFalse(jwtService.esTokenExpirado(jwt));
    }
}
