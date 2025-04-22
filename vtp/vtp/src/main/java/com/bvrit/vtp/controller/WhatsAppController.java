package com.bvrit.vtp.controller;


import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import com.bvrit.vtp.config.TwilioConfig;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.util.*;

@RestController
@RequestMapping(value = "/api/whatsapp", produces = MediaType.APPLICATION_JSON_VALUE)
public class WhatsAppController {
    private final Logger logger = LoggerFactory.getLogger(WhatsAppController.class);
    private final TwilioConfig twilioConfig;
    private final Set<String> phoneNumbers = new HashSet<>();

    @Autowired
    public WhatsAppController(TwilioConfig twilioConfig) {
        this.twilioConfig = twilioConfig;
    }

    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> uploadFile(@RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().body(Collections.singletonMap(
                        "error", "Please select a file to upload"
                ));
            }

            if (!file.getOriginalFilename().endsWith(".xlsx")) {
                return ResponseEntity.badRequest().body(Collections.singletonMap(
                        "error", "Please upload an Excel (.xlsx) file"
                ));
            }

            phoneNumbers.clear();
            int count = 0;

            try (Workbook workbook = new XSSFWorkbook(file.getInputStream())) {
                Sheet sheet = workbook.getSheetAt(0);
                boolean isFirstRow = true;

                for (Row row : sheet) {
                    if (isFirstRow) {
                        isFirstRow = false;
                        continue;
                    }

                    Cell cell = row.getCell(0);
                    if (cell != null) {
                        String phoneNumber;

                        try {
                            switch (cell.getCellType()) {
                                case NUMERIC:
                                    phoneNumber = String.valueOf((long) cell.getNumericCellValue());
                                    break;
                                case STRING:
                                    phoneNumber = cell.getStringCellValue().trim();
                                    break;
                                default:
                                    continue;
                            }

                            if (phoneNumber.matches("\\d+")) {
                                if (!phoneNumber.startsWith("+")) {
                                    phoneNumber = "+" + phoneNumber;
                                }
                                phoneNumbers.add(phoneNumber);
                                count++;
                            }
                        } catch (Exception e) {
                            logger.warn("Error processing row {}: {}", row.getRowNum(), e.getMessage());
                        }
                    }
                }
            }

            logger.info("Successfully loaded {} phone numbers", count);
            Map<String, Object> response = new HashMap<>();
            response.put("message", "File uploaded successfully");
            response.put("count", count);
            response.put("numbers", new ArrayList<>(phoneNumbers));

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Error uploading file", e);
            return ResponseEntity.badRequest().body(Collections.singletonMap(
                    "error", "Failed to upload file: " + e.getMessage()
            ));
        }
    }

    @PostMapping(value = "/send", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> sendMessage(@RequestBody Map<String, String> request, @RequestHeader(value = "Authorization", required = false) String authHeader) {
        try {
            // Check authorization
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                logger.error("Missing or invalid authorization header");
                return ResponseEntity.status(403).body(Collections.singletonMap(
                        "error", "Authorization required"
                ));
            }
            
            // Extract token - in a real app, you would validate this token
            String token = authHeader.substring(7);
            
            String whatsappNumber = twilioConfig.getWhatsappNumber();
            if (whatsappNumber.isEmpty()) {
                logger.error("WhatsApp number not configured");
                return ResponseEntity.badRequest().body(Collections.singletonMap(
                        "error", "WhatsApp number not configured"
                ));
            }

            String phoneNumber = request.get("phone");
            String messageText = request.get("message");

            if (phoneNumber == null || messageText == null) {
                logger.error("Missing required parameters");
                return ResponseEntity.badRequest().body(Collections.singletonMap(
                        "error", "Phone number and message are required"
                ));
            }

            // Ensure phone number format
            if (!phoneNumber.startsWith("+")) {
                phoneNumber = "+" + phoneNumber;
            }

            logger.info("Sending message to {}", phoneNumber);

            try {
                Message message = Message.creator(
                        new PhoneNumber("whatsapp:" + phoneNumber),
                        new PhoneNumber("whatsapp:" + whatsappNumber),
                        messageText
                ).create();

                logger.info("Message sent successfully to {}, SID: {}", phoneNumber, message.getSid());

                Map<String, String> response = new HashMap<>();
                response.put("status", "success");
                response.put("messageSid", message.getSid());
                response.put("to", phoneNumber);
                return ResponseEntity.ok(response);

            } catch (Exception e) {
                logger.error("Error sending message to {}: {}", phoneNumber, e.getMessage());
                return ResponseEntity.badRequest().body(Collections.singletonMap(
                        "error", "Failed to send message: " + e.getMessage()
                ));
            }
        } catch (Exception e) {
            logger.error("Error in send endpoint", e);
            return ResponseEntity.badRequest().body(Collections.singletonMap(
                    "error", "Internal server error: " + e.getMessage()
            ));
        }
    }

    @GetMapping("/numbers")
    public ResponseEntity<?> getPhoneNumbers() {
        Map<String, Object> response = new HashMap<>();
        response.put("count", phoneNumbers.size());
        response.put("numbers", new ArrayList<>(phoneNumbers));
        return ResponseEntity.ok(response);
    }
}