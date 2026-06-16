package com.jmcsoft.taco_os.common.exception;

public class NoAutenticadoException extends RuntimeException {

    private final String codigo;
    private final String mensaje;
    private final String ubicacion;
    private final Integer statusHttp;

    public NoAutenticadoException(String mensaje, String ubicacion) {
        this.codigo = "NO_AUTENTICADO";
        this.mensaje = mensaje;
        this.ubicacion = ubicacion;
        this.statusHttp = 401;
    }

    public String getCodigo() { return codigo; }
    public String getMensaje() { return mensaje; }
    public String getUbicacion() { return ubicacion; }
    public Integer getStatusHttp() { return statusHttp; }
}
