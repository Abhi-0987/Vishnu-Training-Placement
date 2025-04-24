package com.bvrit.vtp.dao;

import com.bvrit.vtp.model.StudentDetails;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface StudentBranchRepo extends JpaRepository<StudentDetails, Long> {
    Optional<StudentDetails> findByEmail(String email);
}
