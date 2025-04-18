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

//@RestController
//@RequestMapping("/api/auth")
//@CrossOrigin(origins = "*")
//public class AuthController {
//
//    @Autowired
//    private StudentRepo studentRepository;
//    @Autowired
//    private AdminRepo adminRepository;
//
//    @Autowired
//    private AuthService authService; // Admin Authentication Service
//    @PostMapping("/student/login")
//    public ResponseEntity<Map<String, String>> studentLogin(@RequestBody Map<String, String> credentials) {
//        String email = credentials.get("email");
//        String password = credentials.get("password");
//
//        String role = authService.authenticate(email, password); //  Call auth service
//
//        Map<String, String> response = new HashMap<>();
//        if ("Student".equals(role)) {
//            response.put("status", "success");
//            response.put("message", "Login successful");
//        } else {
//            response.put("status", "fail");
//            response.put("message", "Invalid credentials");
//        }
//
//        return ResponseEntity.ok()
//                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE) //  Force JSON response
//                .body(response);
//    }
//
//    // ✅ Admin Login
//    @PostMapping("/admin/login")
//    public ResponseEntity<Map<String, String>> adminLogin(@RequestBody Map<String, String> credentials) {
//        String email = credentials.get("email");
//        String password = credentials.get("password");
//
//        String role = authService.authenticate(email, password); //  Call auth service
//
//        Map<String, String> response = new HashMap<>();
//        if ("Admin".equals(role)) {
//            response.put("status", "success");
//            response.put("message", "Login successful");
//        } else {
//            response.put("status", "fail");
//            response.put("message", "Invalid credentials");
//        }
//
//        return ResponseEntity.ok()
//                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE) // ✅ Force JSON
//                .body(response);
//    }
//
//
//    @PostMapping("/change-password")
//    public Map<String, String> changePassword(@RequestBody Map<String, String> request) {
//        String email = request.get("email");
//        String newPassword = request.get("newPassword");
//
//        Map<String, String> response = new HashMap<>();
//
//        if (email == null || newPassword == null || newPassword.isEmpty()) {
//            response.put("status", "fail");
//            response.put("message", "Invalid request");
//            return response;
//        }
//
//        // Update password using AuthService
//        authService.updatePassword(email, newPassword);
//
//        response.put("status", "success");
//        response.put("message", "Password updated successfully");
//        return response;
//    }
//}
