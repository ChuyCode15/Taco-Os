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
import com.tacoos.poc.ui.components.AppDrawerContent
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
    isDarkMode: Boolean,
    onThemeChange: (Boolean) -> Unit,
    viewModel: ReportsViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val currencyFormatter = NumberFormat.getCurrencyInstance(Locale.US)
    
    val scope = rememberCoroutineScope()
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    
    var showRangeSheet by remember { mutableStateOf(false) }
    var showDateRangePicker by remember { mutableStateOf(false) }
    val sheetState = rememberModalBottomSheetState()
    val dateRangePickerState = rememberDateRangePickerState()


    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            AppDrawerContent(
                isDarkMode = isDarkMode,
                onThemeChange = onThemeChange,
                navController = navController,
                onClose = { scope.launch { drawerState.close() } }
            )
        }
    ) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text("REPORTES", fontWeight = FontWeight.Black, fontSize = 20.sp) },
                    navigationIcon = {
                        IconButton(onClick = { scope.launch { drawerState.open() } }) {
                            Icon(Icons.Default.Menu, contentDescription = "Menú")
                        }
                    },
                    actions = {
                        IconButton(onClick = { showRangeSheet = true }) {
                            Icon(Icons.Default.DateRange, contentDescription = "Rango", tint = ActionBlue)
                        }
                    }
                )
            }
        ) { padding ->
            Column(
                modifier = Modifier
                    .padding(padding)
                    .fillMaxSize()
                    .padding(20.dp)
                    .verticalScroll(rememberScrollState()),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(uiState.dateRange.uppercase(), style = MaterialTheme.typography.labelLarge, color = ActionBlue, fontWeight = FontWeight.Bold)
                Spacer(modifier = Modifier.height(24.dp))

                if (uiState.isLoading) {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator(color = ActionBlue)
                    }
                } else if (uiState.sales.isEmpty() && uiState.expenses.isEmpty()) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.padding(top = 100.dp)) {
                        Icon(Icons.Default.BarChart, null, modifier = Modifier.size(64.dp), tint = Color.LightGray)
                        Spacer(Modifier.height(16.dp))
                        Text("No hay movimientos en este periodo", color = Color.Gray)
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
                    if (uiState.cashierStats.isNotEmpty()) {
                        SectionHeader("POR CAJERO", Icons.Default.Groups)
                        uiState.cashierStats.forEach { StatItem(it.name, currencyFormatter.format(it.totalSales), "${it.salesCount} ventas") }
                    }

                    Spacer(modifier = Modifier.height(32.dp))

                    // Top Productos
                    if (uiState.productStats.isNotEmpty()) {
                        SectionHeader("TOP PRODUCTOS", Icons.Default.Inventory2)
                        uiState.productStats.take(10).forEach { StatItem(it.name, "${it.quantitySold} uds", "Total: ${currencyFormatter.format(it.totalSales)}") }
                    }
                }
            }
        }
    }

    if (showRangeSheet) {
        ModalBottomSheet(onDismissRequest = { showRangeSheet = false }, sheetState = sheetState) {
            Column(modifier = Modifier.padding(16.dp).padding(bottom = 32.dp).fillMaxWidth()) {
                Text("Filtrar Periodo", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Black, modifier = Modifier.padding(16.dp))
                RangeOption("Hoy", Icons.Default.Today) { viewModel.loadPreset("HOY"); showRangeSheet = false }
                RangeOption("Ayer", Icons.Default.History) { viewModel.loadPreset("AYER"); showRangeSheet = false }
                RangeOption("Últimos 7 días", Icons.Default.DateRange) { viewModel.loadPreset("SEMANA"); showRangeSheet = false }
                RangeOption("Este mes", Icons.Default.CalendarMonth) { viewModel.loadPreset("MES"); showRangeSheet = false }
                RangeOption("Fecha manual", Icons.Default.EditCalendar) { 
                    showDateRangePicker = true 
                    showRangeSheet = false 
                }
            }
        }
    }

    if (showDateRangePicker) {
        DatePickerDialog(
            onDismissRequest = { showDateRangePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    val start = dateRangePickerState.selectedStartDateMillis
                    val end = dateRangePickerState.selectedEndDateMillis
                    if (start != null && end != null) {
                        val calEnd = Calendar.getInstance().apply {
                            timeInMillis = end
                            set(Calendar.HOUR_OF_DAY, 23)
                            set(Calendar.MINUTE, 59)
                            set(Calendar.SECOND, 59)
                        }
                        viewModel.loadReport(start, calEnd.timeInMillis)
                        showDateRangePicker = false
                    }
                }) { Text("ACEPTAR", fontWeight = FontWeight.Bold) }
            },
            dismissButton = {
                TextButton(onClick = { showDateRangePicker = false }) { Text("CANCELAR") }
            }
        ) {
            DateRangePicker(
                state = dateRangePickerState,
                title = { Text("Selecciona el rango", modifier = Modifier.padding(16.dp), fontWeight = FontWeight.Bold) },
                modifier = Modifier.weight(1f)
            )
        }
    }
}

@Composable
fun RangeOption(label: String, icon: ImageVector, onClick: () -> Unit) {
    Surface(
        modifier = Modifier.fillMaxWidth().clickable { onClick() },
        color = Color.Transparent
    ) {
        Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            Icon(icon, null, tint = ActionBlue, modifier = Modifier.size(24.dp))
            Spacer(Modifier.width(16.dp))
            Text(label, fontSize = 16.sp, fontWeight = FontWeight.Medium)
        }
    }
}

@Composable
fun SectionHeader(title: String, icon: ImageVector) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Icon(icon, null, tint = ActionBlue, modifier = Modifier.size(18.dp))
        Spacer(modifier = Modifier.width(8.dp))
        Text(title, fontWeight = FontWeight.Black, color = PrimaryNavy, letterSpacing = 1.sp, fontSize = 12.sp)
    }
    Spacer(Modifier.height(12.dp))
}

@Composable
fun StatItem(name: String, value: String, subtitle: String) {
    Surface(
        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f),
        shape = RoundedCornerShape(16.dp)
    ) {
        Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            Column(modifier = Modifier.weight(1f)) {
                Text(name, fontWeight = FontWeight.Bold, fontSize = 15.sp)
                Text(subtitle, fontSize = 11.sp, color = Color.Gray)
            }
            Text(value, fontWeight = FontWeight.Black, color = PrimaryNavy)
        }
    }
}

@Composable
fun ReportCardSmall(title: String, amount: String, color: Color, modifier: Modifier = Modifier) {
    Card(modifier = modifier, shape = RoundedCornerShape(16.dp), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(title, fontSize = 10.sp, color = Color.Gray, fontWeight = FontWeight.Bold)
            Text(amount, fontSize = 18.sp, fontWeight = FontWeight.Black, color = color)
        }
    }
}

@Composable
fun ReportCard(title: String, amount: String, color: Color) {
    Card(modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(20.dp), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))) {
        Column(modifier = Modifier.padding(20.dp)) {
            Text(title, fontSize = 12.sp, color = Color.Gray, fontWeight = FontWeight.Bold)
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

    init { loadPreset("HOY") }

    fun loadPreset(preset: String) {
        val calendar = Calendar.getInstance()
        val end = System.currentTimeMillis()
        var start = end
        when (preset) {
            "HOY" -> { 
                calendar.set(Calendar.HOUR_OF_DAY, 0); calendar.set(Calendar.MINUTE, 0); 
                calendar.set(Calendar.SECOND, 0); start = calendar.timeInMillis 
            }
            "AYER" -> { 
                calendar.add(Calendar.DAY_OF_YEAR, -1)
                calendar.set(Calendar.HOUR_OF_DAY, 0); calendar.set(Calendar.MINUTE, 0); start = calendar.timeInMillis
                val calEnd = Calendar.getInstance().apply { 
                    add(Calendar.DAY_OF_YEAR, -1)
                    set(Calendar.HOUR_OF_DAY, 23); set(Calendar.MINUTE, 59) 
                }
                loadReport(start, calEnd.timeInMillis); return
            }
            "SEMANA" -> { calendar.add(Calendar.DAY_OF_YEAR, -7); start = calendar.timeInMillis }
            "MES" -> { calendar.set(Calendar.DAY_OF_MONTH, 1); start = calendar.timeInMillis }
        }
        loadReport(start, end)
    }

    fun loadReport(startDate: Long, endDate: Long) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            val user = db.userDao().getCurrentUser()
            val negocioId = user?.negocioId ?: ""

            if (negocioId.isEmpty()) {
                _uiState.value = _uiState.value.copy(isLoading = false)
                return@launch
            }

            val sales = db.saleDao().getSalesByRange(negocioId, startDate, endDate).filter { it.status == "ACTIVE" }
            val expenses = db.expenseDao().getExpensesByRange(negocioId, startDate, endDate)
            val cashiers = db.userDao().getCashiers(negocioId)

            val productMap = mutableMapOf<String, ProductStat>()
            val type = object : TypeToken<List<Map<String, Any>>>() {}.type
            
            sales.forEach { sale ->
                try {
                    val products: List<Map<String, Any>> = gson.fromJson(sale.productsJson, type) ?: emptyList()
                    products.forEach { p ->
                        val name = p["name"] as? String ?: "Producto"
                        val qty = (p["quantity"] as? Number)?.toInt() ?: (p["qty"] as? Number)?.toInt() ?: 1
                        val price = (p["price"] as? Number)?.toDouble() ?: 0.0
                        
                        val current = productMap[name] ?: ProductStat(name, 0.0, 0)
                        productMap[name] = current.copy(
                            quantitySold = current.quantitySold + qty,
                            totalSales = current.totalSales + (price * qty)
                        )
                    }
                } catch (e: Exception) {
                    val current = productMap["Otros"] ?: ProductStat("Otros", 0.0, 0)
                    productMap["Otros"] = current.copy(
                        quantitySold = current.quantitySold + 1,
                        totalSales = current.totalSales + sale.amount
                    )
                }
            }

            _uiState.value = ReportsState(
                sales = sales,
                expenses = expenses,
                totalSales = sales.sumOf { it.amount },
                totalExpenses = expenses.sumOf { it.amount },
                cashierStats = sales.groupBy { it.userId }.map { (uid, uSales) ->
                    val name = if (uid == user?.id) user.nombre else cashiers.find { it.id == uid }?.nombre ?: "Cajero"
                    CashierStat(name, uSales.sumOf { it.amount }, uSales.size)
                }.sortedByDescending { it.totalSales },
                productStats = productMap.values.sortedByDescending { it.quantitySold },
                dateRange = "Del ${SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()).format(Date(startDate))} al ${SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()).format(Date(endDate))}",
                isLoading = false
            )
        }
    }
}
