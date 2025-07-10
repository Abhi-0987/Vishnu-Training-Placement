package com.bvrit.vtp.dao;

import com.bvrit.vtp.model.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;
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
    
    // Update to use fromTime and toTime
    List<Schedule> findByLocationAndDateAndFromTime(String location, LocalDate date, LocalTime fromTime);
    
    // Add new method to check for time slot conflicts
    List<Schedule> findByLocationAndDateAndFromTimeLessThanEqualAndToTimeGreaterThanEqual(
        String location, LocalDate date, LocalTime fromTime, LocalTime toTime);
    
    // Updated to use studentBranch instead of branches
    List<Schedule> findByStudentBranchContaining(String branch);

    @Query("SELECT s FROM Schedule s WHERE s.location = :location AND s.date = :date AND :fromTime < s.toTime AND :toTime > s.fromTime AND s.id <> :excludeId")
    List<Schedule> findOverlappingSchedules(@Param("location") String location,
                                            @Param("date") LocalDate date,
                                            @Param("fromTime") LocalTime fromTime,
                                            @Param("toTime") LocalTime toTime,
                                            @Param("excludeId") Long excludeId);
}