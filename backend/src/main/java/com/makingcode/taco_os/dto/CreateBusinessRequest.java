package com.makingcode.taco_os.dto;

import lombok.Data;

@Data
public class CreateBusinessRequest {
    private String name;
    private String plan = "free";
    private Double baseCash = 500.0;
    private String currency = "MXN";
}
