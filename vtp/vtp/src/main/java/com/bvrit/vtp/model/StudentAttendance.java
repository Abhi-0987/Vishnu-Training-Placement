package com.bvrit.vtp.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(name = "student_attendance")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentAttendance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "student_email")
    private String email;

    @Column(nullable = false)
    private boolean present = false;

    private LocalDate date;

    private LocalTime time;
    
    // Define proper relationship with Schedule using bigint
    @ManyToOne
    @JoinColumn(name = "schedule_id")
    private Schedule schedule;
    
    // No need for separate scheduleId field as it's handled by the relationship
}
