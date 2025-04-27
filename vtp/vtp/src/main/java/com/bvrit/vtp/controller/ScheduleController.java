package com.bvrit.vtp.controller;

import com.bvrit.vtp.dto.ScheduleDTO;
import com.bvrit.vtp.model.Schedule;
import com.bvrit.vtp.service.ScheduleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*; // Ensure this includes PutMapping, DeleteMapping, PathVariable, RequestBody

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional; // Import Optional

import org.slf4j.Logger; // Import Logger
import org.slf4j.LoggerFactory; // Import LoggerFactory

@RestController
@RequestMapping("/api/schedules") // Consolidated base path
public class ScheduleController {

    // Add Logger instance
    private static final Logger logger = LoggerFactory.getLogger(ScheduleController.class);

    @Autowired
    private ScheduleService scheduleService;

    // Make sure you have this endpoint and it's properly secured
    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE) // Path inherited from class level
    public ResponseEntity<List<Schedule>> getAllSchedules() {
        return ResponseEntity.ok(scheduleService.getAllSchedules());
    }

    @GetMapping(value = "/branch/{branch}", produces = MediaType.APPLICATION_JSON_VALUE) // Path relative to class level
    public ResponseEntity<List<Schedule>> getSchedulesByBranch(@PathVariable String branch) {
        return ResponseEntity.ok(scheduleService.getSchedulesByBranch(branch));
    }

    @PostMapping(produces = MediaType.APPLICATION_JSON_VALUE) // Path inherited from class level
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
            logger.error("Error creating schedule for DTO: {}", scheduleDTO, e);
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/check-availability") // Path relative to class level
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

    // Added PUT endpoint for updating schedules
    @PutMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> updateSchedule(@PathVariable Long id, @RequestBody ScheduleDTO scheduleDetails) {
         logger.info("Received schedule update request for ID {}: {}", id, scheduleDetails);
         try {
             // TODO: Implement the actual update logic in ScheduleService
             // Example: Schedule updatedSchedule = scheduleService.updateSchedule(id, scheduleDetails);
             // For now, just returning OK if the service call would succeed
             // Replace this placeholder logic with your actual service call
             Schedule updatedSchedule = scheduleService.updateSchedule(id, scheduleDetails); // Assuming this method exists and returns the updated schedule or throws an exception
             if (updatedSchedule != null) {
                 logger.info("Successfully updated schedule with ID: {}", id);
                 return ResponseEntity.ok(updatedSchedule);
             } else {
                 // Handle case where schedule is not found or update fails
                 logger.warn("Schedule with ID {} not found for update.", id);
                 Map<String, String> response = new HashMap<>();
                 response.put("error", "Schedule not found with id: " + id);
                 return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
             }
         } catch (Exception e) {
             Map<String, String> response = new HashMap<>();
             response.put("error", "Failed to update schedule: " + e.getMessage());
             logger.error("Error updating schedule with ID {}: {}", id, scheduleDetails, e);
             return ResponseEntity.badRequest().body(response);
         }
    }

    // Added DELETE endpoint for deleting schedules
    @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> deleteSchedule(@PathVariable Long id) {
        logger.info("Received schedule delete request for ID: {}", id);
        try {
            // TODO: Implement the actual delete logic in ScheduleService
            // Example: scheduleService.deleteSchedule(id);
            // For now, just returning NoContent if the service call would succeed
            // Replace this placeholder logic with your actual service call
            boolean deleted = scheduleService.deleteSchedule(id); // Assuming this method exists and returns true on success, false if not found
            if (deleted) {
                 logger.info("Successfully deleted schedule with ID: {}", id);
                 // Return a success message or just status code
                 Map<String, String> response = new HashMap<>();
                 response.put("message", "Schedule deleted successfully");
                 return ResponseEntity.ok(response); // Or ResponseEntity.noContent().build();
            } else {
                 logger.warn("Schedule with ID {} not found for deletion.", id);
                 Map<String, String> response = new HashMap<>();
                 response.put("error", "Schedule not found with id: " + id);
                 return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }
        } catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("error", "Failed to delete schedule: " + e.getMessage());
            logger.error("Error deleting schedule with ID {}: {}", id, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response); // Use 500 for server errors
        }
    }

    // New PUT endpoint for updating mark status
    @PutMapping(value = "/{id}/mark", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> updateScheduleMarkStatus(@PathVariable Long id, @RequestBody Map<String, Boolean> payload) {
        Boolean mark = payload.get("mark");
        if (mark == null) {
            logger.warn("Update mark request for ID {} missing 'mark' field in payload.", id);
            Map<String, String> response = new HashMap<>();
            response.put("error", "Missing 'mark' field in request body");
            return ResponseEntity.badRequest().body(response);
        }

        logger.info("Received schedule mark update request for ID {}: mark={}", id, mark);
        try {
            Optional<Schedule> updatedScheduleOpt = scheduleService.updateMarkStatus(id, mark);

            if (updatedScheduleOpt.isPresent()) {
                logger.info("Successfully updated mark status for schedule with ID: {}", id);
                return ResponseEntity.ok(updatedScheduleOpt.get()); // Return updated schedule
            } else {
                logger.warn("Schedule with ID {} not found for mark update.", id);
                Map<String, String> response = new HashMap<>();
                response.put("error", "Schedule not found with id: " + id);
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }
        } catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("error", "Failed to update schedule mark status: " + e.getMessage());
            logger.error("Error updating mark status for schedule with ID {}: {}", id, payload, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}