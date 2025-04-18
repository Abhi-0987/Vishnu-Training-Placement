package com.bvrit.vtp.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class VenueDTO {
    private Long id;
    private String blockName;
    private String roomNumber;
    private Double latitude;
    private Double longitude;
}