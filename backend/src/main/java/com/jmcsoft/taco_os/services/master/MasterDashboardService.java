package com.jmcsoft.taco_os.services.master;

import com.jmcsoft.taco_os.domain.master.dashboard.dto.DatosEstadisticas;
import com.jmcsoft.taco_os.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;

@Service
@RequiredArgsConstructor
public class MasterDashboardService {

    private final AdministradorRepository administradorRepository;
    private final CajeroRepository cajeroRepository;
    private final MasterTicketRepository ticketRepository;
    private final MasterIncidentRepository incidentRepository;
    private final MasterInvoiceRepository invoiceRepository;
    private final MasterAuditLogRepository auditLogRepository;

    @Transactional(readOnly = true)
    public DatosEstadisticas obtenerEstadisticas() {
        int totalAdmins = administradorRepository.findAll().size();
        int totalCajeros = cajeroRepository.findAll().size();
        long ticketsAbiertos = ticketRepository.countByEstado("ABIERTO") + ticketRepository.countByEstado("EN_PROGRESO");
        long ticketsResueltos = ticketRepository.countByEstado("RESUELTO");
        long incidenciasAbiertas = incidentRepository.countByEstado("DETECTADA") + incidentRepository.countByEstado("EN_INVESTIGACION") + incidentRepository.countByEstado("EN_REPARACION");
        BigDecimal ingresosMensuales = invoiceRepository.sumPagadas();
        BigDecimal pendientes = invoiceRepository.sumPendientes();

        Map<String, Integer> clientesPorPlan = new HashMap<>();
        clientesPorPlan.put("PREMIUM", 0);
        clientesPorPlan.put("BUSINESS", 0);
        clientesPorPlan.put("FREE", 0);

        List<Map<String, Object>> actividadReciente = new ArrayList<>();
        var logs = auditLogRepository.findTop20ByOrderByCreadoElDesc();
        for (var log : logs) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", log.getId().toString());
            item.put("accion", log.getAccion());
            item.put("tipoObjetivo", log.getTipoObjetivo());
            item.put("detalles", log.getDetalles());
            item.put("creadoEl", log.getCreadoEl().toString());
            actividadReciente.add(item);
        }

        return new DatosEstadisticas(
                totalAdmins, 0, 0,
                ingresosMensuales != null ? ingresosMensuales : BigDecimal.ZERO,
                (int) ticketsAbiertos, (int) ticketsResueltos, (int) incidenciasAbiertas,
                clientesPorPlan, new ArrayList<>(), actividadReciente
        );
    }
}
