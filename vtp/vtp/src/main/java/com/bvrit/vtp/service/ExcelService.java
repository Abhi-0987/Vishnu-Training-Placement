package com.bvrit.vtp.service;


import com.bvrit.vtp.dao.StudentAttendanceRepo;
import com.bvrit.vtp.projections.AbsentStudentPhoneProjection;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;


@Service
public class ExcelService {

    @Autowired
    private StudentAttendanceRepo studentAttendanceRepo;

    // Define the missing constants
    private static final String EXCEL_DIRECTORY = "excel_files";
    private static final String EXCEL_FILE_BASE_PATH = "contacts";
    private static final String EXCEL_FILE_PATH = EXCEL_DIRECTORY + File.separator + EXCEL_FILE_BASE_PATH + ".xlsx";


    /*public List<AbsentStudentPhoneProjection> getAbsentStudentsWithPhonesByDate(LocalDate date) {
        return studentAttendanceRepo.findAbsentStudentsWithPhoneByDate(date);
    }*/

    // Add the missing method for getting current file path with date-time
    private String getCurrentExcelFilePath() {
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss");
        String dateTime = now.format(formatter);
        return EXCEL_DIRECTORY + File.separator + EXCEL_FILE_BASE_PATH + "_" + dateTime + ".xlsx";
    }

    public List<String> getAbsentStudentPhoneNumbers(LocalDate date) {
        return studentAttendanceRepo.findAbsentStudentsWithPhoneByDate(date).stream()
                .map(student -> {
                    String phone = student.getParentsPhone();
                    if (phone != null) {
                        phone = phone.replaceAll(" ", "");
                        if (!phone.startsWith("+91")) {
                            phone = "+91" + phone;
                        }
                    }
                    return phone;
                })
                .filter(phone -> phone != null && !phone.isEmpty())
                .toList();
    }

    public byte[] generateAbsentStudentsExcel(LocalDate date) throws IOException {
        List<AbsentStudentPhoneProjection> absentees = studentAttendanceRepo.findAbsentStudentsWithPhoneByDate(date);

        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Absent Students " + date.format(DateTimeFormatter.ISO_LOCAL_DATE));

        Row headerRow = sheet.createRow(0);
        headerRow.createCell(0).setCellValue("Name");
        headerRow.createCell(1).setCellValue("Email");
        headerRow.createCell(2).setCellValue("Phone Number");

        int rowNum = 1;
        for (AbsentStudentPhoneProjection student : absentees) {
            Row row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(student.getName() != null ? student.getName() : "N/A");
            row.createCell(1).setCellValue(student.getEmail() != null ? student.getEmail() : "N/A");
            row.createCell(2).setCellValue(student.getParentsPhone() != null ? student.getParentsPhone() : "N/A");
        }

        for (int i = 0; i < 3; i++) {
            sheet.autoSizeColumn(i);
        }

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        workbook.write(outputStream);
        workbook.close();

        return outputStream.toByteArray();
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


    public byte[] generateAbsentStudentsExcelByScheduleId(Long scheduleId) throws IOException {
        List<AbsentStudentPhoneProjection> absentees =studentAttendanceRepo.findAbsentStudentsByScheduleId(scheduleId);;
        for (AbsentStudentPhoneProjection student : absentees) {
            System.out.println("Name: " + student.getName());
            System.out.println("Email: " + student.getEmail());
            System.out.println("Phone: " + student.getParentsPhone());
        }


        absentees = studentAttendanceRepo.findAbsentStudentsByScheduleId(scheduleId);

        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Absent Students");

        // Create header row
        Row headerRow = sheet.createRow(0);
        headerRow.createCell(0).setCellValue("Name");
        headerRow.createCell(1).setCellValue("Email");
        headerRow.createCell(2).setCellValue("Phone Number");

        // Fill data
        int rowNum = 1;
        for (AbsentStudentPhoneProjection student : absentees) {
            Row row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(student.getName());
            row.createCell(1).setCellValue(student.getEmail());
            row.createCell(2).setCellValue(student.getParentsPhone());
        }

        // Auto-size columns
        for (int i = 0; i < 3; i++) {
            sheet.autoSizeColumn(i);
        }

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        workbook.write(outputStream);
        workbook.close();

        return outputStream.toByteArray();
    }

    public List<String> getAbsentStudentPhoneNumbersByScheduleId(Long scheduleId) {
        List<AbsentStudentPhoneProjection> absentees =
                studentAttendanceRepo.findAbsentStudentsByScheduleId(scheduleId);

        return absentees.stream()
                .map(student -> {
                    String phone = student.getParentsPhone().replaceAll("\\s+", "");
                    if (!phone.startsWith("+91")) {
                        phone = "+91" + phone;
                    }
                    return phone;
                })
                .collect(Collectors.toList());
    }



}