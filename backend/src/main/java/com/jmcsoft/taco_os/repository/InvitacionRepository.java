package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.domain.enlace.Invitacion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface InvitacionRepository extends JpaRepository<Invitacion, UUID> {

    Optional<Invitacion> findByCodigoAndActivoTrue(String codigo);
}
