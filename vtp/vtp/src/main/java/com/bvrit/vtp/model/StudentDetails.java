package com.bvrit.vtp.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "student_details")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)

    private String email;

    private String name;

    @Column(name = "parents_phone")
    private String parentsPhone;

    private String branch;

    private String year;

}
