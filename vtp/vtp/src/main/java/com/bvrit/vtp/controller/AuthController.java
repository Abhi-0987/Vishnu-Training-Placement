package com.bvrit.vtp.controller;

import com.bvrit.vtp.dao.AdminRepo;
import com.bvrit.vtp.model.Admin;
import com.bvrit.vtp.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import com.bvrit.vtp.model.Student;
import com.bvrit.vtp.dao.StudentRepo;

import java.util.HashMap;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private StudentRepo studentRepository;
    @Autowired
    private AdminRepo adminRepository;

    @Autowired
    private AuthService authService; // Admin Authentication Service
    @PostMapping("/student/login")
    public Map<String, String> studentlogin(@RequestBody Map<String, String> credentials) {
        String email = credentials.get("email");
        String password = credentials.get("password");
        Optional<Student> student = studentRepository.findByEmail(email);
//        System.out.println("Received Email: " + email);
//        System.out.println("Received Password: " + password);
        String role = authService.authenticate(email, password);
        if ("Student".equals(role)) {
            return Map.of("status", "success", "message", "Login successful");
        } else {
            return Map.of("status", "fail", "message", "Invalid credentials");
        }
    }

    // ✅ Admin Login
    @PostMapping("/admin/login")
    public Map<String, String> adminLogin(@RequestBody Map<String, String> credentials) {
        String email = credentials.get("email");
        String password = credentials.get("password");

        Optional<Admin> admin = adminRepository.findByEmail(email);
        Map<String, String> response = new HashMap<>();
        String role = authService.authenticate(email, password); // ✅ Call auth service

        if ("Admin".equals(role)) {
            return Map.of("status", "success", "message", "Login successful");
        } else {
            return Map.of("status", "fail", "message", "Invalid credentials");
        }
    }

    @PostMapping("/change-password")
    public Map<String, String> changePassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String newPassword = request.get("newPassword");

        Map<String, String> response = new HashMap<>();

        if (email == null || newPassword == null || newPassword.isEmpty()) {
            response.put("status", "fail");
            response.put("message", "Invalid request");
            return response;
        }

        // Update password using AuthService
        authService.updatePassword(email, newPassword);

        response.put("status", "success");
        response.put("message", "Password updated successfully");
        return response;
    }

}
