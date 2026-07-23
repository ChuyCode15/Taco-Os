package com.jmcsoft.taco_os.repository;

import com.jmcsoft.taco_os.domain.master.invoice.MasterInvoice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public interface MasterInvoiceRepository extends JpaRepository<MasterInvoice, UUID> {
    List<MasterInvoice> findByClienteId(UUID clienteId);

    @Query("SELECT COALESCE(SUM(i.monto), 0) FROM MasterInvoice i WHERE i.estado = 'PAGADA'")
    BigDecimal sumPagadas();

    @Query("SELECT COALESCE(SUM(i.monto), 0) FROM MasterInvoice i WHERE i.estado = 'PENDIENTE'")
    BigDecimal sumPendientes();
}
