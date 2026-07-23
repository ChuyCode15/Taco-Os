package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.domain.master.user.MasterUser;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface MasterUserRepository extends JpaRepository<MasterUser, UUID> {
    Optional<MasterUser> findByUsername(String username);
    boolean existsByUsername(String username);
    boolean existsByCorreo(String correo);
}
