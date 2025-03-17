package com.bvrit.vtp.controller;

import com.bvrit.vtp.model.Student;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api")
public class StudentController {
    List<Student> students = new ArrayList<>(List.of(
            new Student(1, "Akshaya", "Java"),
            new Student(2, "Aishu", "Blockchain")
    ));
    @GetMapping("/csrf-token")
    public CsrfToken getCsrfToken(HttpServletRequest request){
        return (CsrfToken) request.getAttribute("_csrf");
    }
    @GetMapping("/students")
    public List<Student> getStudents(){
        return students;
    }
    @PostMapping("/students")
    public void addStudent(@RequestBody Student student){
        students.add(student);
    }
}
