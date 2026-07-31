package com.makingcode.taco_os.repository;

import com.makingcode.taco_os.domain.Business;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface BusinessRepository extends JpaRepository<Business, UUID> {
    long countByOwnerId(UUID ownerId);
}
