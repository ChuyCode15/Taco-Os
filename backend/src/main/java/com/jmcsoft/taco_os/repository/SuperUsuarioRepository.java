package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.domain.superusuario.SuperUsuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface SuperUsuarioRepository extends JpaRepository<SuperUsuario, UUID> {

    Optional<SuperUsuario> findByUsername(String username);

    Boolean existsByUsername(String username);
}
