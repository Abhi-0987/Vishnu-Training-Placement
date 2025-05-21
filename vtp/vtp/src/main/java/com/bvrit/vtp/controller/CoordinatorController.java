package com.bvrit.vtp.controller;

import com.bvrit.vtp.dao.CoordinatorRepo;
import com.bvrit.vtp.model.Coordinator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/coordinator")
public class CoordinatorController {

    @Autowired
    private CoordinatorRepo coordinatorRepo;

    @PostMapping(value = "/details", produces = "application/json")
    public ResponseEntity<?> getCoordinatorDetailsByEmail(@RequestBody Map<String, String> payload) {
        String email = payload.get("email");

        if (email == null || email.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email is required"));
        }

        Optional<Coordinator> coordinatorOptional = coordinatorRepo.findByEmail(email);

        return coordinatorOptional.<ResponseEntity<?>>map(
                coordinator -> ResponseEntity.ok(Map.of(
                        "name", coordinator.getName(),
                        "email", coordinator.getEmail()
                ))).orElseGet(() ->
                ResponseEntity.status(404).body(Map.of("error", "Coordinator not found")));
    }
}
