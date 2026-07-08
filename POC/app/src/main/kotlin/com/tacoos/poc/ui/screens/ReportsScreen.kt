package com.tacoos.poc.ui.screens

import android.app.Application
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.tacoos.poc.TacoApp
import com.tacoos.poc.data.local.Sale
import com.tacoos.poc.data.local.Expense
import com.tacoos.poc.ui.theme.ActionBlue
import com.tacoos.poc.ui.theme.PrimaryNavy
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import java.text.NumberFormat
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ReportsScreen(
    navController: NavController,
    viewModel: ReportsViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val currencyFormatter = NumberFormat.getCurrencyInstance(Locale.US)
    
    // Estados para el selector de fechas
    var showRangeSheet by remember { mutableStateOf(false) }
    var showCustomRangePicker by remember { mutableStateOf(false) }
    val sheetState = rememberModalBottomSheetState()
    val dateRangePickerState = rememberDateRangePickerState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("REPORTES AVANZADOS", fontWeight = FontWeight.Black, fontSize = 18.sp) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Atrás")
                    }
                },
                actions = {
                    IconButton(onClick = { showRangeSheet = true }) {
                        Icon(Icons.Default.DateRange, contentDescription = "Rango")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .fillMaxSize()
                .padding(24.dp)
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(uiState.dateRange, style = MaterialTheme.typography.labelLarge, color = ActionBlue)
            Spacer(modifier = Modifier.height(24.dp))

            if (uiState.isLoading) {
                Box(modifier = Modifier.fillMaxWidth().height(200.dp), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = PrimaryNavy)
                }
            } else if (uiState.sales.isEmpty() && uiState.expenses.isEmpty()) {
                Box(modifier = Modifier.fillMaxWidth().height(200.dp), contentAlignment = Alignment.Center) {
                    Text("No se encontraron datos", color = Color.Gray, fontSize = 14.sp)
                }
            } else {
                // Resumen Financiero
                Row(modifier = Modifier.fillMaxWidth()) {
                    ReportCardSmall("INGRESOS", currencyFormatter.format(uiState.totalSales), Color(0xFF4CAF50), Modifier.weight(1f))
                    Spacer(modifier = Modifier.width(12.dp))
                    ReportCardSmall("GASTOS", currencyFormatter.format(uiState.totalExpenses), Color(0xFFF44336), Modifier.weight(1f))
                }
                Spacer(modifier = Modifier.height(12.dp))
                ReportCard("BALANCE NETO", currencyFormatter.format(uiState.totalSales - uiState.totalExpenses), PrimaryNavy)
                
                Spacer(modifier = Modifier.height(32.dp))

                // Estadísticas por Cajero
                SectionHeader("RENDIMIENTO POR CAJERO", Icons.Default.Groups)
                Spacer(modifier = Modifier.height(12.dp))
                uiState.cashierStats.forEach { stat ->
                    StatItem(
                        name = stat.name,
                        value = currencyFormatter.format(stat.totalSales),
                        subtitle = "${stat.salesCount} ventas realizadas"
                    )
                }

                Spacer(modifier = Modifier.height(32.dp))

                // Estadísticas por Producto
                SectionHeader("PRODUCTOS MÁS VENDIDOS", Icons.Default.Inventory2)
                Spacer(modifier = Modifier.height(12.dp))
                uiState.productStats.take(5).forEach { stat ->
                    StatItem(
                        name = stat.name,
                        value = "${stat.quantitySold} uds",
                        subtitle = "Total: ${currencyFormatter.format(stat.totalSales)}"
                    )
                }
                
                Spacer(modifier = Modifier.height(40.dp))
            }
        }
    }

    // Modal para presets rápidos (Pop-up desde abajo)
    if (showRangeSheet) {
        ModalBottomSheet(
            onDismissRequest = { showRangeSheet = false },
            sheetState = sheetState,
            containerColor = MaterialTheme.colorScheme.surface
        ) {
            Column(modifier = Modifier.padding(16.dp).padding(bottom = 32.dp).fillMaxWidth()) {
                Text("Seleccionar Periodo", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold, modifier = Modifier.padding(horizontal = 16.dp))
                Spacer(Modifier.height(16.dp))
                
                RangeOption("Hoy", Icons.Default.Today) { viewModel.loadPreset("HOY"); showRangeSheet = false }
                RangeOption("Ayer", Icons.Default.History) { viewModel.loadPreset("AYER"); showRangeSheet = false }
                RangeOption("Últimos 7 días", Icons.Default.DateRange) { viewModel.loadPreset("SEMANA"); showRangeSheet = false }
                RangeOption("Este mes", Icons.Default.CalendarMonth) { viewModel.loadPreset("MES"); showRangeSheet = false }
                RangeOption("Este año", Icons.Default.CalendarToday) { viewModel.loadPreset("AÑO"); showRangeSheet = false }
                
                Divider(modifier = Modifier.padding(vertical = 8.dp), color = Color.LightGray.copy(alpha = 0.3f))
                
                RangeOption("Rango personalizado", Icons.Default.EditCalendar) { 
                    showRangeSheet = false
                    showCustomRangePicker = true 
                }
            }
        }
    }

    // Pop-up para rango personalizado (Calendario)
    if (showCustomRangePicker) {
        DatePickerDialog(
            onDismissRequest = { showCustomRangePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    val start = dateRangePickerState.selectedStartDateMillis
                    val end = dateRangePickerState.selectedEndDateMillis
                    if (start != null && end != null) {
                        viewModel.loadReport(start, end)
                    }
                    showCustomRangePicker = false
                }) { Text("Aplicar") }
            },
            dismissButton = {
                TextButton(onClick = { showCustomRangePicker = false }) { Text("Cancelar") }
            }
        ) {
            DateRangePicker(
                state = dateRangePickerState,
                title = { Text("Selecciona el rango", modifier = Modifier.padding(16.dp)) },
                showModeToggle = false,
                modifier = Modifier.weight(1f)
            )
        }
    }
}

@Composable
fun RangeOption(label: String, icon: ImageVector, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(icon, contentDescription = null, tint = ActionBlue, modifier = Modifier.size(24.dp))
        Spacer(Modifier.width(16.dp))
        Text(label, fontSize = 16.sp, fontWeight = FontWeight.Medium)
    }
}

@Composable
fun SectionHeader(title: String, icon: ImageVector) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(icon, contentDescription = null, tint = ActionBlue, modifier = Modifier.size(20.dp))
        Spacer(modifier = Modifier.width(8.dp))
        Text(
            text = title,
            style = MaterialTheme.typography.labelLarge,
            fontWeight = FontWeight.Bold,
            color = PrimaryNavy,
            letterSpacing = 1.sp
        )
    }
}

@Composable
fun StatItem(name: String, value: String, subtitle: String) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f),
        shape = RoundedCornerShape(12.dp)
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(name, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                Text(subtitle, fontSize = 12.sp, color = Color.Gray)
            }
            Text(value, fontWeight = FontWeight.Black, color = PrimaryNavy, fontSize = 16.sp)
        }
    }
}

@Composable
fun ReportCardSmall(title: String, amount: String, color: Color, modifier: Modifier = Modifier) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(title, style = MaterialTheme.typography.labelSmall, color = Color.Gray)
            Text(amount, fontSize = 18.sp, fontWeight = FontWeight.Black, color = color)
        }
    }
}

@Composable
fun ReportCard(title: String, amount: String, color: Color) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))
    ) {
        Column(modifier = Modifier.padding(24.dp)) {
            Text(title, style = MaterialTheme.typography.labelMedium, color = Color.Gray)
            Text(amount, fontSize = 28.sp, fontWeight = FontWeight.Black, color = color)
        }
    }
}

data class CashierStat(val name: String, val totalSales: Double, val salesCount: Int)
data class ProductStat(val name: String, val totalSales: Double, val quantitySold: Int)

data class ReportsState(
    val sales: List<Sale> = emptyList(),
    val expenses: List<Expense> = emptyList(),
    val totalSales: Double = 0.0,
    val totalExpenses: Double = 0.0,
    val cashierStats: List<CashierStat> = emptyList(),
    val productStats: List<ProductStat> = emptyList(),
    val dateRange: String = "",
    val isLoading: Boolean = false
)

class ReportsViewModel(application: Application) : AndroidViewModel(application) {
    private val app = application as TacoApp
    private val db = app.database
    private val gson = Gson()

    private val _uiState = MutableStateFlow(ReportsState())
    val uiState: StateFlow<ReportsState> = _uiState

    init {
        loadPreset("HOY")
    }

    fun loadPreset(preset: String) {
        val calendar = Calendar.getInstance()
        val end = System.currentTimeMillis()
        var start = end

        when (preset) {
            "HOY" -> {
                calendar.set(Calendar.HOUR_OF_DAY, 0)
                calendar.set(Calendar.MINUTE, 0)
                calendar.set(Calendar.SECOND, 0)
                start = calendar.timeInMillis
            }
            "AYER" -> {
                calendar.add(Calendar.DAY_OF_YEAR, -1)
                calendar.set(Calendar.HOUR_OF_DAY, 0)
                calendar.set(Calendar.MINUTE, 0)
                calendar.set(Calendar.SECOND, 0)
                start = calendar.timeInMillis
                
                val calendarEnd = Calendar.getInstance().apply {
                    add(Calendar.DAY_OF_YEAR, -1)
                    set(Calendar.HOUR_OF_DAY, 23)
                    set(Calendar.MINUTE, 59)
                    set(Calendar.SECOND, 59)
                }
                loadReport(start, calendarEnd.timeInMillis)
                return
            }
            "SEMANA" -> {
                calendar.add(Calendar.DAY_OF_YEAR, -7)
                start = calendar.timeInMillis
            }
            "MES" -> {
                calendar.set(Calendar.DAY_OF_MONTH, 1)
                calendar.set(Calendar.HOUR_OF_DAY, 0)
                calendar.set(Calendar.MINUTE, 0)
                calendar.set(Calendar.SECOND, 0)
                start = calendar.timeInMillis
            }
            "AÑO" -> {
                calendar.set(Calendar.DAY_OF_YEAR, 1)
                calendar.set(Calendar.HOUR_OF_DAY, 0)
                calendar.set(Calendar.MINUTE, 0)
                calendar.set(Calendar.SECOND, 0)
                start = calendar.timeInMillis
            }
        }
        loadReport(start, end)
    }

    fun loadReport(startDate: Long, endDate: Long) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            val user = db.userDao().getCurrentUser()
            val negocioId = user?.negocioId ?: return@launch

            val sales = db.saleDao().getSalesByRange(negocioId, startDate, endDate).filter { it.status == "ACTIVE" }
            val expenses = db.expenseDao().getExpensesByRange(negocioId, startDate, endDate)
            val cashiers = db.userDao().getCashiers(negocioId)

            val cashierStats = sales.groupBy { it.userId }.map { (userId, userSales) ->
                val name = cashiers.find { it.id == userId }?.nombre ?: "Cajero Desconocido"
                CashierStat(name, userSales.sumOf { it.amount }, userSales.size)
            }.sortedByDescending { it.totalSales }

            val productMap = mutableMapOf<String, ProductStat>()
            val type = object : TypeToken<List<Map<String, Any>>>() {}.type
            
            sales.forEach { sale ->
                try {
                    val products: List<Map<String, Any>> = gson.fromJson(sale.productsJson, type) ?: emptyList()
                    if (products.isNotEmpty()) {
                        products.forEach { p ->
                            val name = p["name"] as? String ?: "Producto"
                            val qty = (p["qty"] as? Number)?.toInt() ?: 0
                            val current = productMap[name] ?: ProductStat(name, 0.0, 0)
                            productMap[name] = current.copy(
                                quantitySold = current.quantitySold + qty,
                                totalSales = current.totalSales + (sale.amount / products.size)
                            )
                        }
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            val productStats = productMap.values.sortedByDescending { it.quantitySold }

            _uiState.value = ReportsState(
                sales = sales,
                expenses = expenses,
                totalSales = sales.sumOf { it.amount },
                totalExpenses = expenses.sumOf { it.amount },
                cashierStats = cashierStats,
                productStats = productStats,
                dateRange = "Del ${formatDate(startDate)} al ${formatDate(endDate)}",
                isLoading = false
            )
        }
    }

    private fun formatDate(ts: Long): String {
        val sdf = SimpleDateFormat("dd/MM/yyyy", Locale.getDefault())
        return sdf.format(Date(ts))
    }
}
