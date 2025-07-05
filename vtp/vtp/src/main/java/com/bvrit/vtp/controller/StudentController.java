package com.bvrit.vtp.controller;

import com.bvrit.vtp.dao.StudentAttendanceRepo;
import com.bvrit.vtp.dao.StudentDetailsRepo;
import com.bvrit.vtp.model.StudentDetails;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/student")
public class StudentController {
    @Autowired
    private StudentDetailsRepo studentDetailsRepo;

    @Autowired
    private StudentAttendanceRepo studentAttendanceRepo;

    @PostMapping(value="/details", produces = "application/json")
    public ResponseEntity<?> getStudentDetailsByEmail(@RequestBody Map<String, String> payload) {
        String email = payload.get("email");

        if (email == null || email.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email is required"));
        }

        Optional<StudentDetails> studentOptional = studentDetailsRepo.findByEmail(email);
        return studentOptional.<ResponseEntity<?>>map(
                studentDetails -> ResponseEntity.ok(Map.of(
                        "name", studentDetails.getName(),
                        "branch", studentDetails.getBranch(),
                        "year", studentDetails.getYear(),
                        "email", studentDetails.getEmail()
                ))).orElseGet(() ->
                ResponseEntity.status(404).body(Map.of("error", "Student not found")));
    }

    @GetMapping(value = "/dates", produces = "application/json")
    public ResponseEntity<List<String>> getAvailableDates() {
        List<LocalDate> dates = studentAttendanceRepo.findDistinctDates();
        List<String> formattedDates = dates.stream()
                .map(LocalDate::toString)
                .toList();

        return ResponseEntity.ok(formattedDates);
    }



}
