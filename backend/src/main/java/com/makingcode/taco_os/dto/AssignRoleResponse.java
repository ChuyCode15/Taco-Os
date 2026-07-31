package com.makingcode.taco_os.dto;

import lombok.Data;
import java.util.UUID;

@Data
public class AssignRoleResponse {
    private String redirectTo;
    private UUID businessId;
    private String error;
}
