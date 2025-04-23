package com.bvrit.vtp.service;

import com.bvrit.vtp.dao.ScheduleRepository;
import com.bvrit.vtp.dao.StudentAttendanceRepo;
import com.bvrit.vtp.dao.StudentDetailsRepo;
import com.bvrit.vtp.dto.ScheduleDTO;
import com.bvrit.vtp.model.Schedule;
import com.bvrit.vtp.model.StudentAttendance;
import com.bvrit.vtp.model.StudentDetails;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;
import java.util.ArrayList;
import java.util.stream.Collectors;

@Service
public class ScheduleService {

    @Autowired
    private ScheduleRepository scheduleRepo;

    @Autowired
    private StudentDetailsRepo studentDetailsRepository;

    @Autowired
    private StudentAttendanceRepo studentAttendanceRepository;

    // Method to get all schedules
    public List<Schedule> getAllSchedules() {
        return scheduleRepo.findAll();
    }

    // Method to get schedule by its ID
    public Optional<Schedule> getScheduleById(Long id) {
        return scheduleRepo.findById(id);
    }

    // Method to get schedules by location
    public List<Schedule> getSchedulesByLocation(String location) {
        return scheduleRepo.findByLocation(location);
    }

    // Method to get schedules by branch
    public List<Schedule> getSchedulesByBranch(String branch) {
        return scheduleRepo.findByStudentBranchContaining(branch);
    }

    // Method to create a schedule and insert attendance for students in that branch
    public Schedule createSchedule(ScheduleDTO scheduleDTO) {
        List<Schedule> createdSchedules = new ArrayList<>();

        // Loop over all branches provided in the DTO
        for (String branch : scheduleDTO.getBranches()) {
            Schedule schedule = new Schedule();
            schedule.setLocation(scheduleDTO.getLocation());
            schedule.setRoomNo(scheduleDTO.getRoomNo());

            // Parse date from string to LocalDate
            LocalDate date = LocalDate.parse(scheduleDTO.getDate());
            schedule.setDate(date);

            // Parse time from string to LocalTime
            String timeStr = scheduleDTO.getTime().split(" - ")[0];  // Assuming format like "9:30 - 11:15"
            LocalTime time = LocalTime.parse(timeStr, DateTimeFormatter.ofPattern("H:mm"));
            schedule.setTime(time);

            // Set branch (converting list to comma-separated string)
            if (scheduleDTO.getBranches() != null && !scheduleDTO.getBranches().isEmpty()) {
                String branchesString = scheduleDTO.getBranches().stream()
                        .filter(branchName -> branchName != null && !branchName.trim().isEmpty())
                        .collect(Collectors.joining(","));
                schedule.setStudentBranch(branchesString);
            } else {
                schedule.setStudentBranch(null);  // Or empty string if needed
            }

            // Save schedule and insert attendance records
            Schedule savedSchedule = scheduleRepo.save(schedule);
            insertAttendanceForAllStudents(savedSchedule);
            createdSchedules.add(savedSchedule);
        }

        return createdSchedules.get(0);  // Returning the first schedule
    }

    private void insertAttendanceForAllStudents(Schedule schedule) {
        List<String> emails = studentDetailsRepository.findAllEmails();

        List<StudentAttendance> attendanceList = emails.stream().map(email -> {
            StudentAttendance attendance = new StudentAttendance();
            attendance.setEmail(email);
            attendance.setPresent(false);
            attendance.setDate(schedule.getDate());
            return attendance;
        }).toList();

        studentAttendanceRepository.saveAll(attendanceList);

    }

    // Method to check if the given time slot is available for a specific location and date
    public boolean isTimeSlotAvailable(String location, LocalDate date, LocalTime time) {
        List<Schedule> existingSchedules = scheduleRepo.findByLocationAndDateAndTime(location, date, time);
        return existingSchedules.isEmpty();
    }
}