package com.makingcode.taco_os.service;

import com.makingcode.taco_os.domain.Business;
import com.makingcode.taco_os.domain.User;
import com.makingcode.taco_os.dto.BusinessResponse;
import com.makingcode.taco_os.dto.CreateBusinessRequest;
import com.makingcode.taco_os.dto.ErrorResponse;
import com.makingcode.taco_os.repository.BusinessRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class BusinessService {

    private final BusinessRepository businessRepository;
    private final LicenseService licenseService;

    public Object createBusiness(UUID ownerId, CreateBusinessRequest request) {
        long currentBusinesses = businessRepository.countByOwnerId(ownerId);
        if (currentBusinesses >= 1) {
            return new ErrorResponse(
                    "license_limit_reached",
                    "Alcanzaste el límite de negocios para tu plan actual (máx. 1).",
                    currentBusinesses, 1L,
                    "premium", "/api/v1/plans/premium"
            );
        }

        Business business = new Business();
        business.setName(request.getName());
        business.setPlan(request.getPlan());
        business.setBaseCash(request.getBaseCash());
        business.setCurrency(request.getCurrency());
        business.setOwnerId(ownerId);
        business = businessRepository.save(business);

        licenseService.createFreeLicense(business.getId());

        return toResponse(business);
    }

    public BusinessResponse getBusiness(UUID id) {
        Business business = businessRepository.findById(id).orElseThrow();
        return toResponse(business);
    }

    private BusinessResponse toResponse(Business business) {
        BusinessResponse resp = new BusinessResponse();
        resp.setId(business.getId());
        resp.setName(business.getName());
        resp.setPlan(business.getPlan());
        resp.setBaseCash(business.getBaseCash());
        resp.setCurrency(business.getCurrency());
        resp.setCreatedAt(business.getCreatedAt());
        resp.setMaxCashiers(2);
        resp.setMaxBusinesses(1);
        resp.setCashiersCount(0L);
        return resp;
    }
}
