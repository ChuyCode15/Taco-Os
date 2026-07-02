package com.tacoos.poc.ui.screens

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import com.tacoos.poc.ui.theme.PrimaryNavy

@Composable
fun BusinessRegistrationScreen(navController: NavController, viewModel: RegistrationViewModel = viewModel()) {
    val context = LocalContext.current
    val uiState by viewModel.uiState.collectAsState()

    var nombre by remember { mutableStateOf("") }
    var domicilio by remember { mutableStateOf("") }
    var giro by remember { mutableStateOf("") }
    
    // Horarios
    var mismoHorario by remember { mutableStateOf(true) }
    val diasSemana = listOf("Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo")
    
    // Estado para horarios por día (Abierto, Apertura, Cierre)
    var horariosPorDia by remember { 
        mutableStateOf(diasSemana.associateWith { Triple(true, "09:00 AM", "08:00 PM") }) 
    }
    
    // Horario general (si mismoHorario es true)
    var aperturaGeneral by remember { mutableStateOf("09:00 AM") }
    var cierreGeneral by remember { mutableStateOf("08:00 PM") }

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
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp)
                .verticalScroll(rememberScrollState())
        ) {
            Text(
                text = "Comienza registrando estos datos", 
                style = MaterialTheme.typography.headlineSmall.copy(
                    fontWeight = FontWeight.Black,
                    color = PrimaryNavy,
                    letterSpacing = (-0.5).sp
                )
            )
            Text(
                text = "Configuración de tu establecimiento",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)
            )
            
            Spacer(modifier = Modifier.height(32.dp))
            
            // Estilo Apple: Campos redondeados y limpios
            AppTextField(value = nombre, onValueChange = { nombre = it }, label = "Nombre de tu negocio")
            Spacer(modifier = Modifier.height(16.dp))
            
            AppTextField(value = domicilio, onValueChange = { domicilio = it }, label = "Domicilio")
            Spacer(modifier = Modifier.height(16.dp))
            
            AppTextField(
                value = giro, 
                onValueChange = { giro = it }, 
                label = "¿Qué vendes? (Giro)",
                placeholder = "Ej: Hamburguesas, tacos, carnitas..."
            )
            
            Spacer(modifier = Modifier.height(32.dp))
            
            // SECCIÓN HORARIOS
            Text(
                text = "Horario de servicio",
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold, color = PrimaryNavy)
            )
            
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(vertical = 8.dp).clickable { mismoHorario = !mismoHorario }
            ) {
                Checkbox(
                    checked = mismoHorario,
                    onCheckedChange = { mismoHorario = it },
                    colors = CheckboxDefaults.colors(checkedColor = ActionBlue)
                )
                Text("Mismo horario todos los días", style = MaterialTheme.typography.bodyMedium)
            }

            if (mismoHorario) {
                Row(modifier = Modifier.fillMaxWidth()) {
                    TimePickerField(label = "Apertura", value = aperturaGeneral, modifier = Modifier.weight(1f))
                    Spacer(modifier = Modifier.width(16.dp))
                    TimePickerField(label = "Cierre", value = cierreGeneral, modifier = Modifier.weight(1f))
                }
            } else {
                diasSemana.forEach { dia ->
                    val config = horariosPorDia[dia]!!
                    DayScheduleRow(
                        day = dia,
                        isOpen = config.first,
                        apertura = config.second,
                        cierre = config.third,
                        onToggle = { 
                            horariosPorDia = horariosPorDia.toMutableMap().apply { 
                                put(dia, config.copy(first = it)) 
                            }
                        }
                    )
                }
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
                modifier = Modifier.fillMaxWidth().height(60.dp),
                shape = RoundedCornerShape(20.dp),
                colors = ButtonDefaults.buttonColors(containerColor = PrimaryNavy),
                enabled = uiState !is RegistrationUiState.Loading
            ) {
                if (uiState is RegistrationUiState.Loading) {
                    CircularProgressIndicator(modifier = Modifier.size(24.dp), color = Color.White)
                } else {
                    Text("LISTO", fontWeight = FontWeight.Black, fontSize = 16.sp)
                }
            }
        }
    }
}

@Composable
fun AppTextField(value: String, onValueChange: (String) -> Unit, label: String, placeholder: String = "") {
    Column {
        Text(text = label.uppercase(), style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold, color = PrimaryNavy.copy(alpha = 0.6f)))
        Spacer(modifier = Modifier.height(4.dp))
        OutlinedTextField(
            value = value, 
            onValueChange = onValueChange, 
            placeholder = { if(placeholder.isNotEmpty()) Text(placeholder, color = Color.LightGray) },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(16.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = ActionBlue,
                unfocusedBorderColor = Color.LightGray.copy(alpha = 0.5f)
            )
        )
    }
}

@Composable
fun TimePickerField(label: String, value: String, modifier: Modifier = Modifier) {
    Column(modifier = modifier) {
        Text(text = label.uppercase(), style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold, color = PrimaryNavy.copy(alpha = 0.6f)))
        Spacer(modifier = Modifier.height(4.dp))
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp)
                .background(Color.LightGray.copy(alpha = 0.1f), RoundedCornerShape(16.dp))
                .padding(horizontal = 16.dp),
            contentAlignment = Alignment.CenterStart
        ) {
            Text(text = value, fontWeight = FontWeight.Medium)
        }
    }
}

@Composable
fun DayScheduleRow(day: String, isOpen: Boolean, apertura: String, cierre: String, onToggle: (Boolean) -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Checkbox(checked = isOpen, onCheckedChange = onToggle)
        Text(text = day, modifier = Modifier.width(90.dp), style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.Bold))
        
        if (isOpen) {
            Row(modifier = Modifier.weight(1f)) {
                Box(
                    modifier = Modifier.weight(1f).height(40.dp).background(Color.LightGray.copy(alpha = 0.1f), RoundedCornerShape(8.dp)),
                    contentAlignment = Alignment.Center
                ) { Text(apertura, fontSize = 12.sp) }
                Spacer(modifier = Modifier.width(8.dp))
                Box(
                    modifier = Modifier.weight(1f).height(40.dp).background(Color.LightGray.copy(alpha = 0.1f), RoundedCornerShape(8.dp)),
                    contentAlignment = Alignment.Center
                ) { Text(cierre, fontSize = 12.sp) }
            }
        } else {
            Text("Cerrado", modifier = Modifier.weight(1f), color = Color.Gray, fontSize = 12.sp)
        }
    }
}
