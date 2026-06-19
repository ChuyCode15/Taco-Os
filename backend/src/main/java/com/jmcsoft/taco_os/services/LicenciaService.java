package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.enums.EstadoPlan;
import com.jmcsoft.taco_os.common.enums.TipoPlan;
import com.jmcsoft.taco_os.common.exception.NoExisteException;
import com.jmcsoft.taco_os.common.helper.NegocioHelper;
import com.jmcsoft.taco_os.domain.cajero.Cajero;
import com.jmcsoft.taco_os.domain.licencia.Licencia;
import com.jmcsoft.taco_os.domain.licencia.dto.DatosDetalleLicencia;
import com.jmcsoft.taco_os.domain.licencia.dto.DatosListaPlanes;
import com.jmcsoft.taco_os.domain.licencia.dto.DatosPlan;
import com.jmcsoft.taco_os.domain.licencia.dto.DatosRespuestaPlan;
import com.jmcsoft.taco_os.domain.licencia.dto.DatosUpgradePlan;
import com.jmcsoft.taco_os.repository.CajeroRepository;
import com.jmcsoft.taco_os.repository.LicenciaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LicenciaService {

    private final LicenciaRepository licenciaRepository;
    private final CajeroRepository cajeroRepository;
    private final NegocioHelper negocioHelper;

    @Transactional(readOnly = true)
    public DatosListaPlanes listarPlanes() {
        var planes = List.of(
                new DatosPlan("free", 0, "MXN", "month", 1, 2, List.of("basic_reports", "cashier_management"), false, null),
                new DatosPlan("premium", 199, "MXN", "month", 2, 5, List.of("basic_reports", "detailed_reports", "cashier_management", "multiple_branches"), true, 14),
                new DatosPlan("business", 499, "MXN", "month", 5, 25, List.of("basic_reports", "detailed_reports", "cashier_management", "multiple_branches", "ai_insights"), true, 14)
        );
        return new DatosListaPlanes(planes);
    }

    @Transactional(readOnly = true)
    public DatosDetalleLicencia obtenerLicencia(String negocioId) {
        var negocio = negocioHelper.validarIdNegocio(negocioId);

        var licencia = licenciaRepository.findByNegocioId(negocio.getId())
                .orElseThrow(() -> new NoExisteException("Licencia no encontrada", "LicenciaService.obtenerLicencia"));

        var cajerosActuales = cajeroRepository.findByNegocioId(negocio.getId()).size();

        Long diasRestantes = null;
        if (licencia.getFechaFinTrial() != null && licencia.getFechaFinTrial().isAfter(LocalDate.now())) {
            diasRestantes = ChronoUnit.DAYS.between(LocalDate.now(), licencia.getFechaFinTrial());
        }

        return new DatosDetalleLicencia(
                licencia.getPlan().name().toLowerCase(),
                licencia.getEstado().name().toLowerCase(),
                licencia.getFechaInicio().toString(),
                licencia.getFechaFin() != null ? licencia.getFechaFin().toString() : null,
                licencia.getFechaFinTrial() != null ? licencia.getFechaFinTrial().toString() : null,
                diasRestantes != null ? diasRestantes.intValue() : null,
                licencia.getMaxCajeros(),
                cajerosActuales,
                licencia.getMaxNegocios(),
                1,
                List.of("basic_reports", "cashier_management")
        );
    }

    @Transactional
    public DatosRespuestaPlan mejorarPlan(String negocioId, DatosUpgradePlan datos) {
        var negocio = negocioHelper.validarIdNegocio(negocioId);

        var licencia = licenciaRepository.findByNegocioId(negocio.getId())
                .orElseThrow(() -> new NoExisteException("Licencia no encontrada", "LicenciaService.mejorarPlan"));

        var nuevoPlan = TipoPlan.valueOf(datos.plan().toUpperCase());
        licencia.setPlan(nuevoPlan);
        licencia.setEstado(EstadoPlan.PAGADO);
        licencia.setFechaFin(LocalDate.now().plusMonths(12));

        switch (nuevoPlan) {
            case PREMIUM -> {
                licencia.setMaxNegocios(2);
                licencia.setMaxCajeros(5);
            }
            case BUSINESS -> {
                licencia.setMaxNegocios(5);
                licencia.setMaxCajeros(25);
            }
            default -> {
                licencia.setMaxNegocios(1);
                licencia.setMaxCajeros(2);
            }
        }

        licenciaRepository.save(licencia);

        return new DatosRespuestaPlan(
                "active",
                licencia.getPlan().name().toLowerCase(),
                licencia.getFechaFin().toString(),
                "Plan actualizado exitosamente."
        );
    }

    @Transactional
    public DatosRespuestaPlan activarTrial(String negocioId, String plan) {
        var negocio = negocioHelper.validarIdNegocio(negocioId);

        var licencia = licenciaRepository.findByNegocioId(negocio.getId())
                .orElseThrow(() -> new NoExisteException("Licencia no encontrada", "LicenciaService.activarTrial"));

        var planTrial = TipoPlan.valueOf(plan.toUpperCase());
        licencia.setPlan(planTrial);
        licencia.setEstado(EstadoPlan.TRIAL_PREMIUM);
        licencia.setFechaFinTrial(LocalDate.now().plusDays(14));

        switch (planTrial) {
            case PREMIUM -> {
                licencia.setMaxNegocios(2);
                licencia.setMaxCajeros(5);
            }
            case BUSINESS -> {
                licencia.setMaxNegocios(5);
                licencia.setMaxCajeros(25);
            }
            default -> {}
        }

        licenciaRepository.save(licencia);

        return new DatosRespuestaPlan(
                "trial",
                licencia.getPlan().name().toLowerCase(),
                licencia.getFechaFinTrial().toString(),
                "14 días de prueba activados."
        );
    }
}
