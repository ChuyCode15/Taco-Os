package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.domain.master.message.MasterMessage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface MasterMessageRepository extends JpaRepository<MasterMessage, UUID> {
    List<MasterMessage> findByTicketIdOrderByCreadoElAsc(UUID ticketId);
}
