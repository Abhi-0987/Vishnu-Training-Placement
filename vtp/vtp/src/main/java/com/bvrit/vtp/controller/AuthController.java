package com.bvrit.vtp.controller;

import com.bvrit.vtp.dto.TokenResponse;
import com.bvrit.vtp.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;


@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired private AuthService authService;

    @PostMapping(value = "/admin/login", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<TokenResponse> adminlogin(@RequestBody Map<String, String> credentials) {
        return ResponseEntity.ok(authService.adminlogin(credentials.get("email"), credentials.get("password")));
    }

    @PostMapping(value = "/student/login", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<TokenResponse> studentlogin(@RequestBody Map<String, String> credentials) {
        return ResponseEntity.ok(authService.studentlogin(credentials.get("email"), credentials.get("password")));
    }

    @PostMapping(value = "/refresh", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<TokenResponse> refresh(@RequestBody Map<String, String> tokenMap) {
        return ResponseEntity.ok(authService.refresh(tokenMap.get("refreshToken")));
    }
}
