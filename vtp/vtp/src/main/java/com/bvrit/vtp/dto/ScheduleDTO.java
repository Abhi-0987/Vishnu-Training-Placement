package com.bvrit.vtp.dto;

import lombok.Data;

@Data
public class ScheduleDTO {
    private String location;
    private String roomNo;
    private String date; // Format: yyyy-MM-dd
    // Replace time with fromTime and toTime
    private String fromTime; // Format: HH:mm
    private String toTime; // Format: HH:mm
    private String studentBranch;
    private boolean mark;
}