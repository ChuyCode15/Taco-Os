package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.helper.NegocioHelper;
import com.jmcsoft.taco_os.domain.negocio.dto.DatosDetalleNegocio;
import com.jmcsoft.taco_os.domain.negocio.dto.DatosRegistroNegocio;
import com.jmcsoft.taco_os.domain.negocio.mapper.NegocioMapper;
import com.jmcsoft.taco_os.repository.NegocioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class NegocioService {

    private final NegocioRepository negocioRepository;
    private final NegocioHelper negocioHelper;
    private final NegocioMapper negocioMapper;

    public DatosDetalleNegocio registrarNegocio(DatosRegistroNegocio datos) {
        negocioHelper.negocioYaRegistrado(datos.nombre());

        var negocioNuevo = negocioMapper.nuevoNegocio(datos);
        var negocio = negocioRepository.save(negocioNuevo);

        return negocioMapper.negocioADetalle(negocio);
    }
}
