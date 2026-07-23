package com.jmcsoft.taco_os.common.exception;

public class YaRegistradoException extends RuntimeException {

    private final String codigo;
    private final String mensaje;
    private final String ubicacion;
    private final Integer statusHttp;

    public YaRegistradoException(String mensaje, String ubicacion) {
        this.codigo = "YA_REGISTRADO";
        this.mensaje = mensaje;
        this.ubicacion = ubicacion;
        this.statusHttp = 409;
    }

    public String getCodigo() { return codigo; }
    public String getMensaje() { return mensaje; }
    public String getUbicacion() { return ubicacion; }
    public Integer getStatusHttp() { return statusHttp; }
}
