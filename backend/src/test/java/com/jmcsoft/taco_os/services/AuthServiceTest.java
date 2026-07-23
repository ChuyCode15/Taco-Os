package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.exception.DuplicadoException;
import com.jmcsoft.taco_os.domain.administrador.Administrador;
import com.jmcsoft.taco_os.domain.auth.dto.DatosRegistroAuth;
import com.jmcsoft.taco_os.domain.cajero.Cajero;
import com.jmcsoft.taco_os.repository.AdministradorRepository;
import com.jmcsoft.taco_os.repository.CajeroRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private AdministradorRepository administradorRepository;
    @Mock
    private CajeroRepository cajeroRepository;
    @Mock
    private JwtService jwtService;

    @InjectMocks
    private AuthService authService;

    @BeforeEach
    void setUp() {
        var expField = org.springframework.util.ReflectionUtils.findField(AuthService.class, "expirationMs");
        org.springframework.util.ReflectionUtils.makeAccessible(expField);
        org.springframework.util.ReflectionUtils.setField(expField, authService, 3600000L);
    }

    // === VERIFICAR USUARIO ===

    @Test
    @DisplayName("Verificar usuario existente como admin retorna token y datos")
    void verificarUsuario_adminExistente_retornaTrueConToken() {
        var admin = new Administrador();
        admin.setId(UUID.randomUUID());
        admin.setIdGoogle("ggl_1001");
        admin.setNickname("JuanTacos");
        admin.setCorreo("juan@test.com");

        when(administradorRepository.findByIdGoogle("ggl_1001")).thenReturn(Optional.of(admin));
        when(jwtService.generarToken(any(), any(), any(), any())).thenReturn("fake-jwt-token");

        var resultado = authService.verificarUsuario("ggl_1001");

        assertTrue(resultado.existe());
        assertEquals("fake-jwt-token", resultado.token());
        assertEquals("JuanTacos", resultado.usuario().nickname());
        assertEquals("dueño", resultado.usuario().rol());
    }

    @Test
    @DisplayName("Verificar usuario existente como cajero retorna token y datos")
    void verificarUsuario_cajeroExistente_retornaTrueConToken() {
        var cajero = new Cajero();
        cajero.setId(UUID.randomUUID());
        cajero.setIdGoogle("ggl_2001");
        cajero.setNickname("PedroCajero");
        cajero.setCorreo("pedro@test.com");

        when(administradorRepository.findByIdGoogle("ggl_2001")).thenReturn(Optional.empty());
        when(cajeroRepository.findByIdGoogle("ggl_2001")).thenReturn(Optional.of(cajero));
        when(jwtService.generarToken(any(), any(), any(), any())).thenReturn("fake-jwt-token");

        var resultado = authService.verificarUsuario("ggl_2001");

        assertTrue(resultado.existe());
        assertEquals("cajero", resultado.usuario().rol());
    }

    @Test
    @DisplayName("Verificar usuario inexistente retorna existe=false")
    void verificarUsuario_noExiste_retornaFalse() {
        when(administradorRepository.findByIdGoogle("ggl_noexiste")).thenReturn(Optional.empty());
        when(cajeroRepository.findByIdGoogle("ggl_noexiste")).thenReturn(Optional.empty());

        var resultado = authService.verificarUsuario("ggl_noexiste");

        assertFalse(resultado.existe());
        assertNull(resultado.token());
        assertNull(resultado.usuario());
    }

    @Test
    @DisplayName("Verificar admin con negocio retorna tieneNegocio=true")
    void verificarUsuario_adminConNegocio_retornaTieneNegocio() {
        var negocio = new com.jmcsoft.taco_os.domain.negocio.Negocio();
        negocio.setId(UUID.randomUUID());
        negocio.setNombre("Tacos El Güero");

        var admin = new Administrador();
        admin.setId(UUID.randomUUID());
        admin.setIdGoogle("ggl_1001");
        admin.setNickname("Juan");
        admin.setCorreo("juan@test.com");
        admin.setNegocio(negocio);

        when(administradorRepository.findByIdGoogle("ggl_1001")).thenReturn(Optional.of(admin));
        when(jwtService.generarToken(any(), any(), any(), any())).thenReturn("token");

        var resultado = authService.verificarUsuario("ggl_1001");

        assertTrue(resultado.usuario().tieneNegocio());
        assertNotNull(resultado.usuario().negocioNombre());
    }

    // === REGISTRAR ===

    @Test
    @DisplayName("Registrar nuevo dueño crea administrador y retorna token")
    void registrar_nuevoDueno_creaAdminYRetornaToken() {
        var datos = new DatosRegistroAuth("ggl_new", "NuevoDueño", "nuevo@test.com", "+52123", "dueño");

        when(administradorRepository.existsByIdGoogle("ggl_new")).thenReturn(false);
        when(cajeroRepository.existsByIdGoogle("ggl_new")).thenReturn(false);
        when(administradorRepository.save(any(Administrador.class))).thenAnswer(inv -> {
            Administrador a = inv.getArgument(0);
            a.setId(UUID.randomUUID());
            return a;
        });
        when(jwtService.generarToken(any(), any(), any(), any())).thenReturn("nuevo-token");

        var resultado = authService.registrar(datos);

        assertNotNull(resultado.token());
        assertEquals("nuevo-token", resultado.token());
        assertEquals("dueño", resultado.usuario().rol());
        verify(administradorRepository).save(any(Administrador.class));
    }

    @Test
    @DisplayName("Registrar nuevo cajero crea cajero y retorna token")
    void registrar_nuevoCajero_creaCajeroYRetornaToken() {
        var datos = new DatosRegistroAuth("ggl_caj", "NuevoCajero", "cajero@test.com", "+52124", "cajero");

        when(administradorRepository.existsByIdGoogle("ggl_caj")).thenReturn(false);
        when(cajeroRepository.existsByIdGoogle("ggl_caj")).thenReturn(false);
        when(cajeroRepository.save(any(Cajero.class))).thenAnswer(inv -> {
            Cajero c = inv.getArgument(0);
            c.setId(UUID.randomUUID());
            return c;
        });
        when(jwtService.generarToken(any(), any(), any(), any())).thenReturn("cajero-token");

        var resultado = authService.registrar(datos);

        assertNotNull(resultado.token());
        assertEquals("cajero", resultado.usuario().rol());
        verify(cajeroRepository).save(any(Cajero.class));
    }

    @Test
    @DisplayName("Registrar usuario duplicado lanza DuplicadoException")
    void registrar_usuarioDuplicado_lanzaExcepcion() {
        var datos = new DatosRegistroAuth("ggl_dup", "Dup", "dup@test.com", "+52", "dueño");

        when(administradorRepository.existsByIdGoogle("ggl_dup")).thenReturn(true);

        assertThrows(DuplicadoException.class, () -> authService.registrar(datos));
    }

    @Test
    @DisplayName("Registrar sin rol usa 'dueño' por defecto")
    void registrar_sinRol_usaDuenoPorDefecto() {
        var datos = new DatosRegistroAuth("ggl_default", "Default", "def@test.com", "+52", null);

        when(administradorRepository.existsByIdGoogle("ggl_default")).thenReturn(false);
        when(cajeroRepository.existsByIdGoogle("ggl_default")).thenReturn(false);
        when(administradorRepository.save(any(Administrador.class))).thenAnswer(inv -> {
            Administrador a = inv.getArgument(0);
            a.setId(UUID.randomUUID());
            return a;
        });
        when(jwtService.generarToken(any(), any(), any(), any())).thenReturn("token");

        var resultado = authService.registrar(datos);

        assertEquals("dueño", resultado.usuario().rol());
    }
}
