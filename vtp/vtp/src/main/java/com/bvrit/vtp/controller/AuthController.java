package com.bvrit.vtp.controller;

import com.bvrit.vtp.dao.AdminRepo;
import com.bvrit.vtp.dao.StudentRepo;
import com.bvrit.vtp.dto.ChangePasswordRequest;
import com.bvrit.vtp.dto.TokenResponse;
import com.bvrit.vtp.model.Admin;
import com.bvrit.vtp.model.Student;
import com.bvrit.vtp.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired private AuthService authService;
    @Autowired private StudentRepo studentRepository;
    @Autowired private AdminRepo adminRepository;
    @Autowired private PasswordEncoder passwordEncoder;

    @PostMapping(value = "/admin/login", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> adminlogin(@RequestBody Map<String, String> credentials) {
        String email = credentials.get("email");
        String password = credentials.get("password");

        Optional<Admin> optionalAdmin = adminRepository.findByEmail(email);
        if (optionalAdmin.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid email or password"));
        }

        TokenResponse tokenResponse;
        try {
            tokenResponse = authService.adminlogin(email, password);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid credentials"));
        }

        Admin admin = optionalAdmin.get();
        boolean loginFlag = admin.isLogin();

        return ResponseEntity.ok(Map.of(
                "accessToken", tokenResponse.getAccessToken(),
                "refreshToken", tokenResponse.getRefreshToken(),
                "role", "Admin",
                "login", loginFlag
        ));
    }

    @PostMapping(value = "/student/login", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> studentlogin(@RequestBody Map<String, String> credentials) {
        String email = credentials.get("email");
        String password = credentials.get("password");

        Optional<Student> optionalStudent = studentRepository.findByEmail(email);
        if (optionalStudent.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid email or password"));
        }

        TokenResponse tokenResponse;
        try {
            tokenResponse = authService.studentlogin(email, password);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid credentials"));
        }

        Student student = optionalStudent.get();
        boolean loginFlag = student.isLogin();

        return ResponseEntity.ok(Map.of(
                "accessToken", tokenResponse.getAccessToken(),
                "refreshToken", tokenResponse.getRefreshToken(),
                "role", "Student",
                "login", loginFlag
        ));
    }

    @PostMapping("/student/change-password")
    public ResponseEntity<?> changePassword(@RequestBody ChangePasswordRequest request) {
        Optional<Student> optionalStudent = studentRepository.findByEmail(request.getEmail());
        if (optionalStudent.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "Student not found"));
        }

        Student student = optionalStudent.get();
        student.setPassword(passwordEncoder.encode(request.getNewPassword()));
        student.setLogin(true);
        studentRepository.save(student);

        return ResponseEntity.ok(Map.of("message", "Password updated successfully"));
    }

    @PostMapping("/admin/change-password")
    public ResponseEntity<?> changeAdminPassword(@RequestBody ChangePasswordRequest request) {
        Optional<Admin> optionalAdmin = adminRepository.findByEmail(request.getEmail());
        if (optionalAdmin.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "Admin not found"));
        }

        Admin admin = optionalAdmin.get();
        admin.setPassword(passwordEncoder.encode(request.getNewPassword()));
        admin.setLogin(true);
        adminRepository.save(admin);

        return ResponseEntity.ok(Map.of("message", "Admin password updated successfully"));
    }

    @PostMapping(value = "/refresh", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<TokenResponse> refresh(@RequestBody Map<String, String> tokenMap) {
        return ResponseEntity.ok(authService.refresh(tokenMap.get("refreshToken")));
    }
}
