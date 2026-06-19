package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.domain.corte.DailyCut;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface DailyCutRepository extends JpaRepository<DailyCut, UUID> {

    List<DailyCut> findByNegocioIdAndCierreBetween(UUID negocioId, LocalDateTime inicio, LocalDateTime fin);

    List<DailyCut> findByNegocioIdOrderByCierreDesc(UUID negocioId);
}
