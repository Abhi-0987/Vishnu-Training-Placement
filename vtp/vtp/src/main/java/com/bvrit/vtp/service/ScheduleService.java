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
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

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
        Schedule schedule = new Schedule();
        schedule.setLocation(scheduleDTO.getLocation());
        schedule.setRoomNo(scheduleDTO.getRoomNo());

        LocalDate date = LocalDate.parse(scheduleDTO.getDate());
        schedule.setDate(date);

        String timeStr = scheduleDTO.getTime().split(" - ")[0];// Assuming format like "9:30 - 11:15"
        LocalTime time = LocalTime.parse(timeStr, DateTimeFormatter.ofPattern("H:mm"));
        schedule.setTime(time);

        if (scheduleDTO.getBranches() != null && !scheduleDTO.getBranches().isEmpty()) {
            String branchesString = String.join(",", scheduleDTO.getBranches());
            schedule.setStudentBranch(branchesString);
        } else {
            schedule.setStudentBranch(null);
        }

        // Save only once
        Schedule savedSchedule = scheduleRepo.save(schedule);

        // Insert attendance only once
        insertAttendanceForAllStudents(savedSchedule);

        return savedSchedule;
    }


    private void insertAttendanceForAllStudents(Schedule schedule) {
        //  Split branches
        List<String> branches = Arrays.stream(schedule.getStudentBranch().split(","))
                .map(String::trim)
                .filter(b -> !b.isEmpty())
                .toList();

        List<StudentDetails> students = studentDetailsRepository.findByBranchIn(branches);

        if (students.isEmpty()) {
            System.out.println("⚠️ No students found for these branches.");
        }

        // Step 4: Prepare attendance list and print count
        List<StudentAttendance> attendanceList = students.stream().map(student -> {
            StudentAttendance attendance = new StudentAttendance();
            attendance.setEmail(student.getEmail());
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