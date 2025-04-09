package com.bvrit.vtp.service;

import com.bvrit.vtp.dao.BlacklistedTokenRepo;
import com.bvrit.vtp.dao.StudentRepo;
import com.bvrit.vtp.dao.AdminRepo;
import com.bvrit.vtp.dto.TokenResponse;
import com.bvrit.vtp.model.Admin;
import com.bvrit.vtp.model.BlacklistedToken;
import com.bvrit.vtp.model.Student;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.Optional;

@Service
public class AuthService {

    @Autowired private StudentRepo studentRepo;
    @Autowired private AdminRepo adminRepo;
    @Autowired private JwtService jwtService;
    @Autowired private BlacklistedTokenRepo blacklistedTokenRepo;

    public TokenResponse adminlogin(String email, String password) {
        Optional<Admin> adminOpt = adminRepo.findByEmail(email);
        if (adminOpt.isPresent() && adminOpt.get().getPassword().equals(password)) {
            String access = jwtService.generateToken(email, "Admin", false);
            String refresh = jwtService.generateToken(email, "Admin", true);
            return new TokenResponse(access, refresh, "Admin");
        }

        throw new RuntimeException("Invalid credentials");
    }

    public TokenResponse studentlogin(String email, String password) {
        Optional<Student> studentOpt = studentRepo.findByEmail(email);
        if (studentOpt.isPresent() && studentOpt.get().getPassword().equals(password)) {
            String access = jwtService.generateToken(email, "Student", false);
            String refresh = jwtService.generateToken(email, "Student", true);
            return new TokenResponse(access, refresh, "Student");
        }

        throw new RuntimeException("Invalid credentials");
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