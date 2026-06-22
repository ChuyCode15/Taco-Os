package com.jmcsoft.taco_os.services.master;

import com.jmcsoft.taco_os.domain.master.user.MasterUser;
import com.jmcsoft.taco_os.domain.master.user.dto.*;
import com.jmcsoft.taco_os.repository.MasterUserRepository;
import com.jmcsoft.taco_os.services.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MasterAuthService {

    private final MasterUserRepository masterUserRepository;
    private final JwtService jwtService;

    @Value("${jwt.expiration-ms}")
    private long expirationMs;

    @Transactional(readOnly = true)
    public DatosRespuestaMaster login(DatosLoginMaster datos) {
        var user = masterUserRepository.findByUsername(datos.username())
                .orElseThrow(() -> new com.jmcsoft.taco_os.common.exception.NoExisteException(
                        "Usuario no encontrado", "MasterAuthService.login"));

        if (!user.getActivo()) {
            throw new com.jmcsoft.taco_os.common.exception.NoAutorizadoException(
                    "Usuario desactivado", "MasterAuthService.login");
        }

        if (!user.getPasswordHash().equals(datos.password())) {
            throw new com.jmcsoft.taco_os.common.exception.NoAutorizadoException(
                    "Contraseña incorrecta", "MasterAuthService.login");
        }

        String token = jwtService.generarToken(
                user.getId().toString(),
                user.getUsername(),
                "master_" + user.getRol(),
                user.getNombreCompleto()
        );

        var usuario = new DatosUsuarioMaster(
                user.getId().toString(),
                user.getUsername(),
                user.getNombreCompleto(),
                user.getCorreo(),
                user.getRol()
        );

        return new DatosRespuestaMaster(token, (int)(expirationMs / 3600000), usuario);
    }

    @Transactional(readOnly = true)
    public DatosUsuarioMaster obtenerUsuario(String id) {
        var user = masterUserRepository.findById(java.util.UUID.fromString(id))
                .orElseThrow(() -> new com.jmcsoft.taco_os.common.exception.NoExisteException(
                        "Usuario no encontrado", "MasterAuthService.obtenerUsuario"));

        return new DatosUsuarioMaster(
                user.getId().toString(),
                user.getUsername(),
                user.getNombreCompleto(),
                user.getCorreo(),
                user.getRol()
        );
    }
}
