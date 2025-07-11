package com.bvrit.vtp.controller;

import com.bvrit.vtp.dto.ScheduleDTO;
import com.bvrit.vtp.model.Schedule;
import com.bvrit.vtp.model.StudentAttendance;
import com.bvrit.vtp.service.ScheduleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*; // Ensure this includes PutMapping, DeleteMapping, PathVariable, RequestBody
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.ArrayList;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional; // Import Optional
import java.util.stream.Collectors;

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
        logger.info("Received schedule creation request: {}", scheduleDTO);

        try {
            // Parse date and time to check availability
            LocalDate date = LocalDate.parse(scheduleDTO.getDate());
            // Parse fromTime and toTime
            LocalTime fromTime = LocalTime.parse(scheduleDTO.getFromTime(), DateTimeFormatter.ofPattern("HH:mm"));
            LocalTime toTime = LocalTime.parse(scheduleDTO.getToTime(), DateTimeFormatter.ofPattern("HH:mm"));

            // Check if the time slot is available
            if (!scheduleService.isTimeSlotAvailable(scheduleDTO.getLocation(), date, fromTime, toTime)) {
                Map<String, String> response = new HashMap<>();
                response.put("error", "The selected time slot is already booked for this location");
                logger.warn("Time slot unavailable: Location={}, Date={}, FromTime={}, ToTime={}",
                    scheduleDTO.getLocation(), date, fromTime, toTime);
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
            @RequestParam String fromTimeSlot,
            @RequestParam String toTimeSlot) {
        try {
            LocalTime fromTime = LocalTime.parse(fromTimeSlot, DateTimeFormatter.ofPattern("HH:mm"));
            LocalTime toTime = LocalTime.parse(toTimeSlot, DateTimeFormatter.ofPattern("HH:mm"));

            boolean isAvailable = scheduleService.isTimeSlotAvailable(location, date, fromTime, toTime);

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
            LocalDate date = LocalDate.parse(scheduleDetails.getDate()); // Assuming getter exists
            LocalTime fromTime = LocalTime.parse(scheduleDetails.getFromTime());
            LocalTime toTime = LocalTime.parse(scheduleDetails.getToTime());
            String location = scheduleDetails.getLocation();

            // Check if the new time slot is available for update (excluding current schedule ID)
            if (!scheduleService.isTimeSlotAvailable(location, date, fromTime, toTime,id)) {
                Map<String, String> response = new HashMap<>();
                response.put("error", "The selected time slot is already booked for this location");
                logger.warn("Time slot unavailable for update: Location={}, Date={}, FromTime={}, ToTime={}, ScheduleID={}",
                        location, date, fromTime, toTime, id);
                return ResponseEntity.badRequest().body(response);
            }
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
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteSchedule(@PathVariable Long id) {
        System.out.println(">>> deleteSchedule controller called with id: " + id);
        try {
            boolean deleted = scheduleService.deleteSchedule(id);
            if (deleted) {
                System.out.println("Schedule deleted successfully for id: " + id);
                Map<String, String> response = new HashMap<>();
                response.put("message", "Schedule deleted successfully");
                return ResponseEntity.ok(response);
            } else {
                System.out.println("Schedule not found for id: " + id);
                Map<String, String> response = new HashMap<>();
                response.put("error", "Schedule not found with id: " + id);
                return ResponseEntity.status(404).body(response);
            }
        } catch (Exception e) {
            System.out.println("Error deleting schedule with id " + id + ": " + e.getMessage());
            e.printStackTrace();
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to delete schedule: " + e.getMessage());
            return ResponseEntity.status(500).body(error);
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

    // New endpoint to get all students for a schedule
    @GetMapping(value="/{scheduleId}/students", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> getStudentsForSchedule(@PathVariable Long scheduleId) {
        logger.info("Fetching students for schedule ID: {}", scheduleId);
        try {
            List<StudentAttendance> attendances = scheduleService.getStudentAttendanceByScheduleId(scheduleId);

            // Convert to a simplified format for the frontend
            List<Map<String, Object>> result = new ArrayList<>();
            for (StudentAttendance attendance : attendances) {
                Map<String, Object> studentMap = new HashMap<>();
                studentMap.put("email", attendance.getEmail());
                studentMap.put("present", attendance.isPresent());
                result.add(studentMap);
            }

            // Explicitly convert to JSON using Jackson
            ObjectMapper mapper = new ObjectMapper();
            String jsonResult = mapper.writeValueAsString(result);

            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResult);
        } catch (Exception e) {
            logger.error("Error fetching students for schedule ID {}: {}", scheduleId, e.getMessage(), e);
            Map<String, String> response = new HashMap<>();
            response.put("error", "Failed to fetch students: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // New endpoint to get present students for a schedule
    @GetMapping(value="/{scheduleId}/students/present", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> getPresentStudents(@PathVariable Long scheduleId) {
        logger.info("Fetching present students for schedule ID: {}", scheduleId);
        try {
            List<StudentAttendance> attendances = scheduleService.getPresentStudentsByScheduleId(scheduleId);

            // Convert to a simplified format for the frontend
            List<Map<String, Object>> result = new ArrayList<>();
            for (StudentAttendance attendance : attendances) {
                Map<String, Object> studentMap = new HashMap<>();
                studentMap.put("email", attendance.getEmail());
                studentMap.put("present", true);
                result.add(studentMap);
            }

            // Explicitly convert to JSON using Jackson
            ObjectMapper mapper = new ObjectMapper();
            String jsonResult = mapper.writeValueAsString(result);

            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResult);
        } catch (Exception e) {
            logger.error("Error fetching present students for schedule ID {}: {}", scheduleId, e.getMessage(), e);
            Map<String, String> response = new HashMap<>();
            response.put("error", "Failed to fetch present students: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // New endpoint to get absent students for a schedule
    @GetMapping(value="/{scheduleId}/students/absent", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> getAbsentStudents(@PathVariable Long scheduleId) {
        logger.info("Fetching absent students for schedule ID: {}", scheduleId);
        try {
            List<StudentAttendance> attendances = scheduleService.getAbsentStudentsByScheduleId(scheduleId);

            // Convert to a simplified format for the frontend
            List<Map<String, Object>> result = new ArrayList<>();
            for (StudentAttendance attendance : attendances) {
                Map<String, Object> studentMap = new HashMap<>();
                studentMap.put("email", attendance.getEmail());
                studentMap.put("present", false);
                result.add(studentMap);
            }

            // Explicitly convert to JSON using Jackson
            ObjectMapper mapper = new ObjectMapper();
            String jsonResult = mapper.writeValueAsString(result);

            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResult);
        } catch (Exception e) {
            logger.error("Error fetching absent students for schedule ID {}: {}", scheduleId, e.getMessage(), e);
            Map<String, String> response = new HashMap<>();
            response.put("error", "Failed to fetch absent students: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // New endpoint to mark attendance for multiple students
    @PostMapping(value= "/{scheduleId}/mark-attendance", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> markAttendance(
            @PathVariable Long scheduleId,
            @RequestBody List<String> emails) {

        logger.info("Marking attendance for {} students in schedule ID: {}", emails.size(), scheduleId);
        try {
            int markedCount = scheduleService.markAttendanceForMultipleStudents(scheduleId, emails);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("markedCount", markedCount);
            response.put("message", "Successfully marked attendance for " + markedCount + " students");

            logger.info("Successfully marked attendance for {} students in schedule ID: {}", markedCount, scheduleId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Error marking attendance for schedule ID {}: {}", scheduleId, e.getMessage(), e);
            Map<String, String> response = new HashMap<>();
            response.put("error", "Failed to mark attendance: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // New endpoint to mark attendance for a single student
    @PostMapping(value= "/{scheduleId}/mark-attendance/{email}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> markSingleAttendance(
            @PathVariable Long scheduleId,
            @PathVariable String email) {

        logger.info("Marking attendance for student {} in schedule ID: {}", email, scheduleId);
        try {
            boolean marked = scheduleService.markAttendanceByScheduleId(scheduleId, email);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Successfully marked attendance for " + email);

            logger.info("Successfully marked attendance for student {} in schedule ID: {}", email, scheduleId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Error marking attendance for student {} in schedule ID {}: {}", email, scheduleId, e.getMessage(), e);
            Map<String, String> response = new HashMap<>();
            response.put("error", "Failed to mark attendance: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
    }
    
    @GetMapping(value = "/{scheduleId}/attendance-stats", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> getAttendanceStats(@PathVariable Long scheduleId) {
        try {
            List<StudentAttendance> all = scheduleService.getStudentAttendanceByScheduleId(scheduleId);
            List<StudentAttendance> present = scheduleService.getPresentStudentsByScheduleId(scheduleId);
            List<StudentAttendance> absent = scheduleService.getAbsentStudentsByScheduleId(scheduleId);
    
            Map<String, Object> stats = new HashMap<>();
            stats.put("totalStudents", all.size());
            stats.put("presentCount", present.size());
            stats.put("absentCount", absent.size());
    
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to fetch attendance stats: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
}