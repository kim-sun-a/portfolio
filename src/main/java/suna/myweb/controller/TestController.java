package suna.myweb.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
@Slf4j
public class TestController {
    @GetMapping("/")
    public String test(Model model) {
        model.addAttribute("data", "ok");
        return "main/index";
    }
}
