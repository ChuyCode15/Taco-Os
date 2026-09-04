package com.tacoos.poc.presentation.ui.ops

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import androidx.navigation.compose.rememberNavController
import com.tacoos.poc.presentation.theme.PrimaryNavy
import com.tacoos.poc.presentation.theme.SuccessGreen
import com.tacoos.poc.presentation.ui.components.ReportRow
import com.tacoos.poc.presentation.uiState.ops.DailyCutUiState
import com.tacoos.poc.presentation.viewmodel.ops.DailyCutViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DailyCutScreen(
    navController: NavController,
    shiftId: Long,
    viewModel: DailyCutViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    DailyCutContent(
        uiState = uiState,
        onBack = { navController.popBackStack() },
        onPerformCorte = { cash -> viewModel.performCorte(shiftId, cash) }
    )

    if (uiState.isSuccess) {
        LaunchedEffect(Unit) {
            navController.popBackStack()
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DailyCutContent(
    uiState: DailyCutUiState,
    onBack: () -> Unit,
    onPerformCorte: (Double) -> Unit
) {
    var cashCounted by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("REALIZAR CORTE", fontWeight = FontWeight.Black) },
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
            Text(
                "Resumen de Caja",
                style = MaterialTheme.typography.headlineSmall,
                color = PrimaryNavy,
                fontWeight = FontWeight.Bold
            )
            
            Spacer(Modifier.height(32.dp))

            // Simulación de valores ya que el POC usa estados globales
            ReportRow("Fondo Inicial:", "$100.00")
            ReportRow("Ventas Efectivo:", "$500.00")
            ReportRow("Gastos:", "$50.00")
            HorizontalDivider(Modifier.padding(vertical = 16.dp))
            ReportRow("Efectivo Esperado:", "$550.00", color = PrimaryNavy)

            Spacer(Modifier.height(48.dp))

            OutlinedTextField(
                value = cashCounted,
                onValueChange = { if (it.all { c -> c.isDigit() || c == '.' }) cashCounted = it },
                label = { Text("Efectivo en Caja (Real)") },
                modifier = Modifier.fillMaxWidth(),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                prefix = { Text("$") }
            )

            Spacer(Modifier.weight(1f))

            if (uiState.isClosing) {
                CircularProgressIndicator(color = PrimaryNavy)
            } else {
                Button(
                    onClick = { onPerformCorte(cashCounted.toDoubleOrNull() ?: 0.0) },
                    modifier = Modifier.fillMaxWidth().height(60.dp),
                    shape = RoundedCornerShape(16.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = SuccessGreen)
                ) {
                    Text("CERRAR CAJA Y TERMINAR TURNO", fontWeight = FontWeight.Black)
                }
            }
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun DailyCutPreview() {
    DailyCutContent(
        uiState = DailyCutUiState(),
        onBack = {},
        onPerformCorte = {}
    )
}

@Preview(showBackground = true, showSystemUi = true, name = "Cerrando Caja")
@Composable
fun DailyCutClosingPreview() {
    DailyCutContent(
        uiState = DailyCutUiState(isClosing = true),
        onBack = {},
        onPerformCorte = {}
    )
}

