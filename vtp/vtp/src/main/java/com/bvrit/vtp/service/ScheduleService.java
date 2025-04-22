package com.bvrit.vtp.service;

import com.bvrit.vtp.dao.ScheduleRepository;
import com.bvrit.vtp.dto.ScheduleDTO;
import com.bvrit.vtp.model.Schedule;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

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

    public Schedule createSchedule(ScheduleDTO scheduleDTO) {
        Schedule schedule = new Schedule();
        schedule.setLocation(scheduleDTO.getLocation());
        schedule.setRoomNo(scheduleDTO.getRoomNo());

        // Parse date from string to LocalDate
        LocalDate date = LocalDate.parse(scheduleDTO.getDate());
        schedule.setDate(date);

        // Parse time from string to LocalTime
        String timeStr = scheduleDTO.getTime().split(" - ")[0]; // Assuming format like "9:30 - 11:15"
        LocalTime time = LocalTime.parse(timeStr, DateTimeFormatter.ofPattern("H:mm")); // Or "HH:mm" if always 2 digits
        schedule.setTime(time);

        // **Fix:** Join the list of branches into a comma-separated string
        if (scheduleDTO.getBranches() != null && !scheduleDTO.getBranches().isEmpty()) {
            // Filter out any null or empty strings before joining
            String branchesString = scheduleDTO.getBranches().stream()
                                            .filter(branch -> branch != null && !branch.trim().isEmpty())
                                            .collect(Collectors.joining(","));
            schedule.setStudentBranch(branchesString);
        } else {
            schedule.setStudentBranch(null); // Or set to an empty string "" if preferred over null
        }

        return scheduleRepository.save(schedule);
    }

    public boolean isTimeSlotAvailable(String location, LocalDate date, LocalTime time) {
        List<Schedule> existingSchedules = scheduleRepository.findByLocationAndDateAndTime(location, date, time);
        return existingSchedules.isEmpty();
    }
}