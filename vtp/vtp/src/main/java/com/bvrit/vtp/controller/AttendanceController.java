package com.bvrit.vtp.controller;

import com.bvrit.vtp.service.ScheduleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api")
public class AttendanceController {

    @Autowired
    private ScheduleService scheduleService;

    // Endpoint to mark attendance as present for a student
    @PutMapping("/attendance/mark-present")
    public ResponseEntity<?> markAttendancePresent(
            @RequestParam String email,  // Student email
            @RequestParam LocalDate date   // The schedule ID for which attendance is to be marked
    ) {
        try {
            // Call service to mark attendance present
            boolean success = scheduleService.markAttendancePresent(email, date);
            if (success) {
                return ResponseEntity.ok("Attendance marked as present successfully.");
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Student or schedule not found.");
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error marking attendance.");
        }
    }
}
