package com.bvrit.vtp.dao;

import com.bvrit.vtp.model.StudentAttendance;
import com.bvrit.vtp.projections.AbsentStudentPhoneProjection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
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

    @Query("SELECT DISTINCT s.date FROM StudentAttendance s WHERE s.date <= CURRENT_DATE ORDER BY s.date ASC")
    List<LocalDate> findDistinctDates();

    @Query(value = """
    SELECT DISTINCT ON (sd.parents_phone) 
        sd.name AS name, 
        sd.email AS email, 
        sd.parents_phone AS parentsPhone
    FROM student_attendance sa 
    JOIN student_details sd ON sa.student_email = sd.email 
    WHERE sa.schedule_id = :scheduleId 
      AND sa.present = false
""", nativeQuery = true)
    List<AbsentStudentPhoneProjection> findAbsentStudentsByScheduleId(@Param("scheduleId") Long scheduleId);


    //List<StudentAttendance> findByDateAndPresentFalse(LocalDate date);

    @Query(value = """
    SELECT DISTINCT ON (sd.parents_phone) 
        sd.name AS name, 
        sd.email AS email, 
        sd.parents_phone AS parentsPhone
    FROM student_attendance sa 
    JOIN student_details sd ON sa.student_email = sd.email 
    WHERE sa.date = :date 
      AND sa.present = false
""", nativeQuery = true)
    List<AbsentStudentPhoneProjection> findAbsentStudentsWithPhoneByDate(@Param("date") LocalDate date);



    // Add this method to delete records by schedule ID
    void deleteBySchedule_Id(Long scheduleId);
}
