package com.tacoos.poc.presentation.ui.ops

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.MoneyOff
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
import com.tacoos.poc.domain.model.Expense
import com.tacoos.poc.presentation.theme.ActionBlue
import com.tacoos.poc.presentation.uiState.ops.ExpenseUiState
import com.tacoos.poc.presentation.viewmodel.ops.ExpenseViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExpenseScreen(
    navController: NavController,
    shiftId: Long,
    viewModel: ExpenseViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(shiftId) {
        viewModel.loadExpenses(shiftId)
    }

    ExpenseContent(
        uiState = uiState,
        onBack = { navController.popBackStack() }
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExpenseContent(
    uiState: ExpenseUiState,
    onBack: () -> Unit
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("GASTOS DEL TURNO", fontWeight = FontWeight.Black) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, null)
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(onClick = { /* TODO */ }, containerColor = ActionBlue, contentColor = Color.White) {
                Icon(Icons.Default.Add, "Nuevo Gasto")
            }
        }
    ) { padding ->
        if (uiState.isLoading) {
            Box(Modifier.fillMaxSize().padding(padding), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = ActionBlue)
            }
        } else if (uiState.expenses.isEmpty()) {
            Column(
                modifier = Modifier.fillMaxSize().padding(padding),
                verticalArrangement = Arrangement.Center,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Icon(Icons.Default.MoneyOff, null, modifier = Modifier.size(64.dp), tint = Color.LightGray)
                Spacer(Modifier.height(16.dp))
                Text("No hay gastos registrados", color = Color.Gray)
            }
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize().padding(padding),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(uiState.expenses) { expense ->
                    ExpenseRow(expense)
                }
            }
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun ExpensePreview() {
    ExpenseContent(
        uiState = ExpenseUiState(
            expenses = listOf(
                Expense("1", "Compra de servilletas", 150.0, "Limpieza", System.currentTimeMillis(), "Cajero 1"),
                Expense("2", "Reparación de mesa", 300.0, "Mantenimiento", System.currentTimeMillis(), "Cajero 1")
            )
        ),
        onBack = {}
    )
}

@Preview(showBackground = true, showSystemUi = true, name = "Cargando")
@Composable
fun ExpenseLoadingPreview() {
    ExpenseContent(
        uiState = ExpenseUiState(isLoading = true),
        onBack = {}
    )
}

@Preview(showBackground = true, showSystemUi = true, name = "Vacío")
@Composable
fun ExpenseEmptyPreview() {
    ExpenseContent(
        uiState = ExpenseUiState(expenses = emptyList()),
        onBack = {}
    )
}


@Composable
fun ExpenseRow(expense: Expense) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(expense.detail, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                Text(expense.category, color = Color.Gray, fontSize = 12.sp)
            }
            Text(
                "-$${expense.amount}",
                fontWeight = FontWeight.Black,
                color = Color.Red,
                fontSize = 18.sp
            )
        }
    }
}
