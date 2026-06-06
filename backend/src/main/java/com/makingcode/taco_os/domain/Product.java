package com.makingcode.taco_os.domain;

import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;
import java.util.UUID;

@Table
@Entity

@Data

public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    UUID id;

    @Column(nullable = false)
    String name;

    BigDecimal price;

    UUID category_id;

    UUID business_id;

    String is_synced;


}
