package com.makingcode.taco_os.repository;

import com.makingcode.taco_os.domain.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface ProductRepository extends JpaRepository<Product, UUID> {
    List<Product> findByBusinessId(UUID businessId);
    List<Product> findByBusinessIdAndIsSyncedFalse(UUID businessId);
}
