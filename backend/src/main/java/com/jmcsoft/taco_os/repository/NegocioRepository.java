package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.domain.negocio.Negocio;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface NegocioRepository extends JpaRepository<Negocio, UUID> {

    Boolean existsByNombreAndActivoTrue(String nombre);
}
