package com.tacoos.poc.presentation.ui.auth

import android.graphics.Paint
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.tacoos.poc.presentation.viewmodel.auth.AuthViewModel

/**
 * Pantalla que permite al usuario seleccionar su rol dentro de la aplicación.
 *
 * @param onAdminSelected Callback para cuando se selecciona el rol de Administrador.
 * @param onCajeroSelected Callback para cuando se selecciona el rol de Cajero.
 * @param viewModel ViewModel para obtener información del usuario, como su nickname.
 */
@Composable
fun RoleSelectionScreen(
    onAdminSelected: () -> Unit,
    onCajeroSelected: () -> Unit,
    viewModel: AuthViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    RoleSelectionContent(
        nickname = uiState.nickname,
        onAdminSelected = onAdminSelected,
        onCajeroSelected = onCajeroSelected
    )
}

/**
 * Contenido visual de la pantalla de selección de rol.
 *
 * @param nickname Apodo o nombre del usuario para el saludo inicial.
 * @param onAdminSelected Acción al seleccionar Administrador.
 * @param onCajeroSelected Acción al seleccionar Cajero.
 */
@Composable
fun RoleSelectionContent(
    nickname: String,
    onAdminSelected: () -> Unit,
    onCajeroSelected: () -> Unit
) {
    Surface(
        color = MaterialTheme.colorScheme.background,
        modifier = Modifier.fillMaxSize()
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .fillMaxHeight(0.2f)
                    .background(Color.Transparent)
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth(),
                    horizontalAlignment = Alignment.Start
                ) {
                    Text(
                        text = "Hola, $nickname",
                        style = MaterialTheme.typography.headlineMedium.copy(
                            fontWeight = FontWeight.Light,
                            color = Color(0xFF0D47A1)
                        )
                    )
                    Text(
                        text = "Bienvenido a TacoOs",
                        style = MaterialTheme.typography.headlineMedium.copy(
                            fontWeight = FontWeight.ExtraBold,
                            color = Color(0xFF0D47A1)
                        )
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            Text(
                text = "¿Cuál es tu rol?",
                style = MaterialTheme.typography.headlineSmall.copy(
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF0D47A1)
                )
            )
            Text(
                text = "Selecciona tu perfil de acceso",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f)
            )

            Spacer(modifier = Modifier.height(48.dp))

            Button(
                onClick = onAdminSelected,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(80.dp),
                shape = RoundedCornerShape(20.dp),
                elevation = ButtonDefaults.buttonElevation(defaultElevation = 4.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF0D47A1))
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("ADMINISTRADOR", fontSize = 18.sp, fontWeight = FontWeight.Black)
                    Text("Registra y administra tu negocio", fontSize = 12.sp, fontWeight = FontWeight.Normal)
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            OutlinedButton(
                onClick = onCajeroSelected,
                modifier = Modifier.fillMaxWidth().height(80.dp),
                shape = RoundedCornerShape(20.dp),
                colors = ButtonDefaults.outlinedButtonColors(
                    contentColor = Color(0xFF0D47A1)),
                border = BorderStroke(2.dp, Color(0xFF0D47A1))
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("CAJERO", fontSize = 18.sp, fontWeight = FontWeight.Black)
                    Text("Sé colaborador eficiente de tu empresa", fontSize = 12.sp, fontWeight = FontWeight.Normal)
                }
            }
        }
    }
}

/**
 * Previsualización de la pantalla de selección de rol.
 */
@Preview(showBackground = true, showSystemUi = true)
@Composable
fun RoleSelectionPreview() {
    RoleSelectionContent(nickname = "Faner Santander", onAdminSelected = {}, onCajeroSelected = {})
}
