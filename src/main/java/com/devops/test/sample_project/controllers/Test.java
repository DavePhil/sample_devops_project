package com.devops.test.sample_project.controllers;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Test {

    @GetMapping("/hello")
    String helloWorld() {
        return "hello world Dave";
    }
}
