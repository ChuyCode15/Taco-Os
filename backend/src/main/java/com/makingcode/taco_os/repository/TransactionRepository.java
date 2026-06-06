package com.makingcode.taco_os.repository;

import com.makingcode.taco_os.domain.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface TransactionRepository extends JpaRepository<Transaction, UUID> {
    List<Transaction> findByBusinessIdAndTimestampBetweenAndStatus(
            UUID businessId, Instant start, Instant end, Transaction.TransactionStatus status);

    List<Transaction> findByBusinessIdAndIsSyncedFalse(UUID businessId);

    long countByBusinessIdAndTimestampBetweenAndStatus(
            UUID businessId, Instant start, Instant end, Transaction.TransactionStatus status);

    @Query("SELECT COALESCE(SUM(t.total), 0) FROM Transaction t WHERE t.businessId = :businessId " +
           "AND t.type = :type AND t.timestamp BETWEEN :start AND :end AND t.status = 'completed'")
    Double sumByBusinessIdAndTypeAndTimestampBetween(
            @Param("businessId") UUID businessId,
            @Param("type") Transaction.TransactionType type,
            @Param("start") Instant start,
            @Param("end") Instant end);

    @Query("SELECT t.itemsJson FROM Transaction t WHERE t.businessId = :businessId " +
           "AND t.type = 'sale' AND t.timestamp BETWEEN :start AND :end AND t.status = 'completed'")
    List<String> findItemsJsonByBusinessIdAndTimestampBetween(
            @Param("businessId") UUID businessId,
            @Param("start") Instant start,
            @Param("end") Instant end);
}
