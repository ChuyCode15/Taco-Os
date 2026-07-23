package com.jmcsoft.taco_os.common.enums;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class EnumsTest {

    @Test
    @DisplayName("TipoPlan tiene los valores esperados")
    void tipoPlan_valoresCorrectos() {
        assertEquals(3, TipoPlan.values().length);
        assertNotNull(TipoPlan.FREE);
        assertNotNull(TipoPlan.PREMIUM);
        assertNotNull(TipoPlan.BUSINESS);
    }

    @Test
    @DisplayName("EstadoPlan tiene los valores esperados")
    void estadoPlan_valoresCorrectos() {
        assertEquals(5, EstadoPlan.values().length);
        assertNotNull(EstadoPlan.TRIAL_PREMIUM);
        assertNotNull(EstadoPlan.PAGADO);
        assertNotNull(EstadoPlan.VENCIDO);
        assertNotNull(EstadoPlan.SUSPENDIDO);
    }

    @Test
    @DisplayName("Categoria tiene los valores esperados")
    void categoria_valoresCorrectos() {
        assertEquals(3, Categoria.values().length);
        assertNotNull(Categoria.COMIDA);
        assertNotNull(Categoria.BEBIDAS);
        assertNotNull(Categoria.POSTRES);
    }

    @Test
    @DisplayName("EstadoSesion tiene los valores esperados")
    void estadoSesion_valoresCorrectos() {
        assertEquals(3, EstadoSesion.values().length);
        assertNotNull(EstadoSesion.ABIERTA);
        assertNotNull(EstadoSesion.CERRADA);
        assertNotNull(EstadoSesion.AUTO_CERRADA);
    }

    @Test
    @DisplayName("TipoTransaccion tiene los valores esperados")
    void tipoTransaccion_valoresCorrectos() {
        assertEquals(2, TipoTransaccion.values().length);
        assertNotNull(TipoTransaccion.VENTA);
        assertNotNull(TipoTransaccion.GASTO);
    }

    @Test
    @DisplayName("EstadoTransaccion tiene los valores esperados")
    void estadoTransaccion_valoresCorrectos() {
        assertEquals(2, EstadoTransaccion.values().length);
        assertNotNull(EstadoTransaccion.COMPLETADA);
        assertNotNull(EstadoTransaccion.CANCELADA);
    }

    @Test
    @DisplayName("MetodoPago tiene los valores esperados")
    void metodoPago_valoresCorrectos() {
        assertEquals(2, MetodoPago.values().length);
        assertNotNull(MetodoPago.EFECTIVO);
        assertNotNull(MetodoPago.TARJETA);
    }

    @Test
    @DisplayName("EstadoCorte tiene los valores esperados")
    void estadoCorte_valoresCorrectos() {
        assertEquals(4, EstadoCorte.values().length);
        assertNotNull(EstadoCorte.OK);
        assertNotNull(EstadoCorte.SOBRANTE);
        assertNotNull(EstadoCorte.FALTANTE);
        assertNotNull(EstadoCorte.AUTO_CERRADO);
    }

    @Test
    @DisplayName("TipoNotificacion tiene los valores esperados")
    void tipoNotificacion_valoresCorrectos() {
        assertEquals(3, TipoNotificacion.values().length);
        assertNotNull(TipoNotificacion.CANCELACION);
        assertNotNull(TipoNotificacion.DIFERENCIA_CORTE);
        assertNotNull(TipoNotificacion.AUTO_CIERRE);
    }

    @Test
    @DisplayName("valueOf con string correcto retorna el enum")
    void valueOf_stringCorrecto_retornaEnum() {
        assertEquals(TipoPlan.FREE, TipoPlan.valueOf("FREE"));
        assertEquals(EstadoSesion.ABIERTA, EstadoSesion.valueOf("ABIERTA"));
        assertEquals(MetodoPago.TARJETA, MetodoPago.valueOf("TARJETA"));
    }

    @Test
    @DisplayName("valueOf con string inválido lanza IllegalArgumentException")
    void valueOf_stringInvalido_lanzaExcepcion() {
        assertThrows(IllegalArgumentException.class, () -> TipoPlan.valueOf("INVALIDO"));
    }
}
