package com.bvrit.vtp.dto;

import lombok.Data;
// Remove import for List as it's no longer needed for branches
// import java.util.List;

@Data
public class ScheduleDTO {
    private String location;
    private String roomNo;
    private String date; // Format: yyyy-MM-dd
    private String time; // Format: HH:mm or similar for parsing
    // Change from List<String> branches to String studentBranch
    private String studentBranch; 
}