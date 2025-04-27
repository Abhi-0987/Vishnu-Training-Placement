package com.bvrit.vtp.exception;

public class AttendanceRecordNotFoundException extends RuntimeException {
    public AttendanceRecordNotFoundException(String message) {
        super(message);
    }
}