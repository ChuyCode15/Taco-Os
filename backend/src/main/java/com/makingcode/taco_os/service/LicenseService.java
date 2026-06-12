package com.makingcode.taco_os.service;

import com.makingcode.taco_os.domain.License;
import com.makingcode.taco_os.domain.User;
import com.makingcode.taco_os.dto.ErrorResponse;
import com.makingcode.taco_os.dto.LicenseResponse;
import com.makingcode.taco_os.repository.BusinessRepository;
import com.makingcode.taco_os.repository.LicenseRepository;
import com.makingcode.taco_os.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class LicenseService {

    private final LicenseRepository licenseRepository;
    private final BusinessRepository businessRepository;
    private final UserRepository userRepository;

    public License createFreeLicense(UUID businessId) {
        License license = new License();
        license.setBusinessId(businessId);
        license.setPlan("free");
        license.setStatus(License.LicenseStatus.active);
        license.setStartDate(LocalDate.now());
        license.setMaxCashiers(2);
        license.setMaxBusinesses(1);
        return licenseRepository.save(license);
    }

    public ErrorResponse validateCashierLimit(UUID businessId) {
        License license = licenseRepository.findByBusinessId(businessId)
                .orElse(null);
        if (license == null) return null;

        long currentCashiers = userRepository.countByBusinessIdAndRole(businessId, User.Role.cashier);
        if (currentCashiers >= license.getMaxCashiers()) {
            return new ErrorResponse(
                    "license_limit_reached",
                    "Alcanzaste el límite de cajeros para tu plan actual (máx. " + license.getMaxCashiers() + ").",
                    currentCashiers, (long) license.getMaxCashiers(),
                    "premium", "/api/v1/plans/premium"
            );
        }
        return null;
    }

    public ErrorResponse validateBusinessLimit(UUID ownerId) {
        License license = licenseRepository.findByBusinessId(
                businessRepository.findById(ownerId).orElseThrow().getId()
        ).orElse(null);
        if (license == null) return null;

        long currentBusinesses = businessRepository.countByOwnerId(ownerId);
        if (currentBusinesses >= license.getMaxBusinesses()) {
            return new ErrorResponse(
                    "license_limit_reached",
                    "Alcanzaste el límite de negocios para tu plan actual (máx. " + license.getMaxBusinesses() + ").",
                    currentBusinesses, (long) license.getMaxBusinesses(),
                    "premium", "/api/v1/plans/premium"
            );
        }
        return null;
    }

    public LicenseResponse getLicenseResponse(UUID businessId) {
        License license = licenseRepository.findByBusinessId(businessId).orElse(null);
        if (license == null) return null;

        LicenseResponse resp = new LicenseResponse();
        resp.setPlan(license.getPlan());
        resp.setStatus(license.getStatus().name());
        resp.setStartDate(license.getStartDate());
        resp.setEndDate(license.getEndDate());
        resp.setMaxCashiers(license.getMaxCashiers());
        resp.setMaxBusinesses(license.getMaxBusinesses());
        resp.setFeatures(license.getFeatures());

        long currentCashiers = userRepository.countByBusinessIdAndRole(businessId, User.Role.cashier);
        resp.setCurrentCashiers(currentCashiers);

        long currentBusinesses = businessRepository.count();
        resp.setCurrentBusinesses(currentBusinesses);

        if (license.getEndDate() != null) {
            resp.setDaysRemaining(ChronoUnit.DAYS.between(LocalDate.now(), license.getEndDate()));
        }

        return resp;
    }
}
