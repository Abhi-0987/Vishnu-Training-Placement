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

    @Column(nullable = false)
    private LocalDate date;

    // Update to use fromTime instead of time
     @Column(name = "from_time", nullable=false )
    private LocalTime fromTime;
    
    @Column(name = "to_time", nullable=false)
    private LocalTime toTime;
    
    
    @ManyToOne
    @JoinColumn(name = "schedule_id")
    private Schedule schedule;
}
