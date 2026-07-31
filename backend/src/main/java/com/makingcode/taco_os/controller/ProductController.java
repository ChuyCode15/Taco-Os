package com.makingcode.taco_os.controller;

import com.makingcode.taco_os.domain.Product;
import com.makingcode.taco_os.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/business/{businessId}/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductRepository productRepository;

    @GetMapping
    public ResponseEntity<List<Product>> listProducts(@PathVariable UUID businessId) {
        return ResponseEntity.ok(productRepository.findByBusinessId(businessId));
    }

    @PostMapping
    public ResponseEntity<Product> createProduct(
            @PathVariable UUID businessId,
            @RequestBody Product product) {
        product.setBusinessId(businessId);
        product.setIsSynced(false);
        return ResponseEntity.ok(productRepository.save(product));
    }
}
