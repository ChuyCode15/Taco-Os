package com.makingcode.taco_os.domain;

import jakarta.persistence.*;
import lombok.Data;
import java.util.UUID;

@Entity
@Table(name = "users")
@Data
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String email;

    private String googleId;

    @Enumerated(EnumType.STRING)
    private Role role;

    private String phone;

    private UUID businessId;

    public enum Role {
        owner, cashier
    }
}
