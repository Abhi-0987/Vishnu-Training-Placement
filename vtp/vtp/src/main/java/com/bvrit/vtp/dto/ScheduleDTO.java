package com.bvrit.vtp.dto;

// Remove import for List
// import java.util.List;

import lombok.Data;

@Data
public class ScheduleDTO {
    private String location;
    private String roomNo;
    private String date; // Format: yyyy-MM-dd
    private String time; // Format: HH:mm or similar for parsing
    // Change type from List<String> to String
    private String studentBranch; 
}