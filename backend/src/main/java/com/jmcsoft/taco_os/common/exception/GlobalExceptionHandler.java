package com.jmcsoft.taco_os.common.exception;

import com.fasterxml.jackson.databind.exc.InvalidFormatException;
import com.jmcsoft.taco_os.common.dto.DatosError;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<Map<String, Object>> manejarJsonInvalido(HttpMessageNotReadableException ex) {
        Throwable causa = ex.getCause();
        Map<String, Object> body = new HashMap<>();
        body.put("error", "JSON inválido");

        if (causa instanceof InvalidFormatException ife) {
            body.put("campo", ife.getPath().get(0).getFieldName());
            body.put("valor", ife.getValue());
            body.put("mensaje", "El formato del valor no es correcto para este campo.");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(body);
        }

        String mensaje = (ex.getMessage() != null && ex.getMessage().contains("Required request body is missing"))
                ? "El cuerpo de la solicitud es obligatorio y no fue enviado."
                : "Error al procesar el JSON. Verifica la sintaxis.";
        body.put("mensaje", mensaje);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(body);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<Map<String, Object>> manejarIntegridad(DataIntegrityViolationException ex) {
        String mensaje = ex.getMessage() != null && ex.getMessage().contains("NULL not allowed")
                ? "Falta un campo obligatorio en la base de datos."
                : "Violación de integridad de datos.";
        return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of(
                "error", "ERROR_DE_INTEGRIDAD",
                "mensaje", mensaje,
                "detalle", ex.getMostSpecificCause().getMessage()
        ));
    }

    @ExceptionHandler(DuplicadoException.class)
    public ResponseEntity<Map<String, Object>> manejarDuplicado(DuplicadoException ex) {
        return ResponseEntity.status(ex.getStatusHttp()).body(Map.of(
                "error", ex.getCodigo(),
                "mensaje", ex.getMensaje(),
                "ubicacion", ex.getUbicacion()
        ));
    }

    @ExceptionHandler(YaExisteException.class)
    public ResponseEntity<Map<String, Object>> manejarYaExiste(YaExisteException ex) {
        return ResponseEntity.status(ex.getStatusHttp()).body(Map.of(
                "error", ex.getCodigo(),
                "mensaje", ex.getMensaje(),
                "ubicacion", ex.getUbicacion()
        ));
    }

    @ExceptionHandler(YaRegistradoException.class)
    public ResponseEntity<Map<String, Object>> manejarYaRegistrado(YaRegistradoException ex) {
        return ResponseEntity.status(ex.getStatusHttp()).body(Map.of(
                "error", ex.getCodigo(),
                "mensaje", ex.getMensaje(),
                "ubicacion", ex.getUbicacion()
        ));
    }

    @ExceptionHandler(NoExisteException.class)
    public ResponseEntity<Map<String, Object>> manejarNoExiste(NoExisteException ex) {
        return ResponseEntity.status(ex.getStatusHttp()).body(Map.of(
                "error", ex.getCodigo(),
                "mensaje", ex.getMensaje(),
                "ubicacion", ex.getUbicacion()
        ));
    }

    @ExceptionHandler(NoAutorizadoException.class)
    public ResponseEntity<Map<String, Object>> manejarNoAutorizado(NoAutorizadoException ex) {
        return ResponseEntity.status(ex.getStatusHttp()).body(Map.of(
                "error", ex.getCodigo(),
                "mensaje", ex.getMensaje(),
                "ubicacion", ex.getUbicacion()
        ));
    }

    @ExceptionHandler(NoAutenticadoException.class)
    public ResponseEntity<Map<String, Object>> manejarNoAutenticado(NoAutenticadoException ex) {
        return ResponseEntity.status(ex.getStatusHttp()).body(Map.of(
                "error", ex.getCodigo(),
                "mensaje", ex.getMensaje(),
                "ubicacion", ex.getUbicacion()
        ));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, Object>> manejarArgumentoInvalido(IllegalArgumentException ex) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                "error", "ARGUMENTO_INVALIDO",
                "mensaje", ex.getMessage()
        ));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> manejarValidacion(MethodArgumentNotValidException ex) {
        Map<String, String> errores = new HashMap<>();
        ex.getBindingResult().getFieldErrors()
                .forEach(error -> errores.put(error.getField(), error.getDefaultMessage()));
        return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(Map.of(
                "error", "VALIDACION_FALLIDA",
                "campos", errores
        ));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> manejarErrorGeneral(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                "error", "ERROR_INTERNO",
                "mensaje", "Ocurrió un error inesperado. Intenta de nuevo.",
                "tipo", ex.getClass().getSimpleName()
        ));
    }
}
