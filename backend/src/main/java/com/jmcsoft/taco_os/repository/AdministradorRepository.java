package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.domain.administrador.Administrador;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface AdministradorRepository extends JpaRepository<Administrador, UUID> {

    Optional<Administrador> findByIdGoogle(String idGoogle);
    Boolean existsByIdGoogle(String idGoogle);
}
