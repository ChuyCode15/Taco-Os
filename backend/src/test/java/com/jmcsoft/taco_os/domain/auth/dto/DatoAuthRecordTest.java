package com.jmcsoft.taco_os.domain.auth.dto;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class DatoAuthRecordTest {

    private final ObjectMapper mapper = new ObjectMapper();

    @Test
    @DisplayName("DatosRegistroAuth serializa/deserializa correctamente")
    void datosRegistroAuth_serializaCorrectamente() throws Exception {
        var original = new DatosRegistroAuth("ggl_123", "Juan", "juan@test.com", "+52123", "dueño");

        String json = mapper.writeValueAsString(original);
        var deserialize = mapper.readValue(json, DatosRegistroAuth.class);

        assertEquals("ggl_123", deserialize.idGoogle());
        assertEquals("Juan", deserialize.nickname());
        assertEquals("dueño", deserialize.rol());
    }

    @Test
    @DisplayName("DatosUsuarioAuth contiene todos los campos")
    void datosUsuarioAuth_camposCorrectos() {
        var usuario = new DatosUsuarioAuth(
                "id-1", "ggl_123", "Juan", "juan@test.com",
                "dueño", true, "neg-1", "Tacos El Güero"
        );

        assertEquals("id-1", usuario.id());
        assertEquals("ggl_123", usuario.idGoogle());
        assertEquals("Juan", usuario.nickname());
        assertEquals("dueño", usuario.rol());
        assertTrue(usuario.tieneNegocio());
        assertEquals("Tacos El Güero", usuario.negocioNombre());
    }

    @Test
    @DisplayName("DatosVerificacionAuth con usuario no existe")
    void datosVerificacionAuth_noExiste() {
        var resultado = new DatosVerificacionAuth(false, null, null, null);

        assertFalse(resultado.existe());
        assertNull(resultado.token());
        assertNull(resultado.usuario());
    }

    @Test
    @DisplayName("DatosRespuestaAuth serializa correctamente")
    void datosRespuestaAuth_serializa() throws Exception {
        var usuario = new DatosUsuarioAuth("id-1", "ggl_1", "Nick", "e@t.com", "cajero", false, null, null);
        var respuesta = new DatosRespuestaAuth("token-abc", 3600, usuario);

        String json = mapper.writeValueAsString(respuesta);

        assertTrue(json.contains("token-abc"));
        assertTrue(json.contains("3600"));
        assertTrue(json.contains("cajero"));
    }
}
