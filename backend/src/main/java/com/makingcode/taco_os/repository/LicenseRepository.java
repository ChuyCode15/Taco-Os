package com.makingcode.taco_os.repository;

import com.makingcode.taco_os.domain.License;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface LicenseRepository extends JpaRepository<License, UUID> {
    Optional<License> findByBusinessId(UUID businessId);
}
