package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.domain.cajero.Cajero;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CajeroRepository extends JpaRepository<Cajero, UUID> {

    Optional<Cajero> findByIdGoogle(String idGoogle);
    Boolean existsByIdGoogle(String idGoogle);
    List<Cajero> findByNegocioId(UUID negocioId);
}
