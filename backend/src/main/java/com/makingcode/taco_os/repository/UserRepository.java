package com.makingcode.taco_os.repository;

import com.makingcode.taco_os.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    Optional<User> findByGoogleId(String googleId);
    long countByBusinessIdAndRole(UUID businessId, User.Role role);
}
