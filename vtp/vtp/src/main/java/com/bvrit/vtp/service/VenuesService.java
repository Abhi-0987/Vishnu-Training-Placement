package com.bvrit.vtp.service;

import com.bvrit.vtp.dto.VenueDTO;
import com.bvrit.vtp.model.Venues;
import com.bvrit.vtp.dao.VenuesRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class VenuesService {
    
    private static final Logger logger = LoggerFactory.getLogger(VenuesService.class);
    
    private final VenuesRepository venuesRepository;
    
    @Autowired
    public VenuesService(VenuesRepository venuesRepository) {
        this.venuesRepository = venuesRepository;
    }
    
    public List<VenueDTO> getAllVenues() {
        List<Venues> venues = venuesRepository.findAll();

        // Convert entities to DTOs
        return venues.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    private VenueDTO convertToDTO(Venues venue) {
        return new VenueDTO(
                venue.getId(),
                venue.getBlockName(),
                venue.getRoomNumber(),
                venue.getLatitude(),
                venue.getLongitude()
        );
    }
}