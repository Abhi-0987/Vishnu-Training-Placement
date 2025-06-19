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
    Optional<StudentAttendance> findByEmailAndDateAndTime(String email, LocalDate date, LocalTime time);
    Optional<StudentAttendance> findBySchedule_IdAndEmail(Long scheduleId, String email);
    List<StudentAttendance> findBySchedule_Id(Long scheduleId);
    List<StudentAttendance> findBySchedule_IdAndPresentTrue(Long scheduleId);
    List<StudentAttendance> findBySchedule_IdAndPresentFalse(Long scheduleId);

    // Add this method to delete records by schedule ID
    void deleteBySchedule_Id(Long scheduleId);
}
