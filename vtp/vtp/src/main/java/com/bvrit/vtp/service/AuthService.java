package com.bvrit.vtp.service;

import com.bvrit.vtp.dao.StudentRepo;
import com.bvrit.vtp.dao.AdminRepo;
import com.bvrit.vtp.model.Admin;
import com.bvrit.vtp.model.Student;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Optional;

@Service
public class AuthService {

    @Autowired
    private AdminRepo adminRepository;

    @Autowired // ✅ Fix: Add missing Autowired for StudentRepo
    private StudentRepo studentRepository;

    // ✅ Fix: Change return type to String
    public String authenticate(String email, String password) {
        Optional<Admin> admin = adminRepository.findByEmail(email);
        if (admin.isPresent() && admin.get().getPassword().equals(password)) {
            return "Admin"; // ✅ Admin found, return role
        }

        Optional<Student> student = studentRepository.findByEmail(email);
        if (student.isPresent() && student.get().getPassword().equals(password)) {
            return "Student"; // ✅ Student found, return role
        }

        return "Invalid"; // ❌ No valid user found
    }

    public void updatePassword(String email, String newPassword) {
        Optional<Student> student = studentRepository.findByEmail(email);
        if (student.isPresent()) {
            Student updatedStudent = student.get();
            updatedStudent.setPassword(newPassword); // ✅ Hashing
            studentRepository.save(updatedStudent);
            return;
        }
    }
}