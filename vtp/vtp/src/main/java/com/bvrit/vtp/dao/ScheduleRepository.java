package com.bvrit.vtp.dao;

import com.bvrit.vtp.model.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.Query;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {
    List<Schedule> findByLocation(String location);
    List<Schedule> findByDate(LocalDate date);
    List<Schedule> findByLocationAndDate(String location, LocalDate date);
    List<Schedule> findByLocationAndDateAndTime(String location, LocalDate date, LocalTime time);
    // Updated to use studentBranch instead of branches
    List<Schedule> findByStudentBranchContaining(String branch);
}