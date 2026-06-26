package com.tacoos.poc.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.tacoos.poc.ui.theme.ActionBlue

@Composable
fun BusinessRegistrationScreen(navController: NavController) {
    var nombre by remember { mutableStateOf("") }
    var domicilio by remember { mutableStateOf("") }
    var giro by remember { mutableStateOf("") }
    var apertura by remember { mutableStateOf("") }
    var cierre by remember { mutableStateOf("") }

    Surface(
        color = MaterialTheme.colorScheme.background, 
        modifier = Modifier.fillMaxSize()
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(32.dp)
                .verticalScroll(rememberScrollState())
        ) {
            Text(
                text = "Registra Negocio", 
                style = MaterialTheme.typography.headlineMedium.copy(
                    fontWeight = FontWeight.ExtraBold,
                    color = ActionBlue
                )
            )
            Text(
                text = "Configuración inicial de tu establecimiento",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f)
            )
            
            Spacer(modifier = Modifier.height(32.dp))
            
            OutlinedTextField(
                value = nombre, 
                onValueChange = { nombre = it }, 
                label = { Text("Nombre del Negocio") }, 
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp)
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            OutlinedTextField(
                value = domicilio, 
                onValueChange = { domicilio = it }, 
                label = { Text("Domicilio") }, 
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp)
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            OutlinedTextField(
                value = giro, 
                onValueChange = { giro = it }, 
                label = { Text("Giro Comercial") }, 
                placeholder = { Text("Ej: Venta de hamburguesas, tacos, etc.") },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp)
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Row(modifier = Modifier.fillMaxWidth()) {
                OutlinedTextField(
                    value = apertura, 
                    onValueChange = { apertura = it }, 
                    label = { Text("Apertura") }, 
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(12.dp)
                )
                Spacer(modifier = Modifier.width(16.dp))
                OutlinedTextField(
                    value = cierre, 
                    onValueChange = { cierre = it }, 
                    label = { Text("Cierre") }, 
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(12.dp)
                )
            }
            
            Spacer(modifier = Modifier.height(48.dp))
            
            Button(
                onClick = { navController.navigate("dashboard") },
                modifier = Modifier.fillMaxWidth().height(56.dp),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text("REGISTRAR", fontWeight = FontWeight.Bold)
            }
            
            Spacer(modifier = Modifier.height(12.dp))
            
            TextButton(
                onClick = { navController.popBackStack() },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("CANCELAR", color = MaterialTheme.colorScheme.error)
            }
        }
    }
}
