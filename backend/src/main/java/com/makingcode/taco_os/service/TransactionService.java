package com.makingcode.taco_os.service;

import com.makingcode.taco_os.domain.Cancellation;
import com.makingcode.taco_os.domain.Transaction;
import com.makingcode.taco_os.dto.SyncRequest;
import com.makingcode.taco_os.dto.SyncResponse;
import com.makingcode.taco_os.dto.TransactionRequest;
import com.makingcode.taco_os.repository.CancellationRepository;
import com.makingcode.taco_os.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.*;

@Service
@RequiredArgsConstructor
public class TransactionService {

    private final TransactionRepository transactionRepository;
    private final CancellationRepository cancellationRepository;

    public Transaction createTransaction(TransactionRequest request) {
        Transaction tx = new Transaction();
        tx.setBusinessId(request.getBusinessId());
        tx.setType(Transaction.TransactionType.valueOf(request.getType()));
        tx.setCashierId(request.getCashierId());
        tx.setDeviceId(request.getDeviceId());
        tx.setCustomerPhone(request.getCustomerPhone());
        tx.setItemsJson(request.getItemsJson());
        tx.setPaymentJson(request.getPaymentJson());
        tx.setTotal(request.getTotal());
        tx.setTicketFolio(request.getTicketFolio());
        tx.setStatus(Transaction.TransactionStatus.completed);
        tx.setTimestamp(request.getTimestamp() != null ? request.getTimestamp() : Instant.now());
        tx.setIsSynced(request.getIsSynced());
        tx.setCategory(request.getCategory());
        tx.setCreditor(request.getCreditor());
        if (request.getDueDate() != null) {
            tx.setDueDate(LocalDate.parse(request.getDueDate()));
        }
        return transactionRepository.save(tx);
    }

    public Map<String, Object> cancelTransaction(UUID txId, UUID cashierId, String reason, String photoUrl) {
        Transaction tx = transactionRepository.findById(txId).orElseThrow();

        long minutesSince = ChronoUnit.MINUTES.between(tx.getTimestamp(), Instant.now());
        if (minutesSince > 3) {
            throw new RuntimeException("La venta solo puede cancelarse dentro de los primeros 3 minutos.");
        }

        tx.setStatus(Transaction.TransactionStatus.cancelled);
        transactionRepository.save(tx);

        Cancellation cancel = new Cancellation();
        cancel.setTransactionId(txId);
        cancel.setBusinessId(tx.getBusinessId());
        cancel.setCashierId(cashierId);
        cancel.setReason(reason);
        cancel.setPhotoUrl(photoUrl);
        cancel.setOwnerNotified(true);
        cancellationRepository.save(cancel);

        Map<String, Object> resp = new LinkedHashMap<>();
        resp.put("status", "cancelled");
        resp.put("originalTotal", tx.getTotal());
        resp.put("cancelledAt", Instant.now());
        resp.put("ownerNotified", true);
        return resp;
    }

    public SyncResponse syncBatch(SyncRequest request) {
        int synced = 0;
        int failed = 0;
        List<String> conflicts = new ArrayList<>();

        if (request.getTransactions() != null) {
            for (TransactionRequest txReq : request.getTransactions()) {
                try {
                    txReq.setBusinessId(request.getBusinessId());
                    txReq.setIsSynced(true);
                    createTransaction(txReq);
                    synced++;
                } catch (Exception e) {
                    failed++;
                }
            }
        }

        SyncResponse response = new SyncResponse();
        response.setSynced(synced);
        response.setFailed(failed);
        response.setConflicts(conflicts);
        response.setServerTime(Instant.now());
        return response;
    }
}
