package com.bvrit.vtp.controller;

import com.bvrit.vtp.dao.AdminRepo;
import com.bvrit.vtp.model.Admin;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private AdminRepo adminRepo;

    // API to get Admin details by email
    @PostMapping(value = "/details", produces = "application/json")
    public ResponseEntity<?> getAdminDetailsByEmail(@RequestBody Map<String, String> payload) {
        String email = payload.get("email");

        if (email == null || email.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email is required"));
        }

        Optional<Admin> adminOptional = adminRepo.findByEmail(email);

        if (adminOptional.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Admin not found"));
        }

        Admin admin = adminOptional.get();

        return ResponseEntity.ok(Map.of(
                "name", admin.getName(),
                "email", admin.getEmail()
        ));
    }
}
