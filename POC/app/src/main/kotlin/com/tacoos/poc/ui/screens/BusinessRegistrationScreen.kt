package com.tacoos.poc.ui.screens

import android.widget.Toast
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.tacoos.poc.ui.theme.ActionBlue

@Composable
fun BusinessRegistrationScreen(navController: NavController, viewModel: RegistrationViewModel = viewModel()) {
    val context = LocalContext.current
    val uiState by viewModel.uiState.collectAsState()

    var nombre by remember { mutableStateOf("") }
    var domicilio by remember { mutableStateOf("") }
    var giro by remember { mutableStateOf("") }
    var apertura by remember { mutableStateOf("") }
    var cierre by remember { mutableStateOf("") }

    LaunchedEffect(uiState) {
        if (uiState is RegistrationUiState.Success) {
            navController.navigate("dashboard") {
                popUpTo("login") { inclusive = true }
            }
        } else if (uiState is RegistrationUiState.Error) {
            Toast.makeText(context, (uiState as RegistrationUiState.Error).message, Toast.LENGTH_SHORT).show()
        }
    }

    Surface(
        color = MaterialTheme.colorScheme.background, 
        modifier = Modifier.fillMaxSize()
    ) {
        Box {
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
                    label = { Text("Tipo de Negocio (Giro)") }, 
                    placeholder = { Text("Ej: Venta de hamburguesas, Tacos de pastor...") },
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
                    onClick = { 
                        if (nombre.isNotBlank() && domicilio.isNotBlank()) {
                            viewModel.registerUserAndBusiness(nombre, domicilio, giro)
                        } else {
                            Toast.makeText(context, "Completa los campos obligatorios", Toast.LENGTH_SHORT).show()
                        }
                    },
                    modifier = Modifier.fillMaxWidth().height(56.dp),
                    shape = RoundedCornerShape(12.dp),
                    enabled = uiState !is RegistrationUiState.Loading
                ) {
                    if (uiState is RegistrationUiState.Loading) {
                        CircularProgressIndicator(modifier = Modifier.size(24.dp), color = Color.White)
                    } else {
                        Text("REGISTRAR", fontWeight = FontWeight.Bold)
                    }
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
}
