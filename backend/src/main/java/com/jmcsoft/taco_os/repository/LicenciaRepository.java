package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.domain.licencia.Licencia;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface LicenciaRepository extends JpaRepository<Licencia, UUID> {

    Optional<Licencia> findByNegocioId(UUID negocioId);
}
