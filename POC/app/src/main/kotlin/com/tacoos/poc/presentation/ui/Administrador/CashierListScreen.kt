package com.tacoos.poc.presentation.ui.Administrador

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.compose.ui.tooling.preview.Preview
import com.tacoos.poc.presentation.theme.PrimaryNavy
import com.tacoos.poc.presentation.uiState.business.CashierUiState
import com.tacoos.poc.presentation.viewmodel.business.CashierListViewModel

/**
 * Pantalla que muestra la lista de cajeros asociados al negocio.
 * Permite al administrador visualizar su equipo de trabajo.
 *
 * @param onBack Callback para regresar a la pantalla anterior.
 * @param viewModel ViewModel que gestiona el estado y la lógica de la lista de cajeros.
 */
@Composable
fun CashierListScreen(
    onBack: () -> Unit,
    viewModel: CashierListViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    CashierListContent(
        uiState = uiState,
        onBack = onBack,
        onRetry = { viewModel.loadCashiers() }
    )
}

/**
 * Contenido visual de la pantalla de lista de cajeros.
 *
 * @param uiState Estado actual de la lista de cajeros.
 * @param onBack Acción al presionar el botón de atrás.
 * @param onRetry Acción al presionar el botón de reintentar en caso de error.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CashierListContent(
    uiState: CashierUiState,
    onBack: () -> Unit,
    onRetry: () -> Unit
) {
    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text("MI EQUIPO", fontWeight = FontWeight.Black, letterSpacing = 1.sp) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Atrás")
                    }
                },
                colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                    containerColor = MaterialTheme.colorScheme.background
                )
            )
        }
    ) { padding ->
        Box(modifier = Modifier.fillMaxSize().padding(padding)) {
            if (uiState.isLoading) {
                CircularProgressIndicator(modifier = Modifier.align(Alignment.Center), color = PrimaryNavy)
            } else if (uiState.errorMessage != null) {
                Column(
                    modifier = Modifier.fillMaxSize().padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Text(uiState.errorMessage!!, color = MaterialTheme.colorScheme.error)
                    Spacer(modifier = Modifier.height(16.dp))
                    Button(onClick = onRetry) {
                        Text("Reintentar")
                    }
                }
            } else if (uiState.cashiers.isEmpty()) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Text("Aún no tienes cajeros registrados", color = Color.Gray)
                }
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(uiState.cashiers) { cashierName ->
                        CashierItem(name = cashierName)
                    }
                }
            }
        }
    }
}

/**
 * Componente que representa un elemento individual en la lista de cajeros.
 *
 * @param name Nombre del cajero a mostrar.
 */
@Composable
fun CashierItem(name: String) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = androidx.compose.foundation.shape.RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(Icons.Default.Person, contentDescription = null, tint = PrimaryNavy)
            Spacer(modifier = Modifier.width(16.dp))
            Text(text = name, fontWeight = FontWeight.Bold, fontSize = 16.sp)
        }
    }
}

/**
 * Previsualización de la pantalla de lista de cajeros.
 */
@Preview(showBackground = true, showSystemUi = true)
@Composable
fun CashierListPreview() {
    CashierListContent(
        uiState = CashierUiState(
            cashiers = listOf("Faner Santander", "Jesus Alejandro", "Maria Garcia"),
            isLoading = false
        ),
        onBack = {},
        onRetry = {}
    )
}
