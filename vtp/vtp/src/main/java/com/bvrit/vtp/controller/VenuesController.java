package com.bvrit.vtp.controller;

import com.bvrit.vtp.dto.VenueDTO;
import com.bvrit.vtp.service.VenuesService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
public class VenuesController {
    
    private final VenuesService venuesService;
    
    @Autowired
    public VenuesController(VenuesService venuesService) {
        this.venuesService = venuesService;
    }
    
    @GetMapping(value = "/venues", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<VenueDTO>> getAllVenues() {
        List<VenueDTO> venues = venuesService.getAllVenues();
        return ResponseEntity.ok(venues);
    }


}