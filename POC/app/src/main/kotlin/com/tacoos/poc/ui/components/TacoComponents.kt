package com.tacoos.poc.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.DialogProperties
import com.tacoos.poc.ui.theme.ActionBlue

/**
 * TacoDialog: Componente base para diálogos con diseño consistente y altura dinámica.
 * Implementa las reglas de altura (30% min - 90% max).
 * 
 * @param title Título del diálogo.
 * @param onDismiss Acción al cerrar el diálogo.
 * @param navigationIcon Icono opcional a la izquierda del título.
 * @param onNavigationClick Acción del icono de navegación.
 * @param minHeightFactor Porcentaje mínimo de altura de pantalla.
 * @param maxHeightFactor Porcentaje máximo de altura de pantalla.
 * @param confirmButton Botón de confirmación opcional en el footer.
 * @param dismissButton Botón de cancelación opcional en el footer.
 * @param content Contenido interno del diálogo.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TacoDialog(
    title: String,
    onDismiss: () -> Unit,
    navigationIcon: ImageVector? = null,
    onNavigationClick: (() -> Unit)? = null,
    minHeightFactor: Float = 0.3f,
    maxHeightFactor: Float = 0.9f,
    headerAction: @Composable (() -> Unit)? = null,
    confirmButton: @Composable (() -> Unit)? = null,
    dismissButton: @Composable (() -> Unit)? = null,
    content: @Composable ColumnScope.() -> Unit
) {
    val screenHeight = LocalConfiguration.current.screenHeightDp.dp
    
    AlertDialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false),
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = screenHeight * minHeightFactor, max = screenHeight * maxHeightFactor)
            .padding(16.dp),
        content = {
            Surface(
                modifier = Modifier.fillMaxSize(),
                shape = RoundedCornerShape(28.dp),
                color = MaterialTheme.colorScheme.surface,
                tonalElevation = 6.dp
            ) {
                Column(modifier = Modifier.padding(24.dp)) {
                    // Header del Diálogo
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        if (navigationIcon != null) {
                            IconButton(onClick = { onNavigationClick?.invoke() }) {
                                Icon(navigationIcon, contentDescription = null)
                            }
                        }
                        Text(
                            text = title,
                            style = MaterialTheme.typography.titleLarge,
                            fontWeight = FontWeight.Black,
                            modifier = Modifier.weight(1f)
                        )
                        headerAction?.invoke()
                        IconButton(onClick = onDismiss) {
                            Icon(Icons.Default.Close, contentDescription = "Cerrar")
                        }
                    }
                    
                    Spacer(Modifier.height(16.dp))
                    
                    // Contenido Scrolleable/Dinámico
                    Box(modifier = Modifier.weight(1f)) {
                        Column { content() }
                    }
                    
                    // Footer del Diálogo
                    if (confirmButton != null || dismissButton != null) {
                        Spacer(Modifier.height(24.dp))
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.End,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            dismissButton?.invoke()
                            if (confirmButton != null && dismissButton != null) Spacer(Modifier.width(8.dp))
                            confirmButton?.invoke()
                        }
                    }
                }
            }
        }
    )
}

/**
 * AppleToggle: Interruptor ovalado personalizado con estética iOS.
 */
@Composable
fun AppleToggle(checked: Boolean, onCheckedChange: (Boolean) -> Unit) {
    val thumbOffset by animateDpAsState(if (checked) 22.dp else 2.dp, label = "toggle")
    val bgColor by animateColorAsState(if (checked) ActionBlue else Color.LightGray, label = "toggleBg")

    Box(
        modifier = Modifier
            .width(50.dp)
            .height(30.dp)
            .clip(CircleShape)
            .background(bgColor)
            .clickable { onCheckedChange(!checked) }
            .padding(4.dp),
        contentAlignment = Alignment.CenterStart
    ) {
        Box(
            modifier = Modifier
                .offset(x = thumbOffset)
                .size(22.dp)
                .clip(CircleShape)
                .background(Color.White)
        )
    }
}

/**
 * ActionButton: Botón circular estilizado para acciones rápidas.
 */
@Composable
fun ActionButton(
    icon: ImageVector,
    label: String,
    color: Color,
    onClick: () -> Unit
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier = Modifier
                .size(56.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(color.copy(alpha = 0.1f))
                .clickable { onClick() },
            contentAlignment = Alignment.Center
        ) {
            Icon(icon, null, tint = color)
        }
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            fontWeight = FontWeight.Bold,
            color = Color(0xFF212121)
        )
    }
}

/**
 * ReportRow: Fila utilitaria para mostrar etiquetas y valores.
 */
@Composable
fun ReportRow(
    label: String,
    value: String,
    isBold: Boolean = true,
    color: Color = Color.Unspecified
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(label, color = Color.Gray)
        Text(
            text = value,
            fontWeight = if (isBold) FontWeight.Bold else FontWeight.Normal,
            color = color
        )
    }
}
