package com.jmcsoft.taco_os.services.master;

import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.domain.master.client.dto.*;
import com.jmcsoft.taco_os.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MasterClientService {

    private final AdministradorRepository administradorRepository;
    private final CajeroRepository cajeroRepository;
    private final MasterTicketRepository ticketRepository;

    @Transactional(readOnly = true)
    public List<DatosClienteLista> listarClientes() {
        return administradorRepository.findAll().stream()
                .map(admin -> new DatosClienteLista(
                        admin.getId().toString(),
                        admin.getNombreCompleto(),
                        admin.getNickname(),
                        admin.getCorreo(),
                        admin.getNumero(),
                        admin.getNegocio() != null ? admin.getNegocio().getNombre() : null,
                        admin.getTipoPlan().name(),
                        admin.getActivo(),
                        admin.getRegistro() != null ? admin.getRegistro().toString() : null
                ))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public DatosDetalleCliente obtenerDetalle(String id) {
        var admin = administradorRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new NoExisteException("Cliente no encontrado", "MasterClientService.obtenerDetalle"));

        long cajeros = cajeroRepository.count();
        long tickets = ticketRepository.countAbiertosByCliente(admin.getId());

        return new DatosDetalleCliente(
                admin.getId().toString(),
                admin.getIdGoogle(),
                admin.getNombreCompleto(),
                admin.getNickname(),
                admin.getCorreo(),
                admin.getNumero(),
                admin.getNegocio() != null ? admin.getNegocio().getId().toString() : null,
                admin.getNegocio() != null ? admin.getNegocio().getNombre() : null,
                admin.getNegocio() != null ? admin.getNegocio().getDireccion() : null,
                admin.getTipoPlan().name(),
                admin.getEstadoPlan() != null ? admin.getEstadoPlan().name() : null,
                admin.getFechaVencimiento() != null ? admin.getFechaVencimiento().toString() : null,
                admin.getActivo(),
                (int) cajeros,
                (int) tickets,
                admin.getRegistro() != null ? admin.getRegistro().toString() : null
        );
    }

    @Transactional
    public void toggleActivo(String id) {
        var admin = administradorRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new NoExisteException("Cliente no encontrado", "MasterClientService.toggleActivo"));
        admin.setActivo(!admin.getActivo());
        administradorRepository.save(admin);
    }
}
