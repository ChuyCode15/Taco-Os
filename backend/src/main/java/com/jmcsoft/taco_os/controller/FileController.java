package com.jmcsoft.taco_os.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/files")
@RequiredArgsConstructor
public class FileController {

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    @PostMapping("/upload")
    public ResponseEntity<Map<String, String>> uploadFile(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "type", defaultValue = "general") String type) throws IOException {

        var uploadPath = Paths.get(uploadDir, type);
        Files.createDirectories(uploadPath);

        var originalFilename = file.getOriginalFilename();
        var extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }

        var filename = UUID.randomUUID() + extension;
        var filePath = uploadPath.resolve(filename);
        file.transferTo(filePath.toFile());

        var fileUrl = "/api/v1/files/" + type + "/" + filename;
        return ResponseEntity.ok(Map.of("url", fileUrl, "filename", filename));
    }
}
