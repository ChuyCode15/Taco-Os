package com.jmcsoft.taco_os.common.exception;

import com.jmcsoft.taco_os.common.dto.DatosError;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(DuplicadoException.class)
    public ResponseEntity<DatosError> manejarDuplicado(DuplicadoException ex) {
        var error = new DatosError(ex.getCodigo(), ex.getMensaje(), ex.getUbicacion(), ex.getStatusHttp());
        return ResponseEntity.status(ex.getStatusHttp()).body(error);
    }

    @ExceptionHandler(YaExisteException.class)
    public ResponseEntity<DatosError> manejarYaExiste(YaExisteException ex) {
        var error = new DatosError(ex.getCodigo(), ex.getMensaje(), ex.getUbicacion(), ex.getStatusHttp());
        return ResponseEntity.status(ex.getStatusHttp()).body(error);
    }

    @ExceptionHandler(YaRegistradoException.class)
    public ResponseEntity<DatosError> manejarYaRegistrado(YaRegistradoException ex) {
        var error = new DatosError(ex.getCodigo(), ex.getMensaje(), ex.getUbicacion(), ex.getStatusHttp());
        return ResponseEntity.status(ex.getStatusHttp()).body(error);
    }

    @ExceptionHandler(NoExisteException.class)
    public ResponseEntity<DatosError> manejarNoExiste(NoExisteException ex) {
        var error = new DatosError(ex.getCodigo(), ex.getMensaje(), ex.getUbicacion(), ex.getStatusHttp());
        return ResponseEntity.status(ex.getStatusHttp()).body(error);
    }

    @ExceptionHandler(NoAutorizadoException.class)
    public ResponseEntity<DatosError> manejarNoAutorizado(NoAutorizadoException ex) {
        var error = new DatosError(ex.getCodigo(), ex.getMensaje(), ex.getUbicacion(), ex.getStatusHttp());
        return ResponseEntity.status(ex.getStatusHttp()).body(error);
    }

    @ExceptionHandler(NoAutenticadoException.class)
    public ResponseEntity<DatosError> manejarNoAutenticado(NoAutenticadoException ex) {
        var error = new DatosError(ex.getCodigo(), ex.getMensaje(), ex.getUbicacion(), ex.getStatusHttp());
        return ResponseEntity.status(ex.getStatusHttp()).body(error);
    }
}
