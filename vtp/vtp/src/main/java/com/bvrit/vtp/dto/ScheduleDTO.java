package com.bvrit.vtp.dto;

import lombok.Data;

@Data
public class ScheduleDTO {
    private String location;
    private String roomNo;
    private String date; // Format: yyyy-MM-dd
    private String time; // Format: HH:mm
    private String studentBranch;
}