package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.domain.producto.Producto;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ProductoRepository extends JpaRepository<Producto, UUID> {

    Boolean findByNombreAndActivoTrue(String nombre);

}
