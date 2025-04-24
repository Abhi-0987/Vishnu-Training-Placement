package com.bvrit.vtp.controller;

import com.bvrit.vtp.model.StudentDetails;
import com.bvrit.vtp.dao.StudentBranchRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/student")
public class StudentBranchController {

    @Autowired
    private StudentBranchRepo studentBranchRepository;

    @PostMapping(value="/branch", produces = "application/json")
    public ResponseEntity<?> getBranchByEmail(@RequestBody Map<String, String> payload) {
        String email = payload.get("email");
        if (email == null || email.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email is required"));
        }

        Optional<StudentDetails> studentOptional = studentBranchRepository.findByEmail(email);
        return studentOptional.<ResponseEntity<?>>map(
                studentDetails -> ResponseEntity.ok(Map.of(
                        "branch", studentDetails.getBranch()))).orElseGet(() ->
                            ResponseEntity.status(404).body(Map.of(
                                "error", "Student not found")));
    }
}
