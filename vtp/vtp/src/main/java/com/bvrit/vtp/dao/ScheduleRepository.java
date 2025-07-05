package com.bvrit.vtp.dao;

import com.bvrit.vtp.model.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {
    List<Schedule> findByLocation(String location);
    List<Schedule> findByDate(LocalDate date);
    List<Schedule> findByLocationAndDate(String location, LocalDate date);
    
    // Update to use fromTime and toTime
    List<Schedule> findByLocationAndDateAndFromTime(String location, LocalDate date, LocalTime fromTime);
    
    // Add new method to check for time slot conflicts
    List<Schedule> findByLocationAndDateAndFromTimeLessThanEqualAndToTimeGreaterThanEqual(
        String location, LocalDate date, LocalTime fromTime, LocalTime toTime);
    
    // Updated to use studentBranch instead of branches
    List<Schedule> findByStudentBranchContaining(String branch);
}