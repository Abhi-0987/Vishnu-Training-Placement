package com.bvrit.vtp.exception;

public class AttendanceAlreadyMarkedException extends RuntimeException {
    public AttendanceAlreadyMarkedException(String message) {
        super(message);
    }
}