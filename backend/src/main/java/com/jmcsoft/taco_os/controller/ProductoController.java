package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.domain.producto.dto.DatosDetalleProducto;
import com.jmcsoft.taco_os.domain.producto.dto.DatosRegistroProducto;
import com.jmcsoft.taco_os.services.ProductoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;

@RestController
@RequestMapping("/api/v1/business/{negocioId}/products")
@RequiredArgsConstructor
public class ProductoController {

    private final ProductoService productoService;

    @PostMapping
    public ResponseEntity<DatosDetalleProducto> registrarProducto(
            @PathVariable String negocioId,
            @RequestBody DatosRegistroProducto datos,
            UriComponentsBuilder ucb) {
        var producto = productoService.registrarProducto(negocioId, datos);
        var uri = ucb.path("/api/v1/business/{negocioId}/products/{id}")
                .buildAndExpand(negocioId, producto.id()).toUri();
        return ResponseEntity.created(uri).body(producto);
    }

    @GetMapping
    public ResponseEntity<List<DatosDetalleProducto>> listarProductos(
            @PathVariable String negocioId,
            @RequestParam(required = false) String category) {
        if (category != null) {
            return ResponseEntity.ok(productoService.listarPorCategoria(negocioId, category));
        }
        return ResponseEntity.ok(productoService.listarProductos(negocioId));
    }

    @PutMapping("/{productoId}")
    public ResponseEntity<DatosDetalleProducto> editarProducto(
            @PathVariable String negocioId,
            @PathVariable String productoId,
            @RequestBody DatosRegistroProducto datos) {
        var producto = productoService.editarProducto(negocioId, productoId, datos);
        return ResponseEntity.ok(producto);
    }

    @DeleteMapping("/{productoId}")
    public ResponseEntity<Void> eliminarProducto(
            @PathVariable String negocioId,
            @PathVariable String productoId) {
        productoService.eliminarProducto(negocioId, productoId);
        return ResponseEntity.noContent().build();
    }
}
