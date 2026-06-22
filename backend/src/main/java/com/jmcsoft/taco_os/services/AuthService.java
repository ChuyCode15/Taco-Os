package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.exception.DuplicadoException;
import com.jmcsoft.taco_os.domain.administrador.Administrador;
import com.jmcsoft.taco_os.domain.auth.dto.*;
import com.jmcsoft.taco_os.domain.cajero.Cajero;
import com.jmcsoft.taco_os.repository.AdministradorRepository;
import com.jmcsoft.taco_os.repository.CajeroRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AdministradorRepository administradorRepository;
    private final CajeroRepository cajeroRepository;
    private final JwtService jwtService;

    @Value("${jwt.expiration-ms}")
    private long expirationMs;

    @Transactional(readOnly = true)
    public DatosVerificacionAuth verificarUsuario(String idGoogle) {



        var admin = administradorRepository.findByIdGoogle(idGoogle);
        if (admin.isPresent()) {
            var u = admin.get();
            var usuario = new DatosUsuarioAuth(
                    u.getId().toString(),
                    u.getIdGoogle(),
                    u.getNickname(),
                    u.getCorreo(),
                    "dueño",
                    u.getNegocio() != null,
                    u.getNegocio() != null ? u.getNegocio().getId().toString() : null,
                    u.getNegocio() != null ? u.getNegocio().getNombre() : null
            );
            String token = jwtService.generarToken(u.getId().toString(), u.getIdGoogle(), "dueño", u.getNickname());
            return new DatosVerificacionAuth(true, token, (int)(expirationMs / 3600000), usuario);
        }

        var cajero = cajeroRepository.findByIdGoogle(idGoogle);
        if (cajero.isPresent()) {
            var c = cajero.get();
            var usuario = new DatosUsuarioAuth(
                    c.getId().toString(),
                    c.getIdGoogle(),
                    c.getNickname(),
                    c.getCorreo(),
                    "cajero",
                    c.getNegocio() != null,
                    c.getNegocio() != null ? c.getNegocio().getId().toString() : null,
                    c.getNegocio() != null ? c.getNegocio().getNombre() : null
            );
            String token = jwtService.generarToken(c.getId().toString(), c.getIdGoogle(), "cajero", c.getNickname());
            return new DatosVerificacionAuth(true, token, (int)(expirationMs / 3600000), usuario);
        }

        return new DatosVerificacionAuth(false, null, null, null);
    }

    @Transactional
    public DatosRespuestaAuth registrar(DatosRegistroAuth datos) {
        if (administradorRepository.existsByIdGoogle(datos.idGoogle()) ||
                cajeroRepository.existsByIdGoogle(datos.idGoogle())) {
            throw new DuplicadoException(
                    "Ya existe un usuario registrado con ese idGoogle",
                    "AuthService.registrar"
            );
        }

        String rol = datos.rol() != null ? datos.rol() : "dueño";

        if ("cajero".equalsIgnoreCase(rol)) {
            var cajero = new Cajero();
            cajero.setIdGoogle(datos.idGoogle());
            cajero.setNombreCompleto(datos.nickname());
            cajero.setNickname(datos.nickname());
            cajero.setCorreo(datos.correo());
            cajero.setNumero(datos.numero());
            cajeroRepository.save(cajero);

            var usuario = new DatosUsuarioAuth(
                    cajero.getId().toString(),
                    cajero.getIdGoogle(),
                    cajero.getNickname(),
                    cajero.getCorreo(),
                    "cajero",
                    false, null, null
            );
            String token = jwtService.generarToken(cajero.getId().toString(), cajero.getIdGoogle(), "cajero", cajero.getNickname());
            return new DatosRespuestaAuth(token, (int)(expirationMs / 3600000), usuario);
        } else {
            var admin = new Administrador();
            admin.setIdGoogle(datos.idGoogle());
            admin.setNombreCompleto(datos.nickname());
            admin.setNickname(datos.nickname());
            admin.setCorreo(datos.correo());
            admin.setNumero(datos.numero());
            administradorRepository.save(admin);

            var usuario = new DatosUsuarioAuth(
                    admin.getId().toString(),
                    admin.getIdGoogle(),
                    admin.getNickname(),
                    admin.getCorreo(),
                    "dueño",
                    false, null, null
            );
            String token = jwtService.generarToken(admin.getId().toString(), admin.getIdGoogle(), "dueño", admin.getNickname());
            return new DatosRespuestaAuth(token, (int)(expirationMs / 3600000), usuario);
        }
    }
}
