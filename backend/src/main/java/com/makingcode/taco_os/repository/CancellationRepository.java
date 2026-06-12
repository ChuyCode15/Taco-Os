package com.makingcode.taco_os.repository;

import com.makingcode.taco_os.domain.Cancellation;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface CancellationRepository extends JpaRepository<Cancellation, UUID> {
    List<Cancellation> findByBusinessIdOrderByCreatedAtDesc(UUID businessId);
}
