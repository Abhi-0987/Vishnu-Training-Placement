package com.bvrit.vtp.controller;

import com.bvrit.vtp.service.ScheduleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import com.bvrit.vtp.exception.AttendanceAlreadyMarkedException;
import com.bvrit.vtp.exception.AttendanceRecordNotFoundException;

@RestController
@RequestMapping("/api")
public class AttendanceController {

    @Autowired
    private ScheduleService scheduleService;

    // Endpoint to mark attendance as present for a student
    @PutMapping("/attendance/mark-present")
    public ResponseEntity<?> markAttendancePresent(
            @RequestParam String email,  // Student email
            @RequestParam String date,
            @RequestParam String time  // The schedule ID for which attendance is to be marked
    ) {
        try {
            // Call service to mark attendance present
            LocalDate Date = LocalDate.parse(date);

            String timeStr = time.split(" - ")[0];// Assuming format like "9:30 - 11:15"
            LocalTime Time = LocalTime.parse(timeStr, DateTimeFormatter.ofPattern("H:mm"));

            boolean success = scheduleService.markAttendancePresent(email, Date, Time);
            if (success) {
                return ResponseEntity.ok("Attendance marked as present successfully.");
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Student or schedule not found.");
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }
    @ExceptionHandler(AttendanceAlreadyMarkedException.class)
    public ResponseEntity<String> handleAlreadyMarked(AttendanceAlreadyMarkedException ex) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(ex.getMessage());
    }

    @ExceptionHandler(AttendanceRecordNotFoundException.class)
    public ResponseEntity<String> handleNotFound(AttendanceRecordNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ex.getMessage());
    }
}