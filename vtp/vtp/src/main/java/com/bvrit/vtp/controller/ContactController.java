package com.bvrit.vtp.controller;


import com.bvrit.vtp.model.Contact;
import com.bvrit.vtp.repository.ContactRepository;
import com.bvrit.vtp.service.ExcelService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@RestController
@RequestMapping("/api")
public class ContactController {

    @Autowired
    private ContactRepository contactRepository;

    @Autowired
    private ExcelService excelService;

    @PostMapping(value="/contacts", produces = MediaType.APPLICATION_JSON_VALUE)
    public Contact addContact(@RequestBody Contact contact) {
        return contactRepository.save(contact);
    }

    @GetMapping(value="/contacts", produces = MediaType.APPLICATION_JSON_VALUE )
    public List<Contact> getAllContacts() {
        List<Contact> contacts = contactRepository.findAll();
        System.out.println("Database query returned " + contacts.size() + " contacts");
        for (Contact contact : contacts) {
            System.out.println("Found contact: ID=" + contact.getId() + ", Name=" + contact.getName() + ", Phone=" + contact.getPhoneNumber());
        }
        return contacts;
    }

    @PostMapping(value="/contacts/update-excel", produces = MediaType.APPLICATION_JSON_VALUE)
    public String forceExcelUpdate() {
        excelService.updateExcelSheet();
        return "Excel update triggered";
    }

    @PostMapping(value="/contacts/delete-excel", produces = MediaType.APPLICATION_JSON_VALUE)
    public String forceExcelDelete() {
        excelService.deleteOldExcelFiles();
        return "Excel file deletion triggered";
    }

    // New endpoint to download contacts as Excel file
    @GetMapping(value="/contacts/download", produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
    public ResponseEntity<byte[]> downloadContactsAsExcel() {
        try {
            List<Contact> contacts = contactRepository.findAll();
            byte[] excelBytes = excelService.generateContactsExcel(contacts);
            
            // Format the filename as contacts-DDMMYYYY
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("ddMMyyyy");
            String formattedDate = LocalDateTime.now().format(formatter);
            String fileName = "contacts-" + formattedDate + ".xlsx";
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
            headers.setContentDispositionFormData("attachment", fileName);
            
            return new ResponseEntity<>(excelBytes, headers, HttpStatus.OK);
        } catch (Exception e) {
            e.printStackTrace();
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // New endpoint to download attendance data as Excel file
    @GetMapping(value="/attendance/download", produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
    public ResponseEntity<byte[]> downloadAttendanceAsExcel() {
        try {
            System.out.println("Attendance download endpoint called");

            // Get all contacts from repository (we'll use this as a base for attendance)
            List<Contact> contacts = contactRepository.findAll();

            if (contacts.isEmpty()) {
                System.out.println("No contacts found in database");
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            }

            System.out.println("Found " + contacts.size() + " contacts for attendance export");

            // Generate Excel file using ExcelService - create a new method in ExcelService if needed
            byte[] excelBytes = excelService.generateAttendanceExcel(contacts);

            if (excelBytes == null || excelBytes.length == 0) {
                System.out.println("Generated Excel file is empty");
                return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
            }

            System.out.println("Generated Excel file size: " + excelBytes.length + " bytes");

            // Set up response headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
            headers.setContentDispositionFormData("attachment", "attendance_" + System.currentTimeMillis() + ".xlsx");

            return new ResponseEntity<>(excelBytes, headers, HttpStatus.OK);
        } catch (Exception e) {
            System.out.println("Error generating attendance Excel: " + e.getMessage());
            e.printStackTrace();
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}