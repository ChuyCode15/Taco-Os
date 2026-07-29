package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.domain.producto.dto.DatosDetalleProducto;
import com.jmcsoft.taco_os.domain.producto.dto.DatosRegistroProducto;
import com.jmcsoft.taco_os.services.ProductoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

@RestController
@RequestMapping("/api/v1/business/{negocioId}/products")
@RequiredArgsConstructor
@Tag(name = "Productos", description = "CRUD de productos del negocio")
public class ProductoController {

    private final ProductoService productoService;

    @PostMapping
    @Operation(summary = "Crear un producto nuevo")
    public ResponseEntity<DatosDetalleProducto> crear(
            @PathVariable String negocioId,
            @RequestBody @Valid DatosRegistroProducto datos,
            UriComponentsBuilder ucb) {
        var producto = productoService.crear(negocioId, datos);
        var uri = ucb.path("/api/v1/business/{negocioId}/products/{id}")
                .buildAndExpand(negocioId, producto.id()).toUri();
        return ResponseEntity.created(uri).body(producto);
    }

    @GetMapping
    @Operation(summary = "Listar productos del negocio (con filtro por categoría opcional)")
    public ResponseEntity<Page<DatosDetalleProducto>> listar(
            @PathVariable String negocioId,
            @RequestParam(required = false) String category,
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(productoService.listar(negocioId, category, pageable));
    }

    @GetMapping("/{productoId}")
    @Operation(summary = "Obtener detalle de un producto")
    public ResponseEntity<DatosDetalleProducto> detalle(
            @PathVariable String negocioId,
            @PathVariable String productoId) {
        return ResponseEntity.ok(productoService.detalle(negocioId, productoId));
    }

    @PutMapping("/{productoId}")
    @Operation(summary = "Actualizar un producto existente")
    public ResponseEntity<DatosDetalleProducto> actualizar(
            @PathVariable String negocioId,
            @PathVariable String productoId,
            @RequestBody @Valid DatosRegistroProducto datos) {
        return ResponseEntity.ok(productoService.actualizar(negocioId, productoId, datos));
    }

    @DeleteMapping("/{productoId}")
    @Operation(summary = "Eliminar (soft delete) un producto")
    public ResponseEntity<Void> eliminar(
            @PathVariable String negocioId,
            @PathVariable String productoId) {
        productoService.eliminar(negocioId, productoId);
        return ResponseEntity.noContent().build();
    }

}
