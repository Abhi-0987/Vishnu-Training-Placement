package com.bvrit.vtp.controller;

import com.bvrit.vtp.dto.ScheduleDTO;
import com.bvrit.vtp.model.Schedule;
import com.bvrit.vtp.service.ScheduleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class ScheduleController {

    @Autowired
    private ScheduleService scheduleService;

    @GetMapping
    public ResponseEntity<List<Schedule>> getAllSchedules() {
        return ResponseEntity.ok(scheduleService.getAllSchedules());
    }

    @PostMapping(value = "/schedules", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> createSchedule(@RequestBody ScheduleDTO scheduleDTO) {
        try {
            // Parse date and time to check availability
            LocalDate date = LocalDate.parse(scheduleDTO.getDate());
            String timeStr = scheduleDTO.getTime().split(" - ")[0];
            LocalTime time = LocalTime.parse(timeStr, DateTimeFormatter.ofPattern("H:mm"));
            
            // Check if the time slot is available
            if (!scheduleService.isTimeSlotAvailable(scheduleDTO.getLocation(), date, time)) {
                Map<String, String> response = new HashMap<>();
                response.put("error", "The selected time slot is already booked for this location");
                return ResponseEntity.badRequest().body(response);
            }
            
            Schedule createdSchedule = scheduleService.createSchedule(scheduleDTO);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdSchedule);
        } catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("error", "Failed to create schedule: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    @GetMapping("/check-availability")
    public ResponseEntity<?> checkAvailability(
            @RequestParam String location,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam String timeSlot) {
        try {
            String timeStr = timeSlot.split(" - ")[0];
            LocalTime time = LocalTime.parse(timeStr, DateTimeFormatter.ofPattern("H:mm"));
            
            boolean isAvailable = scheduleService.isTimeSlotAvailable(location, date, time);
            
            Map<String, Boolean> response = new HashMap<>();
            response.put("available", isAvailable);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("error", "Failed to check availability: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
}