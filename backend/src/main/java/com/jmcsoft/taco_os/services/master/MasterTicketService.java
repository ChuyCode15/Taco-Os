package com.jmcsoft.taco_os.services.master;

import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.domain.master.message.MasterMessage;
import com.jmcsoft.taco_os.domain.master.message.dto.*;
import com.jmcsoft.taco_os.domain.master.ticket.MasterTicket;
import com.jmcsoft.taco_os.domain.master.ticket.dto.*;
import com.jmcsoft.taco_os.domain.master.auditlog.MasterAuditLog;
import com.jmcsoft.taco_os.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MasterTicketService {

    private final MasterTicketRepository ticketRepository;
    private final MasterMessageRepository messageRepository;
    private final MasterUserRepository masterUserRepository;
    private final AdministradorRepository administradorRepository;
    private final MasterAuditLogRepository auditLogRepository;

    @Transactional(readOnly = true)
    public List<DatosDetalleTicket> listarTickets() {
        return ticketRepository.findAll().stream()
                .map(this::mapearTicket)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public DatosDetalleTicket obtenerDetalle(String id) {
        var ticket = ticketRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new NoExisteException("Ticket no encontrado", "MasterTicketService.obtenerDetalle"));
        return mapearTicket(ticket);
    }

    @Transactional
    public DatosDetalleTicket crearTicket(DatosCrearTicket datos, String userId) {
        var ticket = new MasterTicket();
        ticket.setClienteId(UUID.fromString(datos.clienteId()));
        ticket.setTitulo(datos.titulo());
        ticket.setDescripcion(datos.descripcion());
        ticket.setPrioridad(datos.prioridad() != null ? datos.prioridad() : "NORMAL");
        ticket.setEstado("ABIERTO");
        ticket.setCreadoPor(UUID.fromString(userId));
        ticketRepository.save(ticket);
        return mapearTicket(ticket);
    }

    @Transactional
    public void asignarTicket(String ticketId, DatosAsignarTicket datos) {
        var ticket = ticketRepository.findById(UUID.fromString(ticketId))
                .orElseThrow(() -> new NoExisteException("Ticket no encontrado", "MasterTicketService.asignarTicket"));
        ticket.setAsignadoA(UUID.fromString(datos.asignadoA()));
        ticket.setEstado("EN_PROGRESO");
        ticketRepository.save(ticket);

        var audit = new MasterAuditLog();
        audit.setUsuarioId(UUID.fromString(datos.asignadoA()));
        audit.setAccion("ASSIGN_TICKET");
        audit.setTipoObjetivo("TICKET");
        audit.setObjetivoId(ticket.getId());
        audit.setDetalles("Ticket asignado");
        auditLogRepository.save(audit);
    }

    @Transactional
    public void cambiarEstado(String ticketId, String nuevoEstado) {
        var ticket = ticketRepository.findById(UUID.fromString(ticketId))
                .orElseThrow(() -> new NoExisteException("Ticket no encontrado", "MasterTicketService.cambiarEstado"));
        ticket.setEstado(nuevoEstado);
        if ("RESUELTO".equals(nuevoEstado)) {
            ticket.setResueltoEl(java.time.LocalDateTime.now());
        }
        ticketRepository.save(ticket);
    }

    @Transactional(readOnly = true)
    public List<DatosMensajeRespuesta> listarMensajes(String ticketId) {
        return messageRepository.findByTicketIdOrderByCreadoElAsc(UUID.fromString(ticketId)).stream()
                .map(this::mapearMensaje)
                .collect(Collectors.toList());
    }

    @Transactional
    public DatosMensajeRespuesta enviarMensaje(String ticketId, DatosEnviarMensaje datos, String senderId, String senderType) {
        var mensaje = new MasterMessage();
        mensaje.setTicketId(UUID.fromString(ticketId));
        mensaje.setEmisorId(UUID.fromString(senderId));
        mensaje.setTipoEmisor(senderType);
        mensaje.setContenido(datos.contenido());
        mensaje.setUrlAdjunto(datos.urlAdjunto());
        messageRepository.save(mensaje);
        return mapearMensaje(mensaje);
    }

    private DatosDetalleTicket mapearTicket(MasterTicket t) {
        String clienteNombre = administradorRepository.findById(t.getClienteId())
                .map(a -> a.getNombreCompleto()).orElse("Desconocido");
        String asignadoNombre = t.getAsignadoA() != null ?
                masterUserRepository.findById(t.getAsignadoA()).map(u -> u.getNombreCompleto()).orElse(null) : null;

        return new DatosDetalleTicket(
                t.getId().toString(),
                t.getClienteId().toString(),
                clienteNombre,
                t.getTitulo(),
                t.getDescripcion(),
                t.getPrioridad(),
                t.getEstado(),
                asignadoNombre,
                t.getCreadoEl() != null ? t.getCreadoEl().toString() : null,
                t.getResueltoEl() != null ? t.getResueltoEl().toString() : null
        );
    }

    private DatosMensajeRespuesta mapearMensaje(MasterMessage m) {
        String emisorNombre = masterUserRepository.findById(m.getEmisorId())
                .map(u -> u.getNombreCompleto())
                .orElseGet(() -> administradorRepository.findById(m.getEmisorId())
                        .map(a -> a.getNombreCompleto()).orElse("Desconocido"));

        return new DatosMensajeRespuesta(
                m.getId().toString(),
                emisorNombre,
                m.getTipoEmisor(),
                m.getContenido(),
                m.getUrlAdjunto(),
                m.getCreadoEl() != null ? m.getCreadoEl().toString() : null
        );
    }
}
