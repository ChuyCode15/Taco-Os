package com.jmcsoft.taco_os.common.exception;

public class NoExisteException extends RuntimeException {

    private final String codigo;
    private final String mensaje;
    private final String ubicacion;
    private final Integer statusHttp;

    public NoExisteException(String mensaje, String ubicacion) {
        this.codigo = "NO_EXISTE";
        this.mensaje = mensaje;
        this.ubicacion = ubicacion;
        this.statusHttp = 404;
    }

    public String getCodigo() { return codigo; }
    public String getMensaje() { return mensaje; }
    public String getUbicacion() { return ubicacion; }
    public Integer getStatusHttp() { return statusHttp; }
}
