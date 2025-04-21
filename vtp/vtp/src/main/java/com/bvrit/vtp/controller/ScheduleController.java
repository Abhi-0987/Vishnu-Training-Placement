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

import org.slf4j.Logger; // Import Logger
import org.slf4j.LoggerFactory; // Import LoggerFactory

@RestController
@RequestMapping("/api")
public class ScheduleController {

    // Add Logger instance
    private static final Logger logger = LoggerFactory.getLogger(ScheduleController.class);

    @Autowired
    private ScheduleService scheduleService;

    // Make sure you have this endpoint and it's properly secured
    @GetMapping(value ="/schedules",produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<Schedule>> getAllSchedules() {
        return ResponseEntity.ok(scheduleService.getAllSchedules());
    }
    
    @GetMapping(value = "/schedules/branch/{branch}",produces = MediaType.APPLICATION_JSON_VALUE )
    public ResponseEntity<List<Schedule>> getSchedulesByBranch(@PathVariable String branch) {
        return ResponseEntity.ok(scheduleService.getSchedulesByBranch(branch));
    }

    @PostMapping(value = "/schedules", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> createSchedule(@RequestBody ScheduleDTO scheduleDTO) {
        // Log the received DTO
        logger.info("Received schedule creation request: {}", scheduleDTO);

        try {
            // Parse date and time to check availability
            LocalDate date = LocalDate.parse(scheduleDTO.getDate());
            // Ensure time parsing matches the format sent from frontend (e.g., "HH:mm" or "H:mm")
            String timeStr = scheduleDTO.getTime().split(" - ")[0]; // Adjust if format is different
            LocalTime time = LocalTime.parse(timeStr, DateTimeFormatter.ofPattern("H:mm")); // Adjust pattern if needed

            // Check if the time slot is available
            if (!scheduleService.isTimeSlotAvailable(scheduleDTO.getLocation(), date, time)) {
                Map<String, String> response = new HashMap<>();
                response.put("error", "The selected time slot is already booked for this location");
                logger.warn("Time slot unavailable: Location={}, Date={}, Time={}", scheduleDTO.getLocation(), date, time);
                return ResponseEntity.badRequest().body(response);
            }

            Schedule createdSchedule = scheduleService.createSchedule(scheduleDTO);
            logger.info("Successfully created schedule with ID: {}", createdSchedule.getId());
            return ResponseEntity.status(HttpStatus.CREATED).body(createdSchedule);
        } catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("error", "Failed to create schedule: " + e.getMessage());
            // Log the exception
            logger.error("Error creating schedule for DTO: {}", scheduleDTO, e);
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    @GetMapping("/schedules/check-availability")
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