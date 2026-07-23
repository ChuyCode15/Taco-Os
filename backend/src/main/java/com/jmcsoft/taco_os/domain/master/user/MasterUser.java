package com.jmcsoft.taco_os.domain.master.user;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Table(name = "master_users")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MasterUser {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "username", nullable = false, unique = true)
    private String username;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Column(name = "full_name", nullable = false)
    private String nombreCompleto;

    @Column(name = "email", nullable = false, unique = true)
    private String correo;

    @Column(name = "role", nullable = false)
    private String rol;

    @Column(name = "is_active", nullable = false)
    private Boolean activo = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime registro;

    @PrePersist
    protected void onCreate() {
        registro = LocalDateTime.now();
    }
}
