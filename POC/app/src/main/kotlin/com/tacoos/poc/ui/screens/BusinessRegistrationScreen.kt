package com.tacoos.poc.ui.screens

import android.app.TimePickerDialog
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
import com.tacoos.poc.domain.usecase.FormatTimeUseCase
import com.tacoos.poc.ui.theme.ActionBlue
import com.tacoos.poc.ui.theme.PrimaryNavy
import java.util.*

/**
 * BusinessRegistrationScreen: Formulario de configuración inicial del negocio.
 * Inyección de dependencias: NavController para flujo de éxito, RegistrationViewModel para envío de datos.
 * Manejo de Formulario: Gestiona estados para nombre, domicilio, giro y una lógica compleja de horarios de servicio.
 */
@Composable
fun BusinessRegistrationScreen(navController: NavController, viewModel: RegistrationViewModel = viewModel()) {
    val context = LocalContext.current
    val uiState by viewModel.uiState.collectAsState()

    // Estados locales del formulario de datos básicos.

    
    // Estados para la lógica de Horarios:
    // mismoHorario define si se aplica una regla general o individual por día de la semana.
    var mismoHorario by remember { mutableStateOf(true) }
    val diasSemana = listOf("Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo")
    
    // horariosPorDia: Almacena Triple(Abierto, Apertura, Cierre) para cada día.
    var horariosPorDia by remember { 
        mutableStateOf(diasSemana.associateWith { Triple(true, "09:00 AM", "08:00 PM") }) 
    }
    
    // Variables para el horario consolidado.
    var aperturaGeneral by remember { mutableStateOf("09:00 AM") }
    var cierreGeneral by remember { mutableStateOf("08:00 PM") }

    // Observador de éxito: Redirige al Dashboard una vez que el Backend confirma el registro.
    LaunchedEffect(uiState) {
        if (uiState is RegistrationUiState.Success) {
            navController.navigate("dashboard") {
                popUpTo("login") { inclusive = true }
            }
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
                    color = PrimaryNavy
                )
            )
            Text(
                text = "Configuración de tu establecimiento",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)
            )
            
            Spacer(modifier = Modifier.height(32.dp))
            
            // Inyección de componentes de entrada de texto estilizados.
            AppTextField(
                value = viewModel.nombre,
                onValueChange = { viewModel.onNombreChange(it)},
                label = "Nombre de tu negocio")
            Spacer(modifier = Modifier.height(16.dp))
            
            AppTextField(
                value = viewModel.domicilio,
                onValueChange = { viewModel.onDomicilioChange(it) },
                label = "Domicilio")
            Spacer(modifier = Modifier.height(16.dp))
            
            AppTextField(
                value = viewModel.giro,
                onValueChange = { viewModel.onGiroChange(it) },
                label = "¿Qué vendes? (Giro)",
                placeholder = "Ej: Hamburguesas, tacos, carnitas..."
            )
            
            Spacer(modifier = Modifier.height(32.dp))
            
            // Sección de Horarios de Servicio.
            Text(
                text = "Horario de servicio",
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold, color = PrimaryNavy)
            )
            
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(vertical = 8.dp).clickable { mismoHorario = !mismoHorario }
            ) {
                Checkbox(checked = mismoHorario, onCheckedChange = { mismoHorario = it })
                Text("Mismo horario todos los días", style = MaterialTheme.typography.bodyMedium)
            }

            if (mismoHorario) {
                // Formulario simplificado: Apertura y Cierre únicos.
                Row(modifier = Modifier.fillMaxWidth()) {
                    TimePickerField(label = "Apertura", value = aperturaGeneral, modifier = Modifier.weight(1f)) {
                        aperturaGeneral = it
                    }
                    Spacer(modifier = Modifier.width(16.dp))
                    TimePickerField(label = "Cierre", value = cierreGeneral, modifier = Modifier.weight(1f)) {
                        cierreGeneral = it
                    }
                }
            } else {
                // Formulario detallado: Listado de 7 días con selectores independientes.
                diasSemana.forEach { dia ->
                    val config = horariosPorDia[dia]!!
                    DayScheduleRow(
                        day = dia,
                        isOpen = config.first,
                        apertura = config.second,
                        cierre = config.third,
                        onToggle = { 
                            horariosPorDia = horariosPorDia.toMutableMap().apply { put(dia, config.copy(first = it)) }
                        },
                        onTimeClick = { isStart, newTime ->
                            horariosPorDia = horariosPorDia.toMutableMap().apply {
                                val current = get(dia)!!
                                put(dia, if(isStart) current.copy(second = newTime) else current.copy(third = newTime))
                            }
                        }
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(48.dp))
            
            // Botón de Envío: Delega el registro al ViewModel de Registro.
            Button(
                onClick = { 
                    if (viewModel.nombre.isNotBlank()) viewModel.registerUserAndBusiness()
                },
                modifier = Modifier.fillMaxWidth().height(60.dp),
                shape = RoundedCornerShape(20.dp),
                colors = ButtonDefaults.buttonColors(containerColor = PrimaryNavy)
            ) {
                Text("LISTO", fontWeight = FontWeight.Black, fontSize = 16.sp)
            }
        }
    }
}

/**
 * AppTextField: Campo de texto personalizado con etiquetas superiores.
 */
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

/**
 * TimePickerField: Selector de hora estilizado que invoca el diálogo nativo de Android.
 */
@Composable
fun TimePickerField(label: String, value: String, modifier: Modifier = Modifier, onTimeSelected: (String) -> Unit) {
    val context = LocalContext.current
    Column(modifier = modifier) {
        Text(text = label.uppercase(), style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold, color = PrimaryNavy.copy(alpha = 0.6f)))
        Spacer(modifier = Modifier.height(4.dp))
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp)
                .background(Color.LightGray.copy(alpha = 0.1f), RoundedCornerShape(16.dp))

                .clickable {
                    // Inyección de lógica nativa: TimePickerDialog.
                    val calendar = Calendar.getInstance()
                    TimePickerDialog(context, { _, h, m ->
                        val formattedTime = FormatTimeUseCase()(h, m)
                        onTimeSelected(formattedTime)
                    }, calendar.get(Calendar.HOUR_OF_DAY), calendar.get(Calendar.MINUTE), false).show()
                }


                .padding(horizontal = 16.dp),
            contentAlignment = Alignment.CenterStart
        ) {
            Text(text = value, fontWeight = FontWeight.Medium)
        }
    }
}

/**
 * DayScheduleRow: Fila individual para configurar el horario de un día específico.
 */
@Composable
fun DayScheduleRow(day: String, isOpen: Boolean, apertura: String, cierre: String, onToggle: (Boolean) -> Unit, onTimeClick: (Boolean, String) -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Checkbox(checked = isOpen, onCheckedChange = onToggle)
        Text(text = day, modifier = Modifier.width(90.dp), fontWeight = FontWeight.Bold)
        
        if (isOpen) {
            Row(modifier = Modifier.weight(1f)) {
                TimeBox(value = apertura, modifier = Modifier.weight(1f)) { onTimeClick(true, it) }
                Spacer(modifier = Modifier.width(8.dp))
                TimeBox(value = cierre, modifier = Modifier.weight(1f)) { onTimeClick(false, it) }
            }
        } else {
            Text("Cerrado", modifier = Modifier.weight(1f), color = Color.Gray)
        }
    }
}

/**
 * TimeBox: Caja interactiva pequeña para selección de hora en el listado por días.
 */
@Composable
fun TimeBox(value: String, modifier: Modifier, onSelected: (String) -> Unit) {
    val context = LocalContext.current
    Box(
        modifier = modifier
            .height(40.dp)
            .background(Color.LightGray.copy(alpha = 0.1f), RoundedCornerShape(8.dp))
            .clickable {
                val calendar = Calendar.getInstance()
                TimePickerDialog(context, { _, h, m ->
                    val formattedTime = FormatTimeUseCase()(h, m)
                    onSelected(formattedTime)
                }, calendar.get(Calendar.HOUR_OF_DAY), calendar.get(Calendar.MINUTE), false).show()
            },
        contentAlignment = Alignment.Center
    ) {
        Text(value, fontSize = 12.sp)
    }
}
