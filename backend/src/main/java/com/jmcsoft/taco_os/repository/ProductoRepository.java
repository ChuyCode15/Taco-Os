package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.common.enums.Categoria;
import com.jmcsoft.taco_os.domain.producto.Producto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ProductoRepository extends JpaRepository<Producto, UUID> {

    boolean existsByNombreAndNegocioIdAndActivoTrue(String nombre, UUID negocioId);

    Page<Producto> findByNegocioIdAndActivoTrue(UUID negocioId, Pageable pageable);

    Page<Producto> findByNegocioIdAndCategoriaAndActivoTrue(UUID negocioId, Categoria categoria, Pageable pageable);

    boolean existsByIdAndNegocioId(UUID id, UUID negocioId);
}
