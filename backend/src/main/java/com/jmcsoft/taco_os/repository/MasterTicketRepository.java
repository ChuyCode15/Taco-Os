package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.domain.master.ticket.MasterTicket;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.UUID;

public interface MasterTicketRepository extends JpaRepository<MasterTicket, UUID> {
    List<MasterTicket> findByClienteId(UUID clienteId);
    List<MasterTicket> findByEstado(String estado);
    List<MasterTicket> findByAsignadoA(UUID asignadoA);
    long countByEstado(String estado);

    @Query("SELECT COUNT(t) FROM MasterTicket t WHERE t.clienteId = :clienteId AND t.estado IN ('ABIERTO', 'EN_PROGRESO')")
    long countAbiertosByCliente(UUID clienteId);
}
