package com.bvrit.vtp.dao;

import org.springframework.data.jpa.repository.JpaRepository;
import com.bvrit.vtp.model.Admin;
import java.util.Optional;

public interface AdminRepo extends JpaRepository<Admin, Long> {
    Optional<Admin> findByEmail(String email);
}

