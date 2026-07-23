package com.jmcsoft.taco_os.services.master;

import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.common.exception.DuplicadoException;
import com.jmcsoft.taco_os.domain.master.team.dto.*;
import com.jmcsoft.taco_os.domain.master.user.MasterUser;
import com.jmcsoft.taco_os.repository.MasterUserRepository;
import com.jmcsoft.taco_os.repository.MasterTicketRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MasterTeamService {

    private final MasterUserRepository masterUserRepository;
    private final MasterTicketRepository ticketRepository;

    @Transactional(readOnly = true)
    public List<DatosMiembroEquipo> listarMiembros() {
        return masterUserRepository.findAll().stream()
                .map(this::mapearMiembro)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public DatosMiembroEquipo obtenerMiembro(String id) {
        var user = masterUserRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new NoExisteException("Miembro no encontrado", "MasterTeamService.obtenerMiembro"));
        return mapearMiembro(user);
    }

    @Transactional
    public DatosMiembroEquipo crearMiembro(DatosCrearMiembro datos) {
        if (masterUserRepository.existsByUsername(datos.username())) {
            throw new DuplicadoException("El username ya existe", "MasterTeamService.crearMiembro");
        }
        if (masterUserRepository.existsByCorreo(datos.correo())) {
            throw new DuplicadoException("El email ya existe", "MasterTeamService.crearMiembro");
        }

        var user = new MasterUser();
        user.setUsername(datos.username());
        user.setPasswordHash(datos.password());
        user.setNombreCompleto(datos.nombreCompleto());
        user.setCorreo(datos.correo());
        user.setRol(datos.rol());
        user.setActivo(true);
        masterUserRepository.save(user);
        return mapearMiembro(user);
    }

    @Transactional
    public void toggleActivo(String id) {
        var user = masterUserRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new NoExisteException("Miembro no encontrado", "MasterTeamService.toggleActivo"));
        user.setActivo(!user.getActivo());
        masterUserRepository.save(user);
    }

    private DatosMiembroEquipo mapearMiembro(MasterUser u) {
        long tickets = ticketRepository.findByAsignadoA(u.getId()).stream()
                .filter(t -> "ABIERTO".equals(t.getEstado()) || "EN_PROGRESO".equals(t.getEstado()))
                .count();

        return new DatosMiembroEquipo(
                u.getId().toString(),
                u.getUsername(),
                u.getNombreCompleto(),
                u.getCorreo(),
                u.getRol(),
                u.getActivo(),
                (int) tickets,
                u.getRegistro() != null ? u.getRegistro().toString() : null
        );
    }
}
