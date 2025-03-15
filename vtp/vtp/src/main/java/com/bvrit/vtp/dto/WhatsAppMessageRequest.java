package com.bvrit.vtp.dto;



import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

    @Data
    public class WhatsAppMessageRequest {
        private String message;
        private MultipartFile excelFile;
    }

