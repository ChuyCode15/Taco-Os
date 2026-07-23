package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.domain.superusuario.SuperUsuario;
import com.jmcsoft.taco_os.domain.superusuario.dto.DatosLoginSuperSu;
import com.jmcsoft.taco_os.repository.AdministradorRepository;
import com.jmcsoft.taco_os.repository.CajeroRepository;
import com.jmcsoft.taco_os.repository.NegocioRepository;
import com.jmcsoft.taco_os.repository.SuperUsuarioRepository;
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
class SuperSuServiceTest {

    @Mock private SuperUsuarioRepository superUsuarioRepository;
    @Mock private AdministradorRepository administradorRepository;
    @Mock private NegocioRepository negocioRepository;
    @Mock private CajeroRepository cajeroRepository;
    @Mock private JwtService jwtService;

    @InjectMocks
    private SuperSuService superSuService;

    @BeforeEach
    void setUp() {
        var expField = org.springframework.util.ReflectionUtils.findField(SuperSuService.class, "expirationMs");
        org.springframework.util.ReflectionUtils.makeAccessible(expField);
        org.springframework.util.ReflectionUtils.setField(expField, superSuService, 3600000L);
    }

    @Test
    @DisplayName("Login con credenciales correctas retorna token")
    void login_credencialesCorrectas_retornaToken() {
        var superUser = new SuperUsuario();
        superUser.setId(UUID.randomUUID());
        superUser.setUsername("SuperSu");
        superUser.setPasswordHash("AdminSu");
        superUser.setNombreCompleto("Super Administrador");

        when(superUsuarioRepository.findByUsername("SuperSu")).thenReturn(Optional.of(superUser));
        when(jwtService.generarToken(any(), any(), any(), any())).thenReturn("super-jwt-token");

        var resultado = superSuService.login(new DatosLoginSuperSu("SuperSu", "AdminSu"));

        assertNotNull(resultado.token());
        assertEquals("super-jwt-token", resultado.token());
        assertEquals("SuperSu", resultado.username());
    }

    @Test
    @DisplayName("Login con usuario inexistente lanza excepción")
    void login_usuarioInexistente_lanzaExcepcion() {
        when(superUsuarioRepository.findByUsername("NoExiste")).thenReturn(Optional.empty());

        assertThrows(NoExisteException.class,
                () -> superSuService.login(new DatosLoginSuperSu("NoExiste", "pass")));
    }

    @Test
    @DisplayName("Login con contraseña incorrecta lanza excepción")
    void login_contrasenaIncorrecta_lanzaExcepcion() {
        var superUser = new SuperUsuario();
        superUser.setUsername("SuperSu");
        superUser.setPasswordHash("AdminSu");

        when(superUsuarioRepository.findByUsername("SuperSu")).thenReturn(Optional.of(superUser));

        assertThrows(NoExisteException.class,
                () -> superSuService.login(new DatosLoginSuperSu("SuperSu", "WrongPass")));
    }

    @Test
    @DisplayName("Detalle admin existente retorna datos correctos")
    void detalleAdmin_existe_retornaDatos() {
        var admin = new com.jmcsoft.taco_os.domain.administrador.Administrador();
        admin.setId(UUID.randomUUID());
        admin.setIdGoogle("ggl_1001");
        admin.setNombreCompleto("Juan Pérez");
        admin.setNickname("Juan");
        admin.setCorreo("juan@test.com");
        admin.setActivo(true);

        when(administradorRepository.findById(any(UUID.class))).thenReturn(Optional.of(admin));

        var resultado = superSuService.detalleAdmin(admin.getId().toString());

        assertEquals("Juan Pérez", resultado.nombreCompleto());
        assertEquals("ggl_1001", resultado.idGoogle());
        assertTrue(resultado.activo());
    }

    @Test
    @DisplayName("Detalle admin inexistente lanza excepción")
    void detalleAdmin_noExiste_lanzaExcepcion() {
        when(administradorRepository.findById(any(UUID.class))).thenReturn(Optional.empty());

        assertThrows(NoExisteException.class,
                () -> superSuService.detalleAdmin(UUID.randomUUID().toString()));
    }

    @Test
    @DisplayName("Activar admin cambia estado a activo")
    void activarAdmin_cambiaEstado() {
        var admin = new com.jmcsoft.taco_os.domain.administrador.Administrador();
        admin.setId(UUID.randomUUID());
        admin.setActivo(false);

        when(administradorRepository.findById(any(UUID.class))).thenReturn(Optional.of(admin));

        superSuService.activarAdmin(admin.getId().toString());

        assertTrue(admin.getActivo());
        verify(administradorRepository).save(admin);
    }

    @Test
    @DisplayName("Desactivar admin cambia estado a inactivo")
    void desactivarAdmin_cambiaEstado() {
        var admin = new com.jmcsoft.taco_os.domain.administrador.Administrador();
        admin.setId(UUID.randomUUID());
        admin.setActivo(true);

        when(administradorRepository.findById(any(UUID.class))).thenReturn(Optional.of(admin));

        superSuService.desactivarAdmin(admin.getId().toString());

        assertFalse(admin.getActivo());
        verify(administradorRepository).save(admin);
    }
}
