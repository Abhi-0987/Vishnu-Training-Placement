package com.bvrit.vtp.controller;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

@RestController
//@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")


public class AuthChekGet {

    @GetMapping("/check")
    public String Hello(){
        return "It is successfull";
    }
}
