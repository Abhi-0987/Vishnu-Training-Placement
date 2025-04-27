package com.bvrit.vtp.controller;

import com.bvrit.vtp.exception.AttendanceAlreadyMarkedException;
import com.bvrit.vtp.exception.AttendanceRecordNotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(AttendanceAlreadyMarkedException.class)
    public ResponseEntity<String> handleAttendanceAlreadyMarked(AttendanceAlreadyMarkedException ex) {
        return new ResponseEntity<>(ex.getMessage(), HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(AttendanceRecordNotFoundException.class)
    public ResponseEntity<String> handleAttendanceRecordNotFound(AttendanceRecordNotFoundException ex) {
        return new ResponseEntity<>(ex.getMessage(), HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleGenericException(Exception ex) {
        return new ResponseEntity<>("An unexpected error occurred: " + ex.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
