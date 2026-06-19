package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.domain.cancelacion.Cancelacion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface CancelacionRepository extends JpaRepository<Cancelacion, UUID> {

    Optional<Cancelacion> findByTransaccionId(UUID transaccionId);
}
