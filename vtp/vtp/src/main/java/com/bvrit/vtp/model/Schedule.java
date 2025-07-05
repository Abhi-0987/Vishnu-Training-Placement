package com.bvrit.vtp.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Column;
import java.time.LocalDate;
import java.time.LocalTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "schedules")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Schedule {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String location;
    
    @Column(name = "room_no")
    private String roomNo;
    
    private LocalDate date;
    
    // Replace single time with fromTime and toTime
    @Column(name = "from_time", nullable=false )
    private LocalTime fromTime;
    
    @Column(name = "to_time", nullable=false)
    private LocalTime toTime;
    
    @Column(name = "student_branch")
    private String studentBranch;

    @Column(name = "mark")
    private boolean mark=false;
}