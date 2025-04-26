package com.bvrit.vtp.service;

import com.bvrit.vtp.dao.ScheduleRepository;
import com.bvrit.vtp.dto.ScheduleDTO;
import com.bvrit.vtp.model.Schedule;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional; // Import Transactional

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException; // Import for exception handling
import java.util.List;
import java.util.Optional;
// Remove unused import
// import java.util.stream.Collectors;

@Service
public class ScheduleService {

    @Autowired
    private ScheduleRepository scheduleRepository;

    public List<Schedule> getAllSchedules() {
        return scheduleRepository.findAll();
    }

    public Optional<Schedule> getScheduleById(Long id) {
        return scheduleRepository.findById(id);
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

            // Parse time from string to LocalTime
            // Ensure time parsing handles potential variations if needed
            String timeStr = scheduleDTO.getTime().contains(" - ") ? scheduleDTO.getTime().split(" - ")[0] : scheduleDTO.getTime();
            LocalTime time = LocalTime.parse(timeStr, DateTimeFormatter.ofPattern("H:mm")); // Or "HH:mm"
            schedule.setTime(time);
        } catch (DateTimeParseException e) {
            // Handle parsing errors appropriately, e.g., throw a custom exception or log
            throw new IllegalArgumentException("Invalid date or time format provided.", e);
        }

        // **Fix:** Use studentBranch directly from the updated DTO
        // This line now correctly assigns String from DTO to String in Entity
        schedule.setStudentBranch(scheduleDTO.getStudentBranch()); 

        return scheduleRepository.save(schedule);
    }

    @Transactional // Add transactional annotation for update operation
    public Schedule updateSchedule(Long id, ScheduleDTO scheduleDetails) {
        Optional<Schedule> scheduleOptional = scheduleRepository.findById(id);
        if (scheduleOptional.isPresent()) {
            Schedule existingSchedule = scheduleOptional.get();
            
            // Update fields from DTO
            existingSchedule.setLocation(scheduleDetails.getLocation());
            existingSchedule.setRoomNo(scheduleDetails.getRoomNo());
            
            try {
                // Parse and update date
                LocalDate date = LocalDate.parse(scheduleDetails.getDate());
                existingSchedule.setDate(date);

                // Parse and update time
                String timeStr = scheduleDetails.getTime().contains(" - ") ? scheduleDetails.getTime().split(" - ")[0] : scheduleDetails.getTime();
                LocalTime time = LocalTime.parse(timeStr, DateTimeFormatter.ofPattern("H:mm"));
                existingSchedule.setTime(time);
            } catch (DateTimeParseException e) {
                 throw new IllegalArgumentException("Invalid date or time format provided for update.", e);
            }

            // Update studentBranch
            // This line now correctly assigns String from DTO to String in Entity
            existingSchedule.setStudentBranch(scheduleDetails.getStudentBranch());

            return scheduleRepository.save(existingSchedule);
        } else {
            // Optionally throw an exception or return null based on desired behavior
            // For now, returning null as indicated by the controller logic
            return null; 
        }
    }

    @Transactional // Add transactional annotation for delete operation
    public boolean deleteSchedule(Long id) {
        if (scheduleRepository.existsById(id)) {
            scheduleRepository.deleteById(id);
            return true;
        } else {
            return false;
        }
    }

    public boolean isTimeSlotAvailable(String location, LocalDate date, LocalTime time) {
        List<Schedule> existingSchedules = scheduleRepository.findByLocationAndDateAndTime(location, date, time);
        return existingSchedules.isEmpty();
    }
}