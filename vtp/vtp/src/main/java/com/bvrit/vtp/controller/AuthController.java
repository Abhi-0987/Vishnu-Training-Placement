package com.bvrit.vtp.controller;

import com.bvrit.vtp.dao.AdminRepo;
import com.bvrit.vtp.dao.CoordinatorRepo;
import com.bvrit.vtp.dao.StudentRepo;
import com.bvrit.vtp.dto.ChangePasswordRequest;
import com.bvrit.vtp.dto.TokenResponse;
import com.bvrit.vtp.model.Admin;
import com.bvrit.vtp.model.Coordinator;
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
@RequestMapping("/api")
public class AuthController {

    @Autowired private AuthService authService;
    @Autowired private StudentRepo studentRepository;
    @Autowired private AdminRepo adminRepository;
    @Autowired private CoordinatorRepo coordinatorRepository;
    @Autowired private PasswordEncoder passwordEncoder;

    // Student login
    @PostMapping(value = "/auth/student/login", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> studentLogin(@RequestBody Map<String, String> credentials) {
        String email = credentials.get("email");
        String password = credentials.get("password");

        Optional<Student> optionalStudent = studentRepository.findByEmail(email);
        if (optionalStudent.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid email or password"));
        }

        TokenResponse tokenResponse;
        try {
            tokenResponse = authService.studentlogin(email, password);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid credentials"));
        }

        Student student = optionalStudent.get();
       // String studentDeviceId = student.getDeviceId();
      //         if(studentDeviceId!=null && !studentDeviceId.equals(deviceId)){
      //     return ResponseEntity.status(HttpStatus.FORBIDDEN)
      //              .body(Map.of("error", "You are trying to login to new device. Please contact admin"));
       // }

        // Check if a different student already has this deviceId
      // Optional<Student> deviceOwner = studentRepository.findByDeviceId(deviceId);
      //  if (deviceOwner.isPresent() && !deviceOwner.get().getEmail().equals(email)) {   
       //              return ResponseEntity.status(HttpStatus.FORBIDDEN)
      //              .body(Map.of("error", "This device is already linked to another account"));
       // }
        
        return ResponseEntity.ok(Map.of(
                "accessToken", tokenResponse.getAccessToken(),
                "refreshToken", tokenResponse.getRefreshToken(),
                "role", "Student",
                "login", student.isLogin()
        ));
    }

    // Admin login
    @PostMapping(value = "/auth/admin/login", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> adminLogin(@RequestBody Map<String, String> credentials) {
        String email = credentials.get("email");
        String password = credentials.get("password");

        Optional<Admin> optionalAdmin = adminRepository.findByEmail(email);
        if (optionalAdmin.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid email or password"));
        }

        TokenResponse tokenResponse;
        try {
            tokenResponse = authService.adminlogin(email, password);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid credentials"));
        }

        Admin admin = optionalAdmin.get();
        return ResponseEntity.ok(Map.of(
                "accessToken", tokenResponse.getAccessToken(),
                "refreshToken", tokenResponse.getRefreshToken(),
                "role", "Admin",
                "login", admin.isLogin()
        ));
    }

    // Coordinator login
    @PostMapping(value = "/auth/coordinator/login", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> coordinatorLogin(@RequestBody Map<String, String> credentials) {
        String email = credentials.get("email");
        String password = credentials.get("password");

        Optional<Coordinator> optionalCoordinator = coordinatorRepository.findByEmail(email);
        if (optionalCoordinator.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid email or password"));
        }

        TokenResponse tokenResponse;
        try {
            tokenResponse = authService.coordinatorlogin(email, password);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Invalid credentials"));
        }

        Coordinator coordinator = optionalCoordinator.get();
        return ResponseEntity.ok(Map.of(
                "accessToken", tokenResponse.getAccessToken(),
                "refreshToken", tokenResponse.getRefreshToken(),
                "role", "Coordinator",
                "login", coordinator.isLogin()
        ));
    }

    // Student change password
    @PostMapping("/student/change-password")
    public ResponseEntity<?> changeStudentPassword(@RequestBody ChangePasswordRequest request) {
        Optional<Student> optionalStudent = studentRepository.findByEmail(request.getEmail());
        if (optionalStudent.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "Student not found"));
        }

        Student student = optionalStudent.get();
        student.setPassword(passwordEncoder.encode(request.getNewPassword()));
        student.setLogin(true);
        studentRepository.save(student);

        return ResponseEntity.ok(Map.of("message", "Student password updated successfully"));
    }

    // Admin change password
    @PostMapping("/admin/change-password")
    public ResponseEntity<?> changeAdminPassword(@RequestBody ChangePasswordRequest request) {
        Optional<Admin> optionalAdmin = adminRepository.findByEmail(request.getEmail());
        if (optionalAdmin.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "Admin not found"));
        }

        Admin admin = optionalAdmin.get();
        admin.setPassword(passwordEncoder.encode(request.getNewPassword()));
        admin.setLogin(true);
        adminRepository.save(admin);

        return ResponseEntity.ok(Map.of("message", "Admin password updated successfully"));
    }

    // Coordinator change password
    @PostMapping("/coordinator/change-password")
    public ResponseEntity<?> changeCoordinatorPassword(@RequestBody ChangePasswordRequest request) {
        Optional<Coordinator> optionalCoordinator = coordinatorRepository.findByEmail(request.getEmail());
        if (optionalCoordinator.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "Coordinator not found"));
        }

        Coordinator coordinator = optionalCoordinator.get();
        coordinator.setPassword(passwordEncoder.encode(request.getNewPassword()));
        coordinator.setLogin(true);
        coordinatorRepository.save(coordinator);

        return ResponseEntity.ok(Map.of("message", "Coordinator password updated successfully"));
    }

    // ✅ Admin reset student password (Unified API)
    @PostMapping("/auth/admin/reset-student-password")
    public ResponseEntity<?> resetStudentPassword(@RequestBody Map<String, String> payload) {
        String email = payload.get("email");

        if (email == null || email.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email is required"));
        }

        Optional<Student> studentOptional = studentRepository.findByEmail(email);

        if (studentOptional.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Student not found"));
        }

        Student student = studentOptional.get();

        String defaultPassword = "bvrit";
        student.setPassword(defaultPassword);  // hashed default password
        student.setLogin(false);
        student.setDeviceId(null);

        studentRepository.save(student);

        return ResponseEntity.ok(Map.of("message", "Student password reset successfully"));
    }

    // Refresh token
    @PostMapping(value = "/auth/refresh", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<TokenResponse> refresh(@RequestBody Map<String, String> tokenMap) {
        return ResponseEntity.ok(authService.refresh(tokenMap.get("refreshToken")));
    }
}