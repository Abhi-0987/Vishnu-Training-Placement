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

    public Schedule createSchedule(ScheduleDTO scheduleDTO) {
        Schedule schedule = new Schedule();
        schedule.setLocation(scheduleDTO.getLocation());
        schedule.setRoomNo(scheduleDTO.getRoomNo());
        
        // Parse date from string to LocalDate
        LocalDate date = LocalDate.parse(scheduleDTO.getDate());
        schedule.setDate(date);
        
        // Parse time from string to LocalTime
        // Assuming time format is like "9:30 - 11:15", we'll take the start time
        String timeStr = scheduleDTO.getTime().split(" - ")[0];
        LocalTime time = LocalTime.parse(timeStr, DateTimeFormatter.ofPattern("H:mm"));
        schedule.setTime(time);
        
        schedule.setStudentBranch(scheduleDTO.getStudentBranch());
        
        return scheduleRepository.save(schedule);
    }

    public boolean isTimeSlotAvailable(String location, LocalDate date, LocalTime time) {
        List<Schedule> existingSchedules = scheduleRepository.findByLocationAndDateAndTime(location, date, time);
        return existingSchedules.isEmpty();
    }
}