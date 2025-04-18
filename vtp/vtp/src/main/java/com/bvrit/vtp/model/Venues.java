package com.bvrit.vtp.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "venues")
@Getter
@NoArgsConstructor
public class Venues {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(length = 100, unique = true, nullable = false)
    private String blockName;
    
    @Column(length = 10, nullable = false)
    private String roomNumber;
    
    @Column(unique = true, nullable = false)
    private Double latitude;
    
    @Column(unique = true, nullable = false)
    private Double longitude;

}
