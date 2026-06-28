package com.tacoos.poc.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.lifecycle.viewmodel.compose.viewModel
import com.tacoos.poc.ui.theme.ActionBlue

@Composable
fun RoleSelectionScreen(navController: NavController, viewModel: RegistrationViewModel = viewModel()) {
    Surface(
        color = MaterialTheme.colorScheme.background, 
        modifier = Modifier.fillMaxSize()
    ) {
        Column(
            modifier = Modifier.fillMaxSize().padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = "¿Cuál es tu rol?", 
                style = MaterialTheme.typography.headlineMedium.copy(
                    fontWeight = FontWeight.ExtraBold,
                    color = ActionBlue
                )
            )
            Text(
                text = "Selecciona tu perfil de acceso",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f)
            )
            
            Spacer(modifier = Modifier.height(48.dp))
            
            Button(
                onClick = { 
                    viewModel.selectRole("dueño")
                    navController.navigate("business_registration") 
                },
                modifier = Modifier.fillMaxWidth().height(80.dp),
                shape = RoundedCornerShape(20.dp),
                elevation = ButtonDefaults.buttonElevation(defaultElevation = 4.dp)
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("ADMINISTRADOR", fontSize = 20.sp, fontWeight = FontWeight.Black)
                    Text("Gestión total del negocio", fontSize = 12.sp, fontWeight = FontWeight.Normal)
                }
            }
            
            Spacer(modifier = Modifier.height(20.dp))
            
            OutlinedButton(
                onClick = { 
                    viewModel.selectRole("cajero")
                    navController.navigate("cashier_assignment") 
                },
                modifier = Modifier.fillMaxWidth().height(80.dp),
                shape = RoundedCornerShape(20.dp)
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("CAJERO", fontSize = 20.sp, fontWeight = FontWeight.Black)
                    Text("Registro de ventas diarias", fontSize = 12.sp, fontWeight = FontWeight.Normal)
                }
            }
        }
    }
}
