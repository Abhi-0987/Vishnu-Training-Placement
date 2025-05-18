package com.bvrit.vtp.service;

import com.bvrit.vtp.dao.AdminRepo;
import com.bvrit.vtp.dao.BlacklistedTokenRepo;
import com.bvrit.vtp.dao.StudentRepo;
import com.bvrit.vtp.dto.TokenResponse;
import com.bvrit.vtp.model.Admin;
import com.bvrit.vtp.model.BlacklistedToken;
import com.bvrit.vtp.model.Student;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.security.crypto.password.PasswordEncoder;
import java.util.Date;
import java.util.Optional;

@Service
public class AuthService {

    @Autowired private StudentRepo studentRepo;
    @Autowired private AdminRepo adminRepo;
    @Autowired private JwtService jwtService;
    @Autowired private BlacklistedTokenRepo blacklistedTokenRepo;
    @Autowired private PasswordEncoder passwordEncoder;
    public TokenResponse adminlogin(String email, String rawPassword) {
        Optional<Admin> adminOpt = adminRepo.findByEmail(email);
        if (adminOpt.isPresent()) {
            Admin admin = adminOpt.get();

            if (!admin.isLogin()) {
                // Default password check
                if (rawPassword.equals(admin.getPassword())) {
                    return generateTokenResponse(email, "Admin");
                }
            } else {
                // Encoded password check
                if (passwordEncoder.matches(rawPassword, admin.getPassword())) {
                    return generateTokenResponse(email, "Admin");
                }
            }
        }

        throw new RuntimeException("Invalid credentials");
    }

    public TokenResponse studentlogin(String email, String rawPassword) {
        Optional<Student> studentOpt = studentRepo.findByEmail(email);
        if (studentOpt.isPresent()) {
            Student student = studentOpt.get();

            if (!student.isLogin()) {
                // Default password check
                if (rawPassword.equals(student.getPassword())) {
                    return generateTokenResponse(email, "Student");
                }
            } else {
                // Encoded password check
                if (passwordEncoder.matches(rawPassword, student.getPassword())) {
                    return generateTokenResponse(email, "Student");
                }
            }
        }

        throw new RuntimeException("Invalid credentials");
    }

    private TokenResponse generateTokenResponse(String email, String role) {
        String access = jwtService.generateToken(email, role, false);
        String refresh = jwtService.generateToken(email, role, true);
        return new TokenResponse(access, refresh, role);
    }

    public TokenResponse refresh(String refreshToken) {
        // Check if token is already blacklisted
        if (blacklistedTokenRepo.findByToken(refreshToken).isPresent()) {
            throw new RuntimeException("Refresh token already used");
        }
        if (jwtService.validateToken(refreshToken)) {
            String email = jwtService.getEmail(refreshToken);
            String role = jwtService.getRole(refreshToken);
            // Blacklist the used refresh token
            BlacklistedToken blacklisted = new BlacklistedToken();
            blacklisted.setToken(refreshToken);
            blacklisted.setBlacklistedAt(new Date());
            blacklistedTokenRepo.save(blacklisted);
            String newAccess = jwtService.generateToken(email, role, false);
            String newRefresh = jwtService.generateToken(email, role, true);
            return new TokenResponse(newAccess, newRefresh, role);
        }
        throw new RuntimeException("Invalid refresh token");
    }
}