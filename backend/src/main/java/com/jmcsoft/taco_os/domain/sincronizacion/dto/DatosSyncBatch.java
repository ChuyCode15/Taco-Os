package com.jmcsoft.taco_os.domain.sincronizacion;

import com.jmcsoft.taco_os.domain.sesioncajero.dto.DatosAperturaSesion;
import com.jmcsoft.taco_os.domain.transaccion.dto.DatosRegistroTransaccion;

import java.util.List;

public record DatosSyncBatch(
        List<DatosRegistroTransaccion> transactions,
        List<DatosAperturaSesion> sessions,
        List<ProductoDto> products,
        List<CorteCajaDto> cuts
) {}

