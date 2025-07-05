package com.bvrit.vtp.controller;

import com.bvrit.vtp.projections.AbsentStudentPhoneProjection;
import com.bvrit.vtp.service.ExcelService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;


@RestController
@RequestMapping("/api/excel")
public class ExcelExportController {

    @Autowired
    private ExcelService excelService;

    // Endpoint: GET /api/excel/absentees/{date}
    @GetMapping(value="/absentees/by-date/{date}", produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
    public ResponseEntity<byte[]> generateAbsentStudentsExcel(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {

        try {
            byte[] excelBytes = excelService.generateAbsentStudentsExcel(date);

            String filename = "Absent_Students_" + date + ".xlsx";


            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + filename)
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .body(excelBytes);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping(value="/absentees/json/{date}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<String>> getAbsentStudentPhoneNumbers(@PathVariable String date) {
        LocalDate localDate = LocalDate.parse(date);
        List<String> phoneNumbers = excelService.getAbsentStudentPhoneNumbers(localDate);
        return ResponseEntity.ok(phoneNumbers);
    }

    @GetMapping(value = "/absentees/json/bySchedule/{scheduleId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<String>> getAbsentStudentPhoneNumbersByScheduleId(@PathVariable Long scheduleId) {
        List<String> phoneNumbers = excelService.getAbsentStudentPhoneNumbersByScheduleId(scheduleId);
        return ResponseEntity.ok(phoneNumbers);
    }

    @GetMapping(value="/absentees/by-schedule/{scheduleId}",produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
    public ResponseEntity<byte[]> downloadAbsentStudentsExcel(
            @PathVariable Long scheduleId) {
        try {
            byte[] excelData = excelService.generateAbsentStudentsExcelByScheduleId(scheduleId);



            String filename = "Absent_Students_" + scheduleId + ".xlsx";

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + filename)
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .body(excelData);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }




}
