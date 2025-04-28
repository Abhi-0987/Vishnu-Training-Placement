package com.bvrit.vtp.dao;

import com.bvrit.vtp.model.Venues;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface VenuesRepository extends JpaRepository<Venues, Long> {
    Optional<Venues> findByBlockNameAndRoomNumber(String blockName, String roomNumber);
}