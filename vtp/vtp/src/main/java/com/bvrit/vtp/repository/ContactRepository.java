package com.bvrit.vtp.repository;

import com.bvrit.vtp.model.Contact;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ContactRepository extends JpaRepository<Contact, Long> {

    @Query(value = "SELECT * FROM contact_records", nativeQuery = true)
    List<Contact> findAllWithNativeQuery();
}