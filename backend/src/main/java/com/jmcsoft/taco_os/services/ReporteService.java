package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.enums.EstadoTransaccion;
import com.jmcsoft.taco_os.common.enums.MetodoPago;
import com.jmcsoft.taco_os.common.enums.TipoTransaccion;
import com.jmcsoft.taco_os.common.helper.NegocioHelper;
import com.jmcsoft.taco_os.repository.CashierSessionRepository;
import com.jmcsoft.taco_os.repository.DailyCutRepository;
import com.jmcsoft.taco_os.repository.TransaccionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReporteService {

    private final CashierSessionRepository sesionRepository;
    private final DailyCutRepository corteRepository;
    private final TransaccionRepository transaccionRepository;
    private final NegocioHelper negocioHelper;

    @Transactional(readOnly = true)
    public java.util.List<Map<String, Object>> cajasAbiertas(String negocioId) {
        negocioHelper.validarIdNegocio(negocioId);

        var sesiones = sesionRepository
                .findByNegocioIdAndEstado(UUID.fromString(negocioId),
                        com.jmcsoft.taco_os.common.enums.EstadoSesion.ABIERTA);

        return sesiones.stream().map(s -> {
            var totalVentas = transaccionRepository
                    .sumBySesionAndTipoAndEstado(s.getId(), TipoTransaccion.VENTA, EstadoTransaccion.COMPLETADA);
            var totalGastos = transaccionRepository
                    .sumBySesionAndTipoAndEstado(s.getId(), TipoTransaccion.GASTO, EstadoTransaccion.COMPLETADA);
            var transactionCount = transaccionRepository
                    .countBySesionIdAndEstado(s.getId(), EstadoTransaccion.COMPLETADA);

            Map<String, Object> resumen = new HashMap<>();
            resumen.put("session_id", s.getId().toString());
            resumen.put("cashier_name", s.getCajero().getNickname());
            resumen.put("branch", s.getNegocio().getNombre());
            resumen.put("opened_at", s.getApertura().toString());
            resumen.put("summary", Map.of(
                    "transaction_count", transactionCount,
                    "total_sales", totalVentas,
                    "total_expenses", totalGastos
            ));
            return resumen;
        }).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public java.util.List<Map<String, Object>> listaCortes(String negocioId) {
        negocioHelper.validarIdNegocio(negocioId);

        return corteRepository
                .findByNegocioIdOrderByCierreDesc(UUID.fromString(negocioId))
                .stream()
                .map(c -> {
                    Map<String, Object> mapa = new HashMap<>();
                    mapa.put("cut_id", c.getId().toString());
                    mapa.put("cashier_name", c.getCajero().getNickname());
                    mapa.put("branch", c.getNegocio().getNombre());
                    mapa.put("opened_at", c.getApertura().toString());
                    mapa.put("closed_at", c.getCierre().toString());
                    mapa.put("total_sales", c.getTotalVentas());
                    mapa.put("total_expenses", c.getTotalGastos());
                    mapa.put("difference", c.getDiferencia());
                    mapa.put("status", c.getEstado().name().toLowerCase());
                    return mapa;
                })
                .collect(Collectors.toList());
    }
}
