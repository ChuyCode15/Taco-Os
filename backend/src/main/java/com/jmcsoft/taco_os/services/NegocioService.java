package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.domain.negocio.dto.DatosDetalleNegocio;
import com.jmcsoft.taco_os.domain.negocio.dto.DatosRegistroNegocio;
import org.springframework.stereotype.Service;

@Service
public class NegocioService {
    public DatosDetalleNegocio registrarNegocio(DatosRegistroNegocio datos) {
        //validacion si el negocio ya existe
        // validacion si el suaurio ya tiene una cuanta
        // validacion si ya esta registrado el numero telefonio
    }
}
