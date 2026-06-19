package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.common.enums.Categoria;
import com.jmcsoft.taco_os.domain.producto.Producto;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ProductoRepository extends JpaRepository<Producto, UUID> {

    Boolean existsByNombreAndNegocioIdAndActivoTrue(String nombre, UUID negocioId);

    List<Producto> findByNegocioIdAndActivoTrue(UUID negocioId);

    List<Producto> findByNegocioIdAndCategoriaAndActivoTrue(UUID negocioId, Categoria categoria);
}
