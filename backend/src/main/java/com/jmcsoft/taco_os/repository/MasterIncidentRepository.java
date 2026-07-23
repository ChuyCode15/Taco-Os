package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.domain.master.incident.MasterIncident;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface MasterIncidentRepository extends JpaRepository<MasterIncident, UUID> {
    List<MasterIncident> findByEstado(String estado);
    long countByEstado(String estado);
}
