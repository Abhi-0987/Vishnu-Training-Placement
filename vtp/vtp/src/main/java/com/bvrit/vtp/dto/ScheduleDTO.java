package com.bvrit.vtp.dto;

import lombok.Data;
import java.util.List;

@Data
public class ScheduleDTO {
    private String location;
    private String roomNo;
    private String date; // Format: yyyy-MM-dd
    private String time; // Format: HH:mm or similar for parsing
    private List<String> branches; // Ensure this field exists to receive data
}