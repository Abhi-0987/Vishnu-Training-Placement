package com.bvrit.vtp.dao;

import com.bvrit.vtp.model.StudentAttendance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface StudentAttendanceRepo extends JpaRepository<StudentAttendance, Long> {
    //Optional<StudentAttendance> findByEmailAndDateAndTime(String email, LocalDate date, LocalTime fromTime, LocalTime toTime);
    Optional<StudentAttendance> findBySchedule_IdAndEmail(Long scheduleId, String email);
    List<StudentAttendance> findBySchedule_Id(Long scheduleId);
    List<StudentAttendance> findBySchedule_IdAndPresentTrue(Long scheduleId);
    List<StudentAttendance> findBySchedule_IdAndPresentFalse(Long scheduleId);
    int countByEmail(String email);
    int countByEmailAndPresentTrue(String email);


    void deleteBySchedule_Id(Long scheduleId);

    // Fix the method signature to properly handle fromTime and toTime
    Optional<StudentAttendance> findByEmailAndDateAndFromTime(String email, LocalDate date, LocalTime fromTime);
    
    // Add a new method if you need to query by both fromTime and toTime
    //Optional<StudentAttendance> findByEmailAndDateAndFromTimeAndToTime(String email, LocalDate date, LocalTime fromTime, LocalTime toTime);
}
