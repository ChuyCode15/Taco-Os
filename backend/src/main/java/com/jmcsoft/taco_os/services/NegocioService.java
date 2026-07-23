package com.jmcsoft.taco_os.services;

import com.jmcsoft.taco_os.common.helper.AdministradorHelper;
import com.jmcsoft.taco_os.common.helper.NegocioHelper;
import com.jmcsoft.taco_os.domain.licencia.Licencia;
import com.jmcsoft.taco_os.domain.negocio.dto.DatosDetalleNegocio;
import com.jmcsoft.taco_os.domain.negocio.dto.DatosRegistroNegocio;
import com.jmcsoft.taco_os.domain.negocio.mapper.NegocioMapper;
import com.jmcsoft.taco_os.domain.cajero.dto.DatosListaCajero;
import com.jmcsoft.taco_os.domain.cajero.dto.DatosListaCajeros;
import com.jmcsoft.taco_os.domain.cajero.mapper.CajeroMapper;
import com.jmcsoft.taco_os.repository.AdministradorRepository;
import com.jmcsoft.taco_os.repository.CajeroRepository;
import com.jmcsoft.taco_os.repository.LicenciaRepository;
import com.jmcsoft.taco_os.repository.NegocioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NegocioService {

    private final NegocioRepository negocioRepository;
    private final AdministradorRepository administradorRepository;
    private final CajeroRepository cajeroRepository;
    private final LicenciaRepository licenciaRepository;
    private final NegocioHelper negocioHelper;
    private final AdministradorHelper administradorHelper;
    private final NegocioMapper negocioMapper;
    private final CajeroMapper cajeroMapper;

    @Transactional
    public DatosDetalleNegocio registrarNegocio(DatosRegistroNegocio datos, String duenoId) {
        negocioHelper.negocioYaRegistrado(datos.nombre());

        var dueno = administradorHelper.validarIdAdministrador(duenoId);
        var negocioNuevo = negocioMapper.nuevoNegocio(datos);
        var negocio = negocioRepository.save(negocioNuevo);

        dueno.setNegocio(negocio);
        administradorRepository.save(dueno);

        var licencia = new Licencia();
        licencia.setNegocio(negocio);
        licenciaRepository.save(licencia);

        return negocioMapper.negocioADetalle(negocio);
    }

    @Transactional(readOnly = true)
    public DatosDetalleNegocio obtenerDetalle(String id) {
        var negocio = negocioHelper.validarIdNegocio(id);
        return negocioMapper.negocioADetalle(negocio);
    }

    @Transactional
    public DatosDetalleNegocio editarNegocio(String id, DatosRegistroNegocio datos) {
        var negocio = negocioHelper.validarIdNegocio(id);

        negocio.setNombre(datos.nombre());
        negocio.setDireccion(datos.direccion());
        negocio.setTelefono(datos.telefono());
        negocio.setGiro(datos.giro());
        negocio.setHorarioCierre(datos.horarioCierre());
        negocio.setEmpleados(datos.empleados());

        var negocioActualizado = negocioRepository.save(negocio);
        return negocioMapper.negocioADetalle(negocioActualizado);
    }

    @Transactional(readOnly = true)
    public DatosListaCajeros listarCajeros(String negocioId) {
        negocioHelper.validarIdNegocio(negocioId);

        var lista = cajeroRepository.findByNegocioId(UUID.fromString(negocioId))
                .stream()
                .map(cajeroMapper::cajeroALista)
                .collect(Collectors.toList());
        return new DatosListaCajeros(lista);
    }
}
