package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.common.enums.EstadoSesion;
import com.jmcsoft.taco_os.domain.sesioncajero.CashierSession;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CashierSessionRepository extends JpaRepository<CashierSession, UUID> {

    Optional<CashierSession> findByNegocioIdAndCajeroIdAndEstado(UUID negocioId, UUID cajeroId, EstadoSesion estado);

    List<CashierSession> findByNegocioIdAndEstado(UUID negocioId, EstadoSesion estado);

    Optional<CashierSession> findByIdAndNegocioId(UUID id, UUID negocioId);
}
