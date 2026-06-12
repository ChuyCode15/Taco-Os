package com.makingcode.taco_os.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ErrorResponse {
    private String error;
    private String message;
    private Object current;
    private Object limit;
    private String upgradeRequired;
    private String upgradeUrl;
}
