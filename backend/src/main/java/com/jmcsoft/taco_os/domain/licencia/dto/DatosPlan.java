package com.jmcsoft.taco_os.domain.licencia.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

@Schema(description = "Subscription plan detail")
public record DatosPlan(
        @Schema(description = "Plan name", example = "Basic")
        String name,
        @Schema(description = "Plan price", example = "2999")
        Integer price,
        @Schema(description = "Currency code", example = "MXN")
        String currency,
        @Schema(description = "Billing interval", example = "monthly")
        String interval,
        @Schema(description = "Maximum number of businesses allowed", example = "1")
        Integer max_businesses,
        @Schema(description = "Maximum number of cashiers allowed", example = "3")
        Integer max_cashiers,
        @Schema(description = "List of features included in the plan")
        List<String> features,
        @Schema(description = "Whether the plan has a trial period", example = "true")
        Boolean has_trial,
        @Schema(description = "Number of trial days", example = "14")
        Integer trial_days
) {}
