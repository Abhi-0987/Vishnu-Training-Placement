package com.bvrit.vtp.service;


import com.bvrit.vtp.model.Contact;
import com.bvrit.vtp.repository.ContactRepository;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class ExcelService {

    @Autowired
    private ContactRepository contactRepository;

    // Define the missing constants
    private static final String EXCEL_DIRECTORY = "excel_files";
    private static final String EXCEL_FILE_BASE_PATH = "contacts";
    private static final String EXCEL_FILE_PATH = EXCEL_DIRECTORY + File.separator + EXCEL_FILE_BASE_PATH + ".xlsx";

    // Add the missing method for getting current file path with date-time
    private String getCurrentExcelFilePath() {
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss");
        String dateTime = now.format(formatter);
        return EXCEL_DIRECTORY + File.separator + EXCEL_FILE_BASE_PATH + "_" + dateTime + ".xlsx";
    }

    // Run immediately on startup and then every 5 minutes
    @Scheduled(fixedRate = 300000, initialDelay = 0)
    public void updateExcelSheet() {
        System.out.println("Starting Excel update...");

        // Try both methods to fetch data
        List<Contact> contacts = contactRepository.findAll();
        System.out.println("JPA findAll() found " + contacts.size() + " contacts");

        List<Contact> nativeContacts = contactRepository.findAllWithNativeQuery();
        System.out.println("Native query found " + nativeContacts.size() + " contacts");

        // Use whichever list has data
        List<Contact> contactsToUse = contacts.isEmpty() ? nativeContacts : contacts;

        if (contactsToUse.isEmpty()) {
            System.out.println("WARNING: No contacts found in database!");
            return;
        }

        try {
            // Create directory if it doesn't exist
            File file = new File(EXCEL_FILE_PATH);
            if (!file.exists()) {
                file.getParentFile().mkdirs();
            }

            Workbook workbook = new XSSFWorkbook();
            Sheet sheet = workbook.createSheet("Contacts");

            // Create header row with style
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            Row headerRow = sheet.createRow(0);
            Cell idCell = headerRow.createCell(0);
            idCell.setCellValue("ID");
            idCell.setCellStyle(headerStyle);

            Cell nameCell = headerRow.createCell(1);
            nameCell.setCellValue("Name");
            nameCell.setCellStyle(headerStyle);

            Cell phoneCell = headerRow.createCell(2);
            phoneCell.setCellValue("Phone Number");
            phoneCell.setCellStyle(headerStyle);

            // Fill data
            int rowNum = 1;
            for (Contact contact : contactsToUse) {
                Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue(contact.getId());
                row.createCell(1).setCellValue(contact.getName());
                row.createCell(2).setCellValue(contact.getPhoneNumber());
                System.out.println("Added contact: " + contact.getName()); // Debug log
            }

            // Auto-size columns
            for (int i = 0; i < 3; i++) {
                sheet.autoSizeColumn(i);
            }

            // Write to file
            try (FileOutputStream outputStream = new FileOutputStream(EXCEL_FILE_PATH)) {
                workbook.write(outputStream);
                System.out.println("Excel file updated successfully at: " + file.getAbsolutePath());
            }
            workbook.close();
        } catch (IOException e) {
            System.err.println("Error updating Excel file: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Scheduled(cron = "0 0 0 */7 * *") // Runs every 7 days at midnight
    public void deleteOldExcelFiles() {
        System.out.println("Starting weekly Excel file cleanup...");
        File directory = new File(EXCEL_DIRECTORY);

        if (directory.exists() && directory.isDirectory()) {
            File[] files = directory.listFiles((dir, name) -> name.startsWith(EXCEL_FILE_BASE_PATH) && name.endsWith(".xlsx"));

            if (files != null) {
                for (File file : files) {
                    // Get file age in days
                    long fileAge = (System.currentTimeMillis() - file.lastModified()) / (24 * 60 * 60 * 1000);

                    // Delete files older than 7 days
                    if (fileAge > 7) {
                        if (file.delete()) {
                            System.out.println("Deleted old Excel file: " + file.getName());
                        } else {
                            System.err.println("Failed to delete Excel file: " + file.getName());
                        }
                    }
                }
            }
        } else {
            System.out.println("Excel directory does not exist, no deletion needed");
        }
    }

    //@Scheduled(fixedRate = 120000) // Changed to run every 2 minutes (120000 milliseconds)
    public void clearExcelSheet() {
        System.out.println("Starting Excel file clear operation...");
        try {
            // Get current file path with date-time
            String currentFilePath = getCurrentExcelFilePath();

            // Create directory if it doesn't exist
            File file = new File(currentFilePath);
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }

            Workbook workbook = new XSSFWorkbook();
            Sheet sheet = workbook.createSheet("Contacts");

            // Create header row with style
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            Row headerRow = sheet.createRow(0);
            Cell idCell = headerRow.createCell(0);
            idCell.setCellValue("ID");
            idCell.setCellStyle(headerStyle);

            Cell nameCell = headerRow.createCell(1);
            nameCell.setCellValue("Name");
            nameCell.setCellStyle(headerStyle);

            Cell phoneCell = headerRow.createCell(2);
            phoneCell.setCellValue("Phone Number");
            phoneCell.setCellStyle(headerStyle);

            // Auto-size columns
            for (int i = 0; i < 3; i++) {
                sheet.autoSizeColumn(i);
            }

            // Write to file
            try (FileOutputStream outputStream = new FileOutputStream(currentFilePath)) {
                workbook.write(outputStream);
                System.out.println("Empty Excel file created successfully at: " + file.getAbsolutePath());
            }
            workbook.close();
        } catch (IOException e) {
            System.err.println("Error creating empty Excel file: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // Method to get the most recent Excel file path
    public String getMostRecentExcelFilePath() {
        File directory = new File(EXCEL_DIRECTORY);
        if (!directory.exists() || !directory.isDirectory()) {
            return null;
        }

        File[] files = directory.listFiles((dir, name) -> name.startsWith(EXCEL_FILE_BASE_PATH) && name.endsWith(".xlsx"));
        if (files == null || files.length == 0) {
            return null;
        }

        // Find the most recent file
        File mostRecent = files[0];
        for (File file : files) {
            if (file.lastModified() > mostRecent.lastModified()) {
                mostRecent = file;
            }
        }

        return mostRecent.getAbsolutePath();
    }


    public byte[] generateContactsExcel(List<Contact> contacts) throws IOException {
        // Create a new workbook
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Contacts");

        // Create header row with style
        CellStyle headerStyle = workbook.createCellStyle();
        Font headerFont = workbook.createFont();
        headerFont.setBold(true);
        headerStyle.setFont(headerFont);

        Row headerRow = sheet.createRow(0);
        Cell idCell = headerRow.createCell(0);
        idCell.setCellValue("ID");
        idCell.setCellStyle(headerStyle);

        Cell nameCell = headerRow.createCell(1);
        nameCell.setCellValue("Name");
        nameCell.setCellStyle(headerStyle);

        Cell phoneCell = headerRow.createCell(2);
        phoneCell.setCellValue("Phone Number");
        phoneCell.setCellStyle(headerStyle);

        // Fill data rows
        int rowNum = 1;
        for (Contact contact : contacts) {
            Row row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(contact.getId());
            row.createCell(1).setCellValue(contact.getName());
            row.createCell(2).setCellValue(contact.getPhoneNumber());
        }

        // Auto-size columns
        for (int i = 0; i < 3; i++) {
            sheet.autoSizeColumn(i);
        }

        // Write to byte array
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        workbook.write(outputStream);
        workbook.close();

        return outputStream.toByteArray();
    }

    // Add this method to your ExcelService class
    public byte[] generateAttendanceExcel(List<Contact> contacts) throws IOException {
        // Create a new workbook
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Attendance");

        // Create header row
        Row headerRow = sheet.createRow(0);

        // Create header cell style
        CellStyle headerStyle = workbook.createCellStyle();
        headerStyle.setFillForegroundColor(IndexedColors.BLUE.getIndex());
        headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

        Font headerFont = workbook.createFont();
        headerFont.setColor(IndexedColors.WHITE.getIndex());
        headerFont.setBold(true);
        headerStyle.setFont(headerFont);

        // Create headers
        Cell nameHeader = headerRow.createCell(0);
        nameHeader.setCellValue("Name");
        nameHeader.setCellStyle(headerStyle);

        Cell phoneHeader = headerRow.createCell(1);
        phoneHeader.setCellValue("Phone Number");
        phoneHeader.setCellStyle(headerStyle);

        Cell attendanceHeader = headerRow.createCell(2);
        attendanceHeader.setCellValue("Attendance Status");
        attendanceHeader.setCellStyle(headerStyle);

        // Add data rows
        int rowNum = 1;
        for (Contact contact : contacts) {
            Row row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(contact.getName() != null ? contact.getName() : "");
            row.createCell(1).setCellValue(contact.getPhoneNumber() != null ? contact.getPhoneNumber() : "");
            row.createCell(2).setCellValue("Absent"); // Default status
        }

        // Resize columns to fit content
        for (int i = 0; i < 3; i++) {
            sheet.autoSizeColumn(i);
        }

        // Write to ByteArrayOutputStream
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        workbook.write(outputStream);
        workbook.close();

        return outputStream.toByteArray();
    }
}