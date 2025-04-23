package com.bvrit.vtp.dao;

import com.bvrit.vtp.model.StudentDetails;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StudentDetailsRepo extends JpaRepository<StudentDetails, Long> {
    List<StudentDetails> findByBranch(String branch);
    @Query("SELECT s.email FROM StudentDetails s")
    List<String> findAllEmails();

}
