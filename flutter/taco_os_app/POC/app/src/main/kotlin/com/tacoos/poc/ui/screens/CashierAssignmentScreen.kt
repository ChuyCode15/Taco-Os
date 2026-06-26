package com.tacoos.poc.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.tacoos.poc.ui.theme.ActionBlue

@Composable
fun CashierAssignmentScreen(navController: NavController) {
    Surface(
        color = MaterialTheme.colorScheme.background,
        modifier = Modifier.fillMaxSize()
    ) {
        Column(
            modifier = Modifier.fillMaxSize().padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(40.dp))
            
            Text(
                text = "Asignación de Caja",
                style = MaterialTheme.typography.headlineSmall.copy(fontWeight = FontWeight.Bold)
            )
            Text(
                text = "Conéctate con tu administrador",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f)
            )

            Spacer(modifier = Modifier.height(60.dp))

            AssignmentOption(
                icon = Icons.Default.Lock,
                title = "Código de Enlace",
                subtitle = "Ingresa el código manual",
                onClick = { /* Abrir diálogo código */ }
            )

            Spacer(modifier = Modifier.height(16.dp))

            AssignmentOption(
                icon = Icons.Default.Add,
                title = "Escanear QR",
                subtitle = "Usa la cámara del celular",
                onClick = { /* Abrir Cámara */ }
            )

            Spacer(modifier = Modifier.height(16.dp))

            AssignmentOption(
                icon = Icons.Default.Notifications,
                title = "Notificar al Patrón",
                subtitle = "Envía una alerta de espera",
                onClick = { /* Lógica alerta */ }
            )
            
            Spacer(modifier = Modifier.weight(1f))
            
            TextButton(onClick = { navController.popBackStack() }) {
                Text("REGRESAR", color = ActionBlue, fontWeight = FontWeight.Bold)
            }
        }
    }
}

@Composable
fun AssignmentOption(icon: ImageVector, title: String, subtitle: String, onClick: () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth().height(90.dp).clickable { onClick() },
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxSize().padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = ActionBlue,
                modifier = Modifier.size(32.dp)
            )
            Spacer(modifier = Modifier.width(20.dp))
            Column {
                Text(text = title, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                Text(text = subtitle, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f))
            }
        }
    }
}
