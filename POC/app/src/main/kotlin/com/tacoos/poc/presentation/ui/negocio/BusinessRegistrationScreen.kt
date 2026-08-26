package com.tacoos.poc.presentation.ui.negocio

import android.app.TimePickerDialog
import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.tacoos.poc.presentation.theme.ActionBlue
import com.tacoos.poc.presentation.theme.PrimaryNavy
import com.tacoos.poc.presentation.uiState.business.BusinessUiState
import com.tacoos.poc.presentation.viewmodel.auth.RegistrationViewModel
import androidx.compose.ui.tooling.preview.Preview
import java.util.Calendar
import java.util.Locale

/**
 * Pantalla para el registro de un nuevo negocio.
 * Gestiona el flujo de registro y muestra mensajes de éxito o error.
 *
 * @param viewModel ViewModel encargado de la lógica de registro de negocio.
 * @param onSuccess Función que se ejecuta tras un registro exitoso.
 */
@Composable
fun BusinessRegistrationScreen(
    viewModel: RegistrationViewModel = hiltViewModel(),
    onSuccess: () -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current

    LaunchedEffect(uiState.isSuccess) {
        if (uiState.isSuccess) {
            uiState.successMessage?.let {
                Toast.makeText(context, it, Toast.LENGTH_LONG).show()
            }
            onSuccess()
        }
    }

    BusinessRegistrationContent(
        uiState = uiState,
        onNombreChange = viewModel::onNombreChange,
        onDomicilioChange = viewModel::onDomicilioChange,
        onTelefonoChange = viewModel::onTelefonoChange,
        onGiroChange = viewModel::onGiroChange,
        onEmpleadosChange = viewModel::onEmpleadosChange,
        onHorarioChange = viewModel::onHorarioChange,
        onRegisterClick = viewModel::registerBusiness
    )
}

/**
 * Contenido visual del formulario de registro de negocio.
 *
 * @param uiState Estado actual del registro del negocio.
 * @param onNombreChange Callback para cuando cambia el nombre del negocio.
 * @param onDomicilioChange Callback para cuando cambia la dirección.
 * @param onTelefonoChange Callback para cuando cambia el teléfono.
 * @param onGiroChange Callback para cuando cambia el giro o categoría.
 * @param onEmpleadosChange Callback para cuando cambia el número de empleados.
 * @param onHorarioChange Callback para cuando cambia el horario de cierre.
 * @param onRegisterClick Acción al pulsar el botón para completar el registro.
 */
@Composable
fun BusinessRegistrationContent(
    uiState: BusinessUiState,
    onNombreChange: (String) -> Unit,
    onDomicilioChange: (String) -> Unit,
    onTelefonoChange: (String) -> Unit,
    onGiroChange: (String) -> Unit,
    onEmpleadosChange: (String) -> Unit,
    onHorarioChange: (String) -> Unit,
    onRegisterClick: () -> Unit
) {
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

            AppTextField(value = uiState.nombre, onValueChange = onNombreChange, label = "Nombre de tu negocio")
            Spacer(modifier = Modifier.height(16.dp))

            AppTextField(value = uiState.domicilio, onValueChange = onDomicilioChange, label = "Dirección completa")
            Spacer(modifier = Modifier.height(16.dp))

            AppTextField(value = uiState.telefono, onValueChange = onTelefonoChange, label = "Teléfono de contacto")
            Spacer(modifier = Modifier.height(16.dp))

            AppTextField(value = uiState.giro, onValueChange = onGiroChange, label = "¿Qué vendes? (Categoría)")
            Spacer(modifier = Modifier.height(16.dp))

            AppTextField(value = uiState.empleados, onValueChange = onEmpleadosChange, label = "Número de empleados")
            Spacer(modifier = Modifier.height(16.dp))

            TimePickerField(label = "Horario de cierre", value = uiState.horarioCierre, onTimeSelected = onHorarioChange)
            
            Spacer(modifier = Modifier.height(32.dp))

            if (uiState.isLoading) {
                Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = PrimaryNavy)
                }
            } else {
                Button(
                    onClick = onRegisterClick,
                    modifier = Modifier.fillMaxWidth().height(60.dp),
                    shape = RoundedCornerShape(20.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF0D47A1))
                ) {
                    Text("LISTO", fontWeight = FontWeight.Black, fontSize = 16.sp)
                }
            }

            uiState.errorMessage?.let {
                Spacer(modifier = Modifier.height(16.dp))
                Text(text = it, color = MaterialTheme.colorScheme.error, fontSize = 12.sp)
            }
        }
    }
}

/**
 * Componente de campo de texto personalizado utilizado en el formulario.
 *
 * @param value Valor actual del texto.
 * @param onValueChange Callback que se ejecuta al cambiar el texto.
 * @param label Etiqueta descriptiva del campo.
 * @param placeholder Texto de sugerencia que aparece cuando el campo está vacío.
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
            singleLine = true,
            shape = RoundedCornerShape(16.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = ActionBlue,
                unfocusedBorderColor = Color.LightGray.copy(alpha = 0.5f)
            )
        )
    }
}

/**
 * Campo que permite seleccionar una hora mediante un diálogo de reloj.
 *
 * @param label Etiqueta del campo.
 * @param value Valor de tiempo actual.
 * @param onTimeSelected Callback que se ejecuta al seleccionar una hora.
 */
@Composable
fun TimePickerField(label: String, value: String, onTimeSelected: (String) -> Unit) {
    val context = LocalContext.current
    Column {
        Text(text = label.uppercase(), style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold, color = PrimaryNavy.copy(alpha = 0.6f)))
        Spacer(modifier = Modifier.height(4.dp))
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp)
                .background(Color.LightGray.copy(alpha = 0.1f), RoundedCornerShape(16.dp))
                .clickable {
                    val calendar = Calendar.getInstance()
                    TimePickerDialog(context, { _, h, m ->
                        val formattedTime = String.format(Locale.getDefault(), "%02d:%02d", h, m)
                        onTimeSelected(formattedTime)
                    }, calendar.get(Calendar.HOUR_OF_DAY), calendar.get(Calendar.MINUTE), true).show()
                }
                .padding(horizontal = 16.dp),
            contentAlignment = Alignment.CenterStart
        ) {
            Text(text = value, fontWeight = FontWeight.Medium)
        }
    }
}

/**
 * Previsualización de la pantalla de registro de negocio.
 */
@Preview(showBackground = true, showSystemUi = true)
@Composable
fun BusinessRegistrationPreview() {
    BusinessRegistrationContent(
        uiState = BusinessUiState(
            nombre = "Tacoos",
            domicilio = "Av. Principal #123",
            telefono = "1234567890",
            giro = "Comida rápida"
        ),
        onNombreChange = {},
        onDomicilioChange = {},
        onTelefonoChange = {},
        onGiroChange = {},
        onEmpleadosChange = {},
        onHorarioChange = {},
        onRegisterClick = {}
    )
}
