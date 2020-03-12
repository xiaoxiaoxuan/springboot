package com.hmx.jenkins.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author xiaoxuan
 * @version 1.0
 * @date 2020/3/12 8:48 上午
 */
@RestController
@RequestMapping("/demo")
public class DemoController {

    @GetMapping("/index")
    @ResponseBody
    public String index(){
        return "jenkins test";
    }

}
