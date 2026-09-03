package com.tacoos.poc.presentation.ui.auth

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PointOfSale
import androidx.compose.material.icons.filled.Store
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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.tacoos.poc.presentation.viewmodel.auth.AuthViewModel


import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.filled.Store
import androidx.compose.material.icons.filled.PointOfSale
import androidx.compose.material3.*
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
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
    // Gradiente de fondo
    val gradient = Brush.verticalGradient(
        colors = listOf(Color(0xFF0D47A1), Color(0xFF42A5F5))
    )

    Surface(
        color = Color.Transparent,
        modifier = Modifier
            .fillMaxSize()
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(Color(0xFF0D47A1), Color(0xFF42A5F5))
                    )
                )
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(32.dp),
                verticalArrangement = Arrangement.Center,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Hola, $nickname",
                    style = MaterialTheme.typography.headlineMedium.copy(
                        color = Color.White
                    )
                )
                Text(
                    text = "Bienvenido a TacoOs",
                    style = MaterialTheme.typography.headlineMedium.copy(
                        fontWeight = FontWeight.ExtraBold,
                        color = Color.White
                    )
                )

                Spacer(modifier = Modifier.height(40.dp))

                Text(
                    text = "¿Cuál es tu rol?",
                    style = MaterialTheme.typography.headlineSmall.copy(
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                )
                Text(
                    text = "Selecciona tu perfil de acceso",
                    style = MaterialTheme.typography.bodyMedium.copy(color = Color.White.copy(alpha = 0.8f))
                )

                Spacer(modifier = Modifier.height(48.dp))

                // Botón Administrador con ícono
                Button(
                    onClick = onAdminSelected,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(80.dp),
                    shape = RoundedCornerShape(20.dp),
                    elevation = ButtonDefaults.buttonElevation(defaultElevation = 6.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color.White)
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Store, contentDescription = "Admin", tint = Color(0xFF0D47A1))
                        Spacer(modifier = Modifier.width(12.dp))
                        Column {
                            Text("ADMINISTRADOR", fontSize = 18.sp, fontWeight = FontWeight.Black, color = Color(0xFF0D47A1))
                            Text("Registra y administra tu negocio", fontSize = 12.sp, color = Color(0xFF0D47A1))
                        }
                    }
                }

                Spacer(modifier = Modifier.height(20.dp))

                // Botón Cajero con ícono
                OutlinedButton(
                    onClick = onCajeroSelected,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(80.dp),
                    shape = RoundedCornerShape(20.dp),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
                    border = BorderStroke(2.dp, Color.White)
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.PointOfSale, contentDescription = "Cajero", tint = Color.White)
                        Spacer(modifier = Modifier.width(12.dp))
                        Column {
                            Text("CAJERO", fontSize = 18.sp, fontWeight = FontWeight.Black, color = Color.White)
                            Text("Sé colaborador eficiente de tu empresa", fontSize = 12.sp, color = Color.White)
                        }
                    }
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
