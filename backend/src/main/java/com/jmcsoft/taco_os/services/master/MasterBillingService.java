package com.jmcsoft.taco_os.services.master;

import com.jmcsoft.taco_os.domain.master.invoice.dto.*;
import com.jmcsoft.taco_os.repository.MasterInvoiceRepository;
import com.jmcsoft.taco_os.repository.AdministradorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MasterBillingService {

    private final MasterInvoiceRepository invoiceRepository;
    private final AdministradorRepository administradorRepository;

    @Transactional(readOnly = true)
    public DatosResumenFacturacion obtenerResumen() {
        var pagadas = invoiceRepository.sumPagadas();
        var pendientes = invoiceRepository.sumPendientes();

        Map<String, Integer> clientesPorPlan = administradorRepository.findAll().stream()
                .collect(Collectors.groupingBy(
                        a -> a.getTipoPlan().name(),
                        Collectors.summingInt(a -> 1)
                ));

        return new DatosResumenFacturacion(
                pagadas != null ? pagadas.add(pendientes != null ? pendientes : java.math.BigDecimal.ZERO) : java.math.BigDecimal.ZERO,
                pagadas != null ? pagadas : java.math.BigDecimal.ZERO,
                pendientes != null ? pendientes : java.math.BigDecimal.ZERO,
                pagadas != null ? pagadas : java.math.BigDecimal.ZERO,
                clientesPorPlan
        );
    }

    @Transactional(readOnly = true)
    public List<DatosFacturaLista> listarFacturas() {
        return invoiceRepository.findAll().stream()
                .map(i -> {
                    String clienteNombre = administradorRepository.findById(i.getClienteId())
                            .map(a -> a.getNombreCompleto()).orElse("Desconocido");
                    return new DatosFacturaLista(
                            i.getId().toString(),
                            clienteNombre,
                            i.getMonto(),
                            i.getPlan(),
                            i.getEstado(),
                            i.getFechaVencimiento() != null ? i.getFechaVencimiento().toString() : null,
                            i.getPagadoEl() != null ? i.getPagadoEl().toString() : null
                    );
                })
                .collect(Collectors.toList());
    }
}
