package com.bvrit.vtp.repository;

import com.bvrit.vtp.model.Venues;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface VenuesRepository extends JpaRepository<Venues, Long> {
    // Basic CRUD operations are automatically provided by JpaRepository
}