package com.makingcode.taco_os.dto;

import lombok.Data;
import java.util.UUID;

@Data
public class LoginResponse {
    private String jwt;
    private UserInfo user;

    @Data
    public static class UserInfo {
        private UUID id;
        private String name;
        private String email;
        private String role;
        private Boolean hasBusiness;
    }
}
