package com.bvrit.vtp.config;
import com.twilio.Twilio;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.PropertySource;

@Configuration
@PropertySource("classpath:application.properties")
public class TwilioConfig {
    private final Logger logger = LoggerFactory.getLogger(TwilioConfig.class);

    @Value("${twilio.account.sid:}")
    private String accountSid;

    @Value("${twilio.auth.token:}")
    private String authToken;

    @Value("${twilio.whatsapp.number:}")
    private String whatsappNumber;

    @PostConstruct
    public void initTwilio() {
        if (accountSid.isEmpty() || authToken.isEmpty()) {
            logger.warn("Twilio credentials not found in application.properties");
            return;
        }
        logger.info("Initializing Twilio with account SID: {}", accountSid);
        Twilio.init(accountSid, authToken);
        logger.info("Twilio initialized successfully");
    }

    public String getWhatsappNumber() {
        if (whatsappNumber.isEmpty()) {
            logger.warn("WhatsApp number not configured");
            return "";
        }
        return whatsappNumber;
    }
}