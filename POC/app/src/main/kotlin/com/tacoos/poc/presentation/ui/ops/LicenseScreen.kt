package com.tacoos.poc.presentation.ui.ops

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.VerifiedUser
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import com.tacoos.poc.domain.model.LicenseStatus
import com.tacoos.poc.presentation.theme.ActionBlue
import com.tacoos.poc.presentation.theme.PrimaryNavy
import com.tacoos.poc.presentation.theme.SuccessGreen
import com.tacoos.poc.presentation.uiState.auth.GoogleSignInState
import com.tacoos.poc.presentation.uiState.ops.LicenseUiState
import com.tacoos.poc.presentation.viewmodel.ops.LicenseViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LicenseScreen(
    navController: NavController,
    viewModel: LicenseViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(Unit) {
        GoogleSignInState.negocioId?.let { viewModel.loadLicense(it) }
    }

    LicenseContent(
        uiState = uiState,
        onBack = { navController.popBackStack() }
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LicenseContent(
    uiState: LicenseUiState,
    onBack: () -> Unit
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("MI LICENCIA", fontWeight = FontWeight.Black) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, null)
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            if (uiState.isLoading) {
                CircularProgressIndicator(color = ActionBlue)
            } else {
                Icon(
                    Icons.Default.VerifiedUser,
                    null,
                    modifier = Modifier.size(100.dp),
                    tint = SuccessGreen
                )
                
                Spacer(Modifier.height(24.dp))

                Text(
                    uiState.license?.planName ?: "Sin Plan Activo",
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.Black,
                    color = PrimaryNavy
                )

                Spacer(Modifier.height(8.dp))

                Surface(
                    color = SuccessGreen.copy(alpha = 0.1f),
                    shape = RoundedCornerShape(8.dp)
                ) {
                    Text(
                        "ESTADO: ${uiState.license?.status ?: "INACTIVO"}",
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp),
                        color = SuccessGreen,
                        fontWeight = FontWeight.Bold,
                        fontSize = 12.sp
                    )
                }

                Spacer(Modifier.height(32.dp))

                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                ) {
                    Column(Modifier.padding(20.dp)) {
                        Text("Detalles de Suscripción", fontWeight = FontWeight.Bold)
                        Spacer(Modifier.height(12.dp))
                        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                            Text("Fecha de Vencimiento:", color = Color.Gray)
                            Text(uiState.license?.expiryDate ?: "N/A", fontWeight = FontWeight.Bold)
                        }
                    }
                }

                Spacer(Modifier.weight(1f))

                Button(
                    onClick = { /* TODO */ },
                    modifier = Modifier.fillMaxWidth().height(60.dp),
                    shape = RoundedCornerShape(16.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = ActionBlue)
                ) {
                    Text("RENOVAR O CAMBIAR PLAN", fontWeight = FontWeight.Black)
                }
            }
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun LicensePreview() {
    LicenseContent(
        uiState = LicenseUiState(
            license = LicenseStatus("123", "ACTIVE", "2026-12-31", "TacoOs Premium")
        ),
        onBack = {}
    )
}

@Preview(showBackground = true, showSystemUi = true, name = "Expirado")
@Composable
fun LicenseExpiredPreview() {
    LicenseContent(
        uiState = LicenseUiState(
            license = LicenseStatus("123", "EXPIRED", "2024-01-01", "Plan Básico")
        ),
        onBack = {}
    )
}

