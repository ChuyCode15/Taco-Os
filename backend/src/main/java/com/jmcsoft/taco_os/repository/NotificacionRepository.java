package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.domain.notificacion.Notificacion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface NotificacionRepository extends JpaRepository<Notificacion, UUID> {

    List<Notificacion> findByNegocioIdOrderByRegistroDesc(UUID negocioId);

    Long countByNegocioIdAndLeidoFalse(UUID negocioId);
}
