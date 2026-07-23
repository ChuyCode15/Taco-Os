package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.domain.administrador.Administrador;
import com.jmcsoft.taco_os.domain.superusuario.dto.DatosDetalleAdminTenant;
import com.jmcsoft.taco_os.domain.superusuario.dto.DatosLoginSuperSu;
import com.jmcsoft.taco_os.domain.superusuario.dto.DatosRespuestaSuperSu;
import com.jmcsoft.taco_os.repository.AdministradorRepository;
import com.jmcsoft.taco_os.repository.CajeroRepository;
import com.jmcsoft.taco_os.repository.NegocioRepository;
import com.jmcsoft.taco_os.repository.SuperUsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SuperSuService {

    private final SuperUsuarioRepository superUsuarioRepository;
    private final AdministradorRepository administradorRepository;
    private final NegocioRepository negocioRepository;
    private final CajeroRepository cajeroRepository;
    private final JwtService jwtService;

    @Value("${jwt.expiration-ms}")
    private long expirationMs;

    @Transactional(readOnly = true)
    public DatosRespuestaSuperSu login(DatosLoginSuperSu datos) {
        var superUser = superUsuarioRepository.findByUsername(datos.username())
                .orElseThrow(() -> new NoExisteException(
                        "Credenciales inválidas",
                        "SuperSuService.login"
                ));

        // Plain text comparison for dev (seed data uses plain text)
        // In production, use PasswordEncoder
        if (!superUser.getPasswordHash().equals(datos.password())) {
            throw new NoExisteException(
                    "Credenciales inválidas",
                    "SuperSuService.login"
            );
        }

        String token = jwtService.generarToken(
                superUser.getId().toString(),
                superUser.getUsername(),
                "super_admin",
                superUser.getNombreCompleto()
        );

        return new DatosRespuestaSuperSu(
                token,
                (int)(expirationMs / 1000),
                superUser.getUsername(),
                superUser.getNombreCompleto()
        );
    }

    @Transactional(readOnly = true)
    public List<DatosDetalleAdminTenant> listarAdmins() {
        return administradorRepository.findAll().stream()
                .map(this::toAdminTenant)
                .toList();
    }

    @Transactional(readOnly = true)
    public DatosDetalleAdminTenant detalleAdmin(String id) {
        var admin = administradorRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new NoExisteException(
                        "Administrador no encontrado con ID: " + id,
                        "SuperSuService.detalleAdmin"
                ));
        return toAdminTenant(admin);
    }

    @Transactional
    public void activarAdmin(String id) {
        var admin = administradorRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new NoExisteException(
                        "Administrador no encontrado con ID: " + id,
                        "SuperSuService.activarAdmin"
                ));
        admin.setActivo(true);
        administradorRepository.save(admin);
    }

    @Transactional
    public void desactivarAdmin(String id) {
        var admin = administradorRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new NoExisteException(
                        "Administrador no encontrado con ID: " + id,
                        "SuperSuService.desactivarAdmin"
                ));
        admin.setActivo(false);
        administradorRepository.save(admin);
    }

    @Transactional(readOnly = true)
    public Object estadisticas() {
        long totalAdmins = administradorRepository.count();
        long adminsActivos = administradorRepository.findAll().stream()
                .filter(Administrador::getActivo).count();
        long totalNegocios = negocioRepository.count();
        long totalCajeros = cajeroRepository.count();

        return new Object() {
            public final long totalAdmins = administradorRepository.count();
            public final long adminsActivos = administradorRepository.findAll().stream()
                    .filter(Administrador::getActivo).count();
            public final long totalNegocios = negocioRepository.count();
            public final long totalCajeros = cajeroRepository.count();
        };
    }

    private DatosDetalleAdminTenant toAdminTenant(Administrador admin) {
        return new DatosDetalleAdminTenant(
                admin.getId().toString(),
                admin.getIdGoogle(),
                admin.getNombreCompleto(),
                admin.getNickname(),
                admin.getCorreo(),
                admin.getNumero(),
                admin.getNegocio() != null ? admin.getNegocio().getId().toString() : null,
                admin.getNegocio() != null ? admin.getNegocio().getNombre() : null,
                admin.getTipoPlan() != null ? admin.getTipoPlan().name() : null,
                admin.getEstadoPlan() != null ? admin.getEstadoPlan().name() : null,
                admin.getFechaVencimiento() != null ? admin.getFechaVencimiento().toString() : null,
                admin.getActivo(),
                admin.getRegistro() != null ? admin.getRegistro().toLocalDate().toString() : null
        );
    }
}
