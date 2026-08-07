package com.makingcode.taco_os.repository;

import com.makingcode.taco_os.domain.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface CustomerRepository extends JpaRepository<Customer, UUID> {
    Optional<Customer> findByBusinessIdAndPhone(UUID businessId, String phone);
}
