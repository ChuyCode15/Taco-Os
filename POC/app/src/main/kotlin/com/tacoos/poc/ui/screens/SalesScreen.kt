package com.tacoos.poc.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.tacoos.poc.ui.theme.ActionBlue
import com.tacoos.poc.ui.theme.PrimaryNavy

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SalesScreen(navController: NavController) {
    var isShiftStarted by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("VENTAS", fontWeight = FontWeight.Black) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Regresar")
                    }
                },
                actions = {
                    IconButton(onClick = { /* Notificaciones */ }) {
                        Icon(Icons.Default.Notifications, null)
                    }
                }
            )
        },
        bottomBar = {
            Box(modifier = Modifier.fillMaxWidth().padding(16.dp), contentAlignment = Alignment.Center) {
                Text("Taco'Os POS v1.0", style = MaterialTheme.typography.labelSmall, color = Color.Gray)
            }
        }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding),
            contentAlignment = Alignment.Center
        ) {
            if (!isShiftStarted) {
                // Vista Inicial: Abrir Caja
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(
                        Icons.Default.Lock, 
                        contentDescription = null, 
                        modifier = Modifier.size(80.dp),
                        tint = ActionBlue.copy(alpha = 0.5f)
                    )
                    Spacer(modifier = Modifier.height(24.dp))
                    Text(
                        "LA CAJA ESTÁ CERRADA", 
                        fontWeight = FontWeight.Bold, 
                        color = Color.Gray
                    )
                    Spacer(modifier = Modifier.height(32.dp))
                    Button(
                        onClick = { isShiftStarted = true },
                        modifier = Modifier.fillMaxWidth(0.7f).height(60.dp),
                        shape = RoundedCornerShape(16.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = ActionBlue)
                    ) {
                        Text("ABRIR CAJA", fontWeight = FontWeight.Black, fontSize = 16.sp)
                    }
                }
            } else {
                // POS Dashboard Simple (3 Opciones)
                Column(
                    modifier = Modifier.fillMaxSize().padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        "TOTAL VENTAS: $0.00", 
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Black,
                        color = PrimaryNavy
                    )
                    
                    Spacer(modifier = Modifier.height(40.dp))

                    POSOptionButton("NUEVA VENTA", Icons.Default.Add) { /* Nueva Venta */ }
                    Spacer(modifier = Modifier.height(16.dp))
                    POSOptionButton("HISTORIAL", Icons.Default.List) { /* Ver ventas */ }
                    Spacer(modifier = Modifier.height(16.dp))
                    POSOptionButton("CERRAR CORTE", Icons.Default.Check) { isShiftStarted = false }
                }
            }
        }
    }
}

@Composable
fun POSOptionButton(title: String, icon: androidx.compose.ui.graphics.vector.ImageVector, onClick: () -> Unit) {
    Button(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth().height(80.dp),
        shape = RoundedCornerShape(20.dp),
        colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.surfaceVariant, contentColor = PrimaryNavy),
        elevation = ButtonDefaults.buttonElevation(defaultElevation = 2.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth()) {
            Icon(icon, null, modifier = Modifier.size(28.dp))
            Spacer(modifier = Modifier.width(20.dp))
            Text(title, fontWeight = FontWeight.Bold, fontSize = 18.sp)
        }
    }
}
