package com.bvrit.vtp.service;

import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Service
public class WhatsAppService {

    private static final String TWILIO_WHATSAPP_NUMBER = "whatsapp:+14155238886"; // Replace with your Twilio WhatsApp number

    public List<String> sendWhatsAppMessages(String messageContent, MultipartFile excelFile) {
        List<String> results = new ArrayList<>();
        List<String> phoneNumbers = readPhoneNumbersFromExcel(excelFile);

        for (String phoneNumber : phoneNumbers) {
            try {
                Message message = Message.creator(
                        new PhoneNumber("whatsapp:" + phoneNumber),
                        new PhoneNumber(TWILIO_WHATSAPP_NUMBER),
                        messageContent
                ).create();

                results.add("Message sent successfully to " + phoneNumber + ". SID: " + message.getSid());
            } catch (Exception e) {
                results.add("Failed to send message to " + phoneNumber + ". Error: " + e.getMessage());
            }
        }

        return results;
    }

    private List<String> readPhoneNumbersFromExcel(MultipartFile file) {
        List<String> phoneNumbers = new ArrayList<>();
        try (Workbook workbook = new XSSFWorkbook(file.getInputStream())) {
            Sheet sheet = workbook.getSheetAt(0);
            for (Row row : sheet) {
                // Assuming phone numbers are in the first column
                String phoneNumber = row.getCell(0).getStringCellValue();
                // Skip header row if it exists
                if (!phoneNumber.equals("Phone Number") && !phoneNumber.isEmpty()) {
                    phoneNumbers.add(phoneNumber);
                }
            }
        } catch (IOException e) {
            throw new RuntimeException("Failed to read Excel file: " + e.getMessage());
        }
        return phoneNumbers;
    }
}