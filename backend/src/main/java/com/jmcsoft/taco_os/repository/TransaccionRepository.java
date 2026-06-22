package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.common.enums.EstadoTransaccion;
import com.jmcsoft.taco_os.common.enums.TipoTransaccion;
import com.jmcsoft.taco_os.domain.transaccion.Transaccion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface TransaccionRepository extends JpaRepository<Transaccion, UUID> {

    List<Transaccion> findBySesionIdAndEstado(UUID sesionId, EstadoTransaccion estado);

    List<Transaccion> findByNegocioIdAndMarcaTiempoBetween(UUID negocioId, LocalDateTime inicio, LocalDateTime fin);

    @Query("SELECT COALESCE(SUM(t.total), 0) FROM Transaccion t WHERE t.sesion.id = :sesionId AND t.tipo = :tipo AND t.estado = :estado")
    BigDecimal sumBySesionAndTipoAndEstado(UUID sesionId, TipoTransaccion tipo, EstadoTransaccion estado);

    @Query("SELECT COALESCE(SUM(t.total), 0) FROM Transaccion t WHERE t.sesion.id = :sesionId AND t.metodoPago = :metodo AND t.tipo = 'VENTA' AND t.estado = :estado")
    BigDecimal sumBySesionAndMetodoAndEstado(UUID sesionId, com.jmcsoft.taco_os.common.enums.MetodoPago metodo, EstadoTransaccion estado);

    Boolean existsByIdAndNegocioId(UUID id, UUID negocioId);

    @Query("SELECT COUNT(t) FROM Transaccion t WHERE t.sesion.id = :sesionId AND t.estado = :estado")
    long countBySesionIdAndEstado(UUID sesionId, EstadoTransaccion estado);
}
