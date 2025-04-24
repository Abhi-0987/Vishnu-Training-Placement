package com.bvrit.vtp.dao;

import com.bvrit.vtp.model.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface StudentRepo extends JpaRepository<Student, Long> {
    Optional<Student> findByEmail(String email);
    Optional<Student> findByDeviceId(String deviceId);
}

