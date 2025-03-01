package com.bvrit.vtp.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

@RestController
public class HomeController {
    private final Logger logger = LoggerFactory.getLogger(HomeController.class);

    @GetMapping("/")
    public Map<String, String> home() {
        logger.info("Home endpoint called");
        Map<String, String> response = new HashMap<>();
        response.put("status", "running");
        response.put("message", "WhatsApp Bulk Messaging API is active");
        response.put("endpoints", "/api/whatsapp/send - POST endpoint for sending messages");
        return response;
    }
}