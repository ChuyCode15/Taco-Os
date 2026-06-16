package com.jmcsoft.taco_os.controller;

import com.jmcsoft.taco_os.domain.producto.dto.DatosDetalleProducto;
import com.jmcsoft.taco_os.domain.producto.dto.DatosRegistroProducto;
import com.jmcsoft.taco_os.services.ProductoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;


@RestController
@RequestMapping("/products")
@RequiredArgsConstructor
public class ProductoController {

    private final ProductoService productoService;

    @PostMapping
    public ResponseEntity<DatosDetalleProducto> registrarProducto(@RequestBody DatosRegistroProducto datos, UriComponentsBuilder ucb){
        var producto = productoService.registrarProducto(datos);
        var uri = ucb.path("/producto/{id}").buildAndExpand(producto.id()).toUri();
        return ResponseEntity.created(uri).body(producto);
    }

}
