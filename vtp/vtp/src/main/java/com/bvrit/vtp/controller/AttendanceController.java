package com.bvrit.vtp.controller;

import com.bvrit.vtp.dao.VenuesRepository;
import com.bvrit.vtp.model.Venues;
import com.bvrit.vtp.service.ScheduleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.Optional;

import com.bvrit.vtp.exception.AttendanceAlreadyMarkedException;
import com.bvrit.vtp.exception.AttendanceRecordNotFoundException;

@RestController
@RequestMapping("/api")
public class AttendanceController {

    @Autowired
    private ScheduleService scheduleService;

    @Autowired
    private VenuesRepository venuesRepository;

    // Endpoint to mark attendance as present for a student
    @PutMapping("/attendance/mark-present")
    public ResponseEntity<?> markAttendancePresent(@RequestBody Map<String,String> Data) {
        try {
            String date = Data.get("date");
            String time = Data.get("time");
            String email = Data.get("email");
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

    @PostMapping(value = "/fetch/coordinates", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> fetchCoordinates(@RequestBody Map<String, String> location) {
        String blockName = location.get("venue");
        String roomNumber = location.get("roomNo");

        if (blockName == null || roomNumber == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Block name and Room number are required"));
        }

        Optional<Venues> optionalVenue = venuesRepository.findByBlockNameAndRoomNumber(blockName, roomNumber);

        if (optionalVenue.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "Venue not found for the given block and room number"));
        }

        Venues venue = optionalVenue.get();

        Map<String, Object> coordinates = Map.of(
                "latitude", venue.getLatitude(),
                "longitude", venue.getLongitude()
        );

        return ResponseEntity.ok(coordinates);
    }

}