package com.jmcsoft.taco_os.domain.transaccion;

import com.jmcsoft.taco_os.common.enums.EstadoTransaccion;
import com.jmcsoft.taco_os.common.enums.MetodoPago;
import com.jmcsoft.taco_os.common.enums.TipoTransaccion;
import com.jmcsoft.taco_os.domain.cajero.Cajero;
import com.jmcsoft.taco_os.domain.negocio.Negocio;
import com.jmcsoft.taco_os.domain.sesioncajero.CashierSession;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Table(name = "transactions")
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Transaccion {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "business_id", nullable = false)
    private Negocio negocio;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private CashierSession sesion;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private TipoTransaccion tipo;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cashier_id", nullable = false)
    private Cajero cajero;

    @Column(name = "device_id")
    private String dispositivoId;

    @Column(name = "items_json", columnDefinition = "TEXT")
    private String itemsJson;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_method")
    private MetodoPago metodoPago;

    @Column(name = "amount_received", precision = 10, scale = 2)
    private BigDecimal montoRecibido;

    @Column(name = "change_amount", precision = 10, scale = 2)
    private BigDecimal cambio;

    @Column(name = "card_photo_url")
    private String fotoBaucher;

    @Column(name = "total", nullable = false, precision = 10, scale = 2)
    private BigDecimal total;

    @Column(name = "description")
    private String descripcion;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private EstadoTransaccion estado = EstadoTransaccion.COMPLETADA;

    @Column(name = "timestamp", nullable = false, updatable = false)
    private LocalDateTime marcaTiempo;

    @Column(name = "is_synced", nullable = false)
    private Boolean sincronizado = false;

    @PrePersist
    protected void onCreate() {
        marcaTiempo = LocalDateTime.now();
    }
}
