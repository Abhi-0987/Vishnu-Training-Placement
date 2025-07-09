package com.bvrit.vtp.service;

import com.bvrit.vtp.dao.ScheduleRepository;
import com.bvrit.vtp.dao.StudentAttendanceRepo;
import com.bvrit.vtp.dao.StudentDetailsRepo;
import com.bvrit.vtp.dto.ScheduleDTO;
import com.bvrit.vtp.exception.AttendanceAlreadyMarkedException;
import com.bvrit.vtp.exception.AttendanceRecordNotFoundException;
import com.bvrit.vtp.model.Schedule;
import com.bvrit.vtp.model.StudentAttendance;
import com.bvrit.vtp.model.StudentDetails;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional; // Import Transactional

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException; // Import for exception handling
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Optional;

@Service
public class ScheduleService {

    @Autowired
    private ScheduleRepository scheduleRepository;

    @Autowired
    private StudentDetailsRepo studentDetailsRepository;

    @Autowired
    private StudentAttendanceRepo studentAttendanceRepository;
    // Method to mark attendance as present
    // Update this method to use fromTime instead of time
    public boolean markAttendancePresent(String email, LocalDate date, LocalTime fromTime) {
        Optional<StudentAttendance> attendanceOpt = studentAttendanceRepository.findByEmailAndDateAndFromTime(email, date, fromTime);

        if (attendanceOpt.isEmpty()) {
            throw new AttendanceRecordNotFoundException("No attendance record found for " + email + " on " + date + " at " + fromTime);
        }

        StudentAttendance attendance = attendanceOpt.get();

        if (attendance.isPresent()) {
            throw new AttendanceAlreadyMarkedException("You have already marked your attendance for " + date + " at " + fromTime);
        }

        attendance.setPresent(true);
        studentAttendanceRepository.save(attendance);
        return true;
    }
    
    // New method to mark attendance based on schedule ID and email
    @Transactional
    public boolean markAttendanceByScheduleId(Long scheduleId, String email) {
        Optional<StudentAttendance> attendanceOpt = studentAttendanceRepository.findBySchedule_IdAndEmail(scheduleId, email);
        
        if (attendanceOpt.isEmpty()) {
            throw new AttendanceRecordNotFoundException("No attendance record found for " + email + " in schedule " + scheduleId);
        }
        
        StudentAttendance attendance = attendanceOpt.get();
        
        if (attendance.isPresent()) {
            throw new AttendanceAlreadyMarkedException("Attendance already marked for " + email + " in this schedule");
        }
        
        attendance.setPresent(true);
        studentAttendanceRepository.save(attendance);
        return true;
    }
    
    // New method to mark attendance for multiple students in a schedule
    @Transactional
    public int markAttendanceForMultipleStudents(Long scheduleId, List<String> emails) {
        int markedCount = 0;
        
        for (String email : emails) {
            try {
                if (markAttendanceByScheduleId(scheduleId, email)) {
                    markedCount++;
                }
            } catch (Exception e) {
                // Log the error but continue with other students
                System.out.println("Error marking attendance for " + email + ": " + e.getMessage());
            }
        }
        
        return markedCount;
    }
    
    // New method to get all students for a schedule
    public List<StudentAttendance> getStudentAttendanceByScheduleId(Long scheduleId) {
        return studentAttendanceRepository.findBySchedule_Id(scheduleId);
    }
    
    // New method to get present students for a schedule
    public List<StudentAttendance> getPresentStudentsByScheduleId(Long scheduleId) {
        return studentAttendanceRepository.findBySchedule_IdAndPresentTrue(scheduleId);
    }
    
    // New method to get absent students for a schedule
    public List<StudentAttendance> getAbsentStudentsByScheduleId(Long scheduleId) {
        return studentAttendanceRepository.findBySchedule_IdAndPresentFalse(scheduleId);
    }

    public List<Schedule> getAllSchedules() {
        return scheduleRepository.findAll();
    }

    public List<Schedule> getSchedulesByLocation(String location) {
        return scheduleRepository.findByLocation(location);
    }

    public List<Schedule> getSchedulesByBranch(String branch) {
        // Updated to use studentBranch instead of branches
        return scheduleRepository.findByStudentBranchContaining(branch);
    }

    @Transactional // Add transactional annotation for create operation
    public Schedule createSchedule(ScheduleDTO scheduleDTO) {
        Schedule schedule = new Schedule();
        schedule.setLocation(scheduleDTO.getLocation());
        schedule.setRoomNo(scheduleDTO.getRoomNo());

        try {
            // Parse date from string to LocalDate
            LocalDate date = LocalDate.parse(scheduleDTO.getDate());
            schedule.setDate(date);

            // Parse fromTime and toTime from strings to LocalTime
            LocalTime fromTime = LocalTime.parse(scheduleDTO.getFromTime(), DateTimeFormatter.ofPattern("HH:mm"));
            LocalTime toTime = LocalTime.parse(scheduleDTO.getToTime(), DateTimeFormatter.ofPattern("HH:mm"));
            schedule.setFromTime(fromTime);
            schedule.setToTime(toTime);
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Invalid date or time format provided.", e);
        }

        schedule.setStudentBranch(scheduleDTO.getStudentBranch());

        Schedule savedSchedule = scheduleRepository.save(schedule);

        insertAttendanceForAllStudents(savedSchedule);

        return savedSchedule;
    }

    @Transactional // Add transactional annotation for update operation
    public Schedule updateSchedule(Long id, ScheduleDTO scheduleDetails) {
        Optional<Schedule> scheduleOptional = scheduleRepository.findById(id);
        if (scheduleOptional.isPresent()) {
            Schedule existingSchedule = scheduleOptional.get();

            existingSchedule.setLocation(scheduleDetails.getLocation());
            existingSchedule.setRoomNo(scheduleDetails.getRoomNo());

            try {
                // Parse and update date
                LocalDate date = LocalDate.parse(scheduleDetails.getDate());
                existingSchedule.setDate(date);

                // Parse and update fromTime and toTime
                LocalTime fromTime = LocalTime.parse(scheduleDetails.getFromTime(), DateTimeFormatter.ofPattern("H:mm"));
                LocalTime toTime = LocalTime.parse(scheduleDetails.getToTime(), DateTimeFormatter.ofPattern("H:mm"));
                existingSchedule.setFromTime(fromTime);
                existingSchedule.setToTime(toTime);
            } catch (DateTimeParseException e) {
                throw new IllegalArgumentException("Invalid date or time format provided for update.", e);
            }

            existingSchedule.setStudentBranch(scheduleDetails.getStudentBranch());
            Schedule updatedSchedule = scheduleRepository.save(existingSchedule);
            List<StudentAttendance> attendanceList = studentAttendanceRepository.findBySchedule_Id(id);
            for (StudentAttendance attendance : attendanceList) {
                attendance.setDate(updatedSchedule.getDate());
                attendance.setFromTime(updatedSchedule.getFromTime());
                attendance.setToTime(updatedSchedule.getToTime());
            }

            studentAttendanceRepository.saveAll(attendanceList);

            return updatedSchedule;
        } else {
            return null;
        }
    }

    @Transactional
    public boolean deleteSchedule(Long id) {
        System.out.println(">>> deleteSchedule service called with id: " + id);
        if (scheduleRepository.existsById(id)) {
            System.out.println("Schedule exists. Deleting related attendance records.");
            studentAttendanceRepository.deleteBySchedule_Id(id);
            System.out.println("Deleted related attendance records. Deleting schedule now.");
            scheduleRepository.deleteById(id);
            System.out.println("Schedule deleted successfully.");
            return true;
        } else {
            System.out.println("Schedule with id " + id + " does not exist.");
            return false;
        }
    }
    
    

    // New method to update only the mark status
    @Transactional
    public Optional<Schedule> updateMarkStatus(Long id, boolean mark) {
        Optional<Schedule> scheduleOptional = scheduleRepository.findById(id);
        if (scheduleOptional.isPresent()) {
            Schedule schedule = scheduleOptional.get();
            schedule.setMark(mark);
            return Optional.of(scheduleRepository.save(schedule));
        } else {
            return Optional.empty(); // Schedule not found
        }
    }
    
    // Update this method to check for time slot conflicts
    public boolean isTimeSlotAvailable(String location, LocalDate date, LocalTime fromTime, LocalTime toTime) {
        // Check if there are any schedules that overlap with the requested time slot
        List<Schedule> existingSchedules = scheduleRepository.findByLocationAndDate(location, date);

    for (Schedule existing : existingSchedules) {
        LocalTime existingFrom = existing.getFromTime();
        LocalTime existingTo = existing.getToTime();

        if (!(toTime.compareTo(existingFrom) <= 0 || fromTime.compareTo(existingTo) >= 0)) {
            return false; // Conflict
        }
    }

    return true; // No conflict
}
    

    private void insertAttendanceForAllStudents(Schedule schedule) {
        //  Split branches
        List<String> branches = Arrays.stream(schedule.getStudentBranch().split(","))
                .map(String::trim)
                .filter(b -> !b.isEmpty())
                .toList();

        List<StudentDetails> students = studentDetailsRepository.findByBranchIn(branches);

        if (students.isEmpty()) {
            System.out.println("⚠ No students found for these branches.");
        }
        List<StudentAttendance> attendanceList = students.stream().map(student -> {
            StudentAttendance attendance = new StudentAttendance();
            attendance.setEmail(student.getEmail());
            attendance.setPresent(false);
            attendance.setDate(schedule.getDate());
            attendance.setFromTime(schedule.getFromTime());
            attendance.setToTime(schedule.getToTime());
            // Update to use fromTime
            attendance.setSchedule(schedule);
            System.out.println("Setting time for student " + student.getEmail() + ": " + schedule.getFromTime());
            return attendance;
        }).toList();

        studentAttendanceRepository.saveAll(attendanceList);
    }
}