package com.bvrit.vtp.dao;

import org.springframework.data.jpa.repository.JpaRepository;
import com.bvrit.vtp.model.Coordinator;
import java.util.Optional;

public interface CoordinatorRepo extends JpaRepository<Coordinator, Long> {
    Optional<Coordinator> findByEmail(String email);
}

