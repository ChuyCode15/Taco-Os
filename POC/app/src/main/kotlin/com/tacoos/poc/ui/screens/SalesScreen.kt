package com.tacoos.poc.ui.screens

import android.graphics.Bitmap
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.result.launch
import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.tacoos.poc.ui.components.ActionButton
import com.tacoos.poc.ui.components.AppleToggle
import com.tacoos.poc.ui.components.ReportRow
import com.tacoos.poc.ui.components.TacoDialog
import com.tacoos.poc.ui.theme.ActionBlue
import com.tacoos.poc.ui.theme.PrimaryNavy
import com.tacoos.poc.ui.theme.SuccessGreen
import com.tacoos.poc.ui.theme.WarningAmber
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

/**
 * SalesScreen: Pantalla principal del Punto de Venta (POS).
 * Inyección de dependencias: NavController para navegación.
 * Manejo de estado: Utiliza ShiftManager para la persistencia del turno activo.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SalesScreen(
    navController: NavController,
    isDarkMode: Boolean,
    onThemeChange: (Boolean) -> Unit
) {
    val scope = rememberCoroutineScope()
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val context = LocalContext.current

    // Estado local para la venta seleccionada en la lista
    var selectedSale by remember { mutableStateOf<POSSale?>(null) }

    // Controladores de visibilidad para diálogos
    var showOpeningDialog by remember { mutableStateOf(false) }
    var showNewSalePopup by remember { mutableStateOf(false) }
    var showCortePopup by remember { mutableStateOf(false) }
    var showExpensePopup by remember { mutableStateOf(false) }

    // Feedback visual para transacciones
    var transactionSuccessMessage by remember { mutableStateOf<String?>(null) }
    var transactionErrorMessage by remember { mutableStateOf<String?>(null) }

    val dateFormat = SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.getDefault())

    // Lógica de auto-cierre para alertas transaccionales (1.5 segundos)
    LaunchedEffect(transactionSuccessMessage) {
        if (transactionSuccessMessage != null) {
            delay(1500)
            transactionSuccessMessage = null
        }
    }
    LaunchedEffect(transactionErrorMessage) {
        if (transactionErrorMessage != null) {
            delay(1500)
            transactionErrorMessage = null
        }
    }

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            ModalDrawerSheet(
                modifier = Modifier.width(300.dp),
                drawerContainerColor = MaterialTheme.colorScheme.surface,
                drawerShape = RoundedCornerShape(topEnd = 24.dp, bottomEnd = 24.dp)
            ) {
                Spacer(Modifier.height(48.dp))
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 24.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text("MENU", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Black)
                    AppleToggle(checked = isDarkMode, onCheckedChange = onThemeChange)
                }
                Spacer(Modifier.height(16.dp))
                NavigationDrawerItem(
                    label = { Text("Ajustes") },
                    selected = false,
                    onClick = { scope.launch { drawerState.close() }; navController.navigate("settings") },
                    icon = { Icon(Icons.Default.Settings, null) })
                Spacer(modifier = Modifier.weight(1f))
                Text(
                    "Cerrar Sesión",
                    modifier = Modifier
                        .padding(24.dp)
                        .clickable { navController.navigate("login") { popUpTo(0) } },
                    color = Color.Red,
                    fontWeight = FontWeight.Black
                )
            }
        }
    ) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text("VENTAS", fontWeight = FontWeight.Black) },
                    navigationIcon = {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            IconButton(onClick = { navController.popBackStack() }) {
                                Icon(Icons.Default.ArrowBack, null)
                            }
                            IconButton(onClick = { scope.launch { drawerState.open() } }) {
                                Icon(Icons.Default.Menu, null)
                            }
                        }
                    }
                )
            }
        ) { padding ->
            Box(modifier = Modifier.fillMaxSize().padding(padding)) {
                Column(modifier = Modifier.fillMaxSize()) {
                    // Barra de Información Superior
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(Color.LightGray.copy(alpha = 0.1f))
                            .padding(12.dp),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()).format(Date()),
                            fontWeight = FontWeight.Bold,
                            color = Color.Gray
                        )
                        Text(
                            GoogleSignInState.nombre.ifEmpty { "Usuario" },
                            fontWeight = FontWeight.Bold,
                            color = ActionBlue
                        )
                    }

                    if (!ShiftManager.isShiftOpen) {
                        // Bloqueo de Caja
                        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Icon(Icons.Default.Lock, null, modifier = Modifier.size(100.dp), tint = Color.LightGray.copy(alpha = 0.5f))
                                Spacer(Modifier.height(16.dp))
                                Text("LA CAJA ESTÁ CERRADA", fontWeight = FontWeight.Black, color = Color.Gray)
                                Spacer(Modifier.height(32.dp))
                                Button(
                                    onClick = { showOpeningDialog = true },
                                    shape = RoundedCornerShape(20.dp),
                                    modifier = Modifier.height(60.dp).fillMaxWidth(0.6f)
                                ) {
                                    Text("ABRIR CAJA", fontWeight = FontWeight.Black)
                                }
                            }
                        }
                    } else {
                        // Dashboard de Turno Activo
                        Column(modifier = Modifier.weight(1f).padding(16.dp)) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text("CORTE ACTIVO", style = MaterialTheme.typography.labelSmall, fontWeight = FontWeight.Bold)
                                Spacer(Modifier.width(8.dp))
                                Box(modifier = Modifier.size(8.dp).clip(CircleShape).background(SuccessGreen))
                            }
                            Text("Abierta: ${dateFormat.format(Date(ShiftManager.openTimestamp))}", fontSize = 10.sp, color = Color.Gray)
                            Spacer(Modifier.height(16.dp))
                            Surface(
                                modifier = Modifier.weight(1f).fillMaxWidth(),
                                shape = RoundedCornerShape(24.dp),
                                color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.2f),
                                border = androidx.compose.foundation.BorderStroke(1.dp, Color.LightGray.copy(alpha = 0.3f))
                            ) {
                                if (ShiftManager.sales.isEmpty()) {
                                    Box(contentAlignment = Alignment.Center) { Text("Sin ventas en este corte", color = Color.Gray) }
                                } else {
                                    LazyColumn {
                                        items(ShiftManager.sales) { sale ->
                                            SaleRow(sale, isSelected = selectedSale?.id == sale.id) { selectedSale = sale }
                                        }
                                    }
                                }
                            }
                            Row(modifier = Modifier.fillMaxWidth().padding(vertical = 16.dp), horizontalArrangement = Arrangement.SpaceEvenly, verticalAlignment = Alignment.CenterVertically) {
                                ActionButton(Icons.Default.Close, "Cancelar", Color.Red) {
                                    selectedSale?.let {
                                        if (System.currentTimeMillis() - it.timestamp < 300000) {
                                            ShiftManager.sales[ShiftManager.sales.indexOf(it)] = it.copy(status = "Cancelada")
                                            selectedSale = null
                                        } else {
                                            Toast.makeText(context, "Registro inmutable (> 5 min)", Toast.LENGTH_SHORT).show()
                                        }
                                    }
                                }
                                ActionButton(Icons.Default.ShoppingCart, "Gasto", WarningAmber) { showExpensePopup = true }
                                ActionButton(Icons.Default.Add, "Venta", SuccessGreen) { showNewSalePopup = true }
                            }
                            Button(
                                onClick = { showCortePopup = true },
                                modifier = Modifier.fillMaxWidth().height(60.dp),
                                shape = RoundedCornerShape(16.dp),
                                colors = ButtonDefaults.buttonColors(containerColor = PrimaryNavy)
                            ) {
                                Text("CERRAR CORTE", fontWeight = FontWeight.Black)
                            }
                        }
                    }
                }

                // Alertas transaccionales
                if (transactionSuccessMessage != null) TransactionBanner(transactionSuccessMessage!!, SuccessGreen)
                if (transactionErrorMessage != null) TransactionBanner(transactionErrorMessage!!, Color.Red)
            }
        }
    }

    // --- FORMULARIOS ---

    if (showOpeningDialog) {
        OpeningForm(onDismiss = { showOpeningDialog = false }) { fondo ->
            ShiftManager.fondoCaja = fondo
            ShiftManager.isShiftOpen = true
            ShiftManager.openTimestamp = System.currentTimeMillis()
            ShiftManager.currentCashier = GoogleSignInState.nombre
            showOpeningDialog = false
        }
    }

    if (showNewSalePopup) {
        NewSaleDialog(
            onDismiss = { showNewSalePopup = false },
            onConfirm = { sale ->
                try {
                    ShiftManager.sales.add(0, sale)
                    transactionSuccessMessage = "Se cobraron $${sale.amount} con éxito"
                    showNewSalePopup = false
                } catch (e: Exception) {
                    transactionErrorMessage = "Fallo el cobro"
                }
            }
        )
    }

    if (showExpensePopup) {
        ExpenseDialog(
            onDismiss = { showExpensePopup = false },
            onConfirm = { expense ->
                ShiftManager.expenses.add(expense)
                showExpensePopup = false
                Toast.makeText(context, "Gasto registrado", Toast.LENGTH_SHORT).show()
            }
        )
    }

    if (showCortePopup) {
        CorteDialog(
            onDismiss = { showCortePopup = false },
            onConfirm = {
                ShiftManager.isShiftOpen = false
                ShiftManager.sales.clear()
                ShiftManager.expenses.clear()
                showCortePopup = false
                navController.popBackStack()
            }
        )
    }
}

/**
 * TransactionBanner: Notificación superior temporal.
 */
@Composable
fun TransactionBanner(message: String, color: Color) {
    Box(
        modifier = Modifier.fillMaxWidth().height(50.dp).background(color),
        contentAlignment = Alignment.Center
    ) {
        Text(message, color = Color.White, fontWeight = FontWeight.Bold)
    }
}

/**
 * OpeningForm: Diálogo para apertura de caja.
 * @param onDismiss Acción al cancelar.
 * @param onConfirm Acción al confirmar con el monto inicial.
 */
@Composable
fun OpeningForm(onDismiss: () -> Unit, onConfirm: (Double) -> Unit) {
    var fondoInput by remember { mutableStateOf("") }
    TacoDialog(
        title = "Abrir Caja",
        onDismiss = onDismiss,
        confirmButton = { Button(onClick = { onConfirm(fondoInput.toDoubleOrNull() ?: 0.0) }) { Text("ACEPTAR") } },
        dismissButton = { TextButton(onClick = onDismiss) { Text("CANCELAR") } }
    ) {
        Text("¿Deseas ingresar un fondo de caja?")
        Spacer(Modifier.height(16.dp))
        OutlinedTextField(
            value = fondoInput,
            onValueChange = { if (it.all { c -> c.isDigit() }) fondoInput = it },
            label = { Text("Cantidad") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            modifier = Modifier.fillMaxWidth()
        )
    }
}

/**
 * SaleRow: Fila de la lista de ventas.
 */
@Composable
fun SaleRow(sale: POSSale, isSelected: Boolean, onClick: () -> Unit) {
    val statusColor = if (sale.status == "Cancelada") Color.Red else (if (sale.method == "Efectivo") SuccessGreen else ActionBlue)
    Row(
        modifier = Modifier.fillMaxWidth().background(if (isSelected) ActionBlue.copy(alpha = 0.1f) else Color.Transparent).clickable { onClick() }.padding(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(modifier = Modifier.size(10.dp).clip(CircleShape).background(statusColor))
        Spacer(Modifier.width(12.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text("Venta #${sale.id.take(4)}", fontWeight = FontWeight.Bold)
            Text(sale.method, fontSize = 12.sp, color = Color.Gray)
        }
        Text("$${sale.amount}", fontWeight = FontWeight.Black, color = if (sale.status == "Cancelada") Color.Red else PrimaryNavy)
    }
}

/**
 * NewSaleDialog: Proceso de nueva venta con pasos dinámicos.
 * @param onDismiss Acción al cancelar.
 * @param onConfirm Acción al completar la venta.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NewSaleDialog(onDismiss: () -> Unit, onConfirm: (POSSale) -> Unit) {
    var step by remember { mutableStateOf(1) } // 1: Nota, 2: Productos
    val saleDetails = remember { mutableStateListOf<POSItem>() }
    var selectedCategory by remember { mutableStateOf("Comidas") }
    var showCobroPopup by remember { mutableStateOf(false) }

    val products = listOf(
        POSItem("Taco Pastor", 15.0, "Comidas"),
        POSItem("Taco Bistec", 18.0, "Comidas"),
        POSItem("Coca 600ml", 20.0, "Bebidas"),
        POSItem("Fanta 600ml", 20.0, "Bebidas"),
        POSItem("Flan", 35.0, "Postres")
    )

    TacoDialog(
        title = if (step == 1) "Nota de Venta" else "Agregar Producto",
        onDismiss = onDismiss,
        navigationIcon = if (step > 1) Icons.Default.ArrowBack else null,
        onNavigationClick = { step = 1 }
    ) {
        if (step == 1) {
            Column {
                Box(modifier = Modifier.weight(1f)) {
                    if (saleDetails.isEmpty()) {
                        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) { Text("Sin productos", color = Color.Gray) }
                    } else {
                        LazyColumn { items(saleDetails) { item -> Row(modifier = Modifier.fillMaxWidth().padding(4.dp)) { Text("${item.quantity}x ${item.name}", modifier = Modifier.weight(1f)); Text("$${item.price * item.quantity}") } } }
                    }
                }
                TextButton(onClick = { step = 2 }, modifier = Modifier.fillMaxWidth()) { Text("+ AGREGAR PRODUCTO", color = ActionBlue, fontWeight = FontWeight.Bold) }
                if (saleDetails.isNotEmpty()) {
                    Button(onClick = { showCobroPopup = true }, modifier = Modifier.fillMaxWidth().height(50.dp), shape = RoundedCornerShape(16.dp)) { Text("COBRAR", fontWeight = FontWeight.Black) }
                }
            }
        } else {
            Column {
                Row(modifier = Modifier.fillMaxWidth().background(Color.LightGray.copy(alpha = 0.1f), RoundedCornerShape(12.dp))) {
                    listOf("Comidas", "Bebidas", "Postres").forEach { cat ->
                        Box(
                            modifier = Modifier.weight(1f).height(40.dp).clip(RoundedCornerShape(12.dp))
                                .background(if (selectedCategory == cat) ActionBlue else Color.Transparent)
                                .clickable { selectedCategory = cat },
                            contentAlignment = Alignment.Center
                        ) { Text(cat, color = if (selectedCategory == cat) Color.White else Color.Gray, fontWeight = FontWeight.Bold, fontSize = 11.sp) }
                    }
                }
                Spacer(Modifier.height(8.dp))
                LazyColumn(modifier = Modifier.weight(1f)) {
                    items(products.filter { it.category == selectedCategory }) { prod ->
                        ProductRowInline(prod) { qty ->
                            val existing = saleDetails.find { it.name == prod.name }
                            if (existing != null) existing.quantity += qty else saleDetails.add(prod.copy(quantity = qty))
                            step = 1
                        }
                    }
                    item { TextButton(onClick = { /* Temp popup */ }, modifier = Modifier.fillMaxWidth()) { Text("Registrar un producto Nuevo", color = ActionBlue, fontWeight = FontWeight.Bold) } }
                }
            }
        }
    }

    if (showCobroPopup) {
        CobroForm(
            items = saleDetails,
            onDismiss = { showCobroPopup = false },
            onConfirm = { amount, method ->
                val summaries = saleDetails.map { SaleItemSummary(it.name, it.quantity, it.price * it.quantity) }
                onConfirm(POSSale(UUID.randomUUID().toString(), amount, method, "Cobrada", items = summaries))
                showCobroPopup = false
            }
        )
    }
}

/**
 * CobroForm: Pantalla final de pago.
 */
@Composable
fun CobroForm(items: List<POSItem>, onDismiss: () -> Unit, onConfirm: (Double, String) -> Unit) {
    val total = items.sumOf { it.price * it.quantity }
    var paymentMethod by remember { mutableStateOf("Efectivo") }
    var amountPaid by remember { mutableStateOf("") }

    TacoDialog(title = "Resumen de venta", onDismiss = onDismiss) {
        LazyColumn(modifier = Modifier.weight(1f)) {
            items(items) { item ->
                Row(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text("${item.quantity} ${item.name}", color = Color.Gray)
                    Text("$${item.price * item.quantity}", fontWeight = FontWeight.Bold)
                }
            }
        }
        Divider(Modifier.padding(vertical = 8.dp))
        ReportRow("TOTAL:", "$${total}", isBold = true, color = PrimaryNavy)
        Spacer(Modifier.height(16.dp))
        Row(modifier = Modifier.fillMaxWidth()) {
            Button(onClick = { paymentMethod = "Efectivo" }, modifier = Modifier.weight(1f), colors = ButtonDefaults.buttonColors(containerColor = if (paymentMethod == "Efectivo") ActionBlue else Color.Gray)) { Text("Efectivo") }
            Spacer(Modifier.width(8.dp))
            Button(onClick = { paymentMethod = "Tarjeta" }, modifier = Modifier.weight(1f), colors = ButtonDefaults.buttonColors(containerColor = if (paymentMethod == "Tarjeta") ActionBlue else Color.Gray)) { Text("Tarjeta") }
        }
        if (paymentMethod == "Efectivo") {
            OutlinedTextField(value = amountPaid, onValueChange = { if (it.all { c -> c.isDigit() }) amountPaid = it }, label = { Text("Paga con") }, modifier = Modifier.fillMaxWidth())
            val p = amountPaid.toDoubleOrNull() ?: 0.0
            if (p >= total) {
                Column(modifier = Modifier.padding(top = 12.dp)) {
                    Text("CAMBIO", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = SuccessGreen)
                    Text("$${p - total}", color = SuccessGreen, fontSize = 36.sp, fontWeight = FontWeight.Black)
                }
            }
        }
        Spacer(Modifier.height(24.dp))
        Button(onClick = { onConfirm(total, paymentMethod) }, modifier = Modifier.fillMaxWidth().height(60.dp), shape = RoundedCornerShape(20.dp), colors = ButtonDefaults.buttonColors(containerColor = SuccessGreen)) { Text("COBRA", fontWeight = FontWeight.Black, fontSize = 18.sp) }
    }
}

/**
 * ProductRowInline: Fila de producto con selector de cantidad.
 */
@Composable
fun ProductRowInline(prod: POSItem, onAdd: (Int) -> Unit) {
    var qty by remember { mutableStateOf("") }
    val focusRequester = remember { FocusRequester() }
    var isSelected by remember { mutableStateOf(false) }
    Card(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp).clickable { isSelected = true }, shape = RoundedCornerShape(12.dp)) {
        Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(modifier = Modifier.size(40.dp).clip(RoundedCornerShape(8.dp)).background(Color.LightGray))
            Spacer(Modifier.width(12.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(prod.name, fontWeight = FontWeight.Bold)
                Text("$${prod.price}", color = ActionBlue, fontSize = 12.sp)
            }
            if (isSelected) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    OutlinedTextField(value = qty, onValueChange = { if (it.all { c -> c.isDigit() }) qty = it }, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number), modifier = Modifier.width(70.dp).focusRequester(focusRequester), textStyle = LocalTextStyle.current.copy(textAlign = TextAlign.Center))
                    IconButton(onClick = { if (qty.isNotEmpty()) onAdd(qty.toInt()) }) { Icon(Icons.Default.Check, null, tint = SuccessGreen) }
                    LaunchedEffect(Unit) { focusRequester.requestFocus() }
                }
            }
        }
    }
}

/**
 * ExpenseDialog: Formulario de gastos.
 */
@Composable
fun ExpenseDialog(onDismiss: () -> Unit, onConfirm: (POSExpense) -> Unit) {
    var detalle by remember { mutableStateOf("") }
    var cantidad by remember { mutableStateOf("") }
    var capturedPhoto by remember { mutableStateOf<Bitmap?>(null) }
    val cameraLauncher = rememberLauncherForActivityResult(ActivityResultContracts.TakePicturePreview()) { capturedPhoto = it }

    TacoDialog(title = "Registrar Gasto", onDismiss = onDismiss) {
        OutlinedTextField(value = detalle, onValueChange = { detalle = it }, label = { Text("Detalle") }, modifier = Modifier.fillMaxWidth())
        OutlinedTextField(value = cantidad, onValueChange = { if (it.all { c -> c.isDigit() }) cantidad = it }, label = { Text("Total") }, modifier = Modifier.fillMaxWidth())
        Spacer(Modifier.height(8.dp))
        Button(onClick = { cameraLauncher.launch() }, modifier = Modifier.fillMaxWidth(), colors = ButtonDefaults.buttonColors(containerColor = Color.LightGray)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.AddCircle, null)
                Spacer(Modifier.width(8.dp))
                Text(if (capturedPhoto != null) "FOTO CAPTURADA" else "TOMAR FOTO TICKET")
            }
        }
        Spacer(Modifier.height(16.dp))
        Button(onClick = { onConfirm(POSExpense(detail = detalle, amount = cantidad.toDoubleOrNull() ?: 0.0, cashier = GoogleSignInState.nombre, receiptPhoto = capturedPhoto)) }, modifier = Modifier.fillMaxWidth()) { Text("REGISTRAR GASTO") }
        TextButton(onClick = onDismiss, modifier = Modifier.fillMaxWidth()) { Text("CANCELAR") }
    }
}

/**
 * CorteDialog: Formulario final de arqueo.
 */
@Composable
fun CorteDialog(onDismiss: () -> Unit, onConfirm: () -> Unit) {
    val totalSales = ShiftManager.sales.filter { it.status == "Cobrada" }.sumOf { it.amount }
    val totalCash = ShiftManager.sales.filter { it.status == "Cobrada" && it.method == "Efectivo" }.sumOf { it.amount }
    val totalCard = ShiftManager.sales.filter { it.status == "Cobrada" && it.method == "Tarjeta" }.sumOf { it.amount }
    val totalExp = ShiftManager.expenses.sumOf { it.amount }
    val cashInDrawer = totalCash + ShiftManager.fondoCaja - totalExp

    TacoDialog(title = "¿Cerrar Corte?", onDismiss = onDismiss) {
        Text("Responsable: ${ShiftManager.currentCashier}", fontWeight = FontWeight.Bold)
        Divider(modifier = Modifier.padding(vertical = 8.dp))
        ReportRow("Total Ventas:", "$$totalSales")
        ReportRow("Pago con Tarjeta:", "$$totalCard")
        ReportRow("Pago en Efectivo:", "$$totalCash")
        ReportRow("Total Gastos:", "$$totalExp")
        Divider(modifier = Modifier.padding(vertical = 8.dp))
        ReportRow("Fondo Inicial:", "$${ShiftManager.fondoCaja}")
        ReportRow("EFECTIVO EN CAJA:", "$${cashInDrawer}", color = SuccessGreen)
        if (ShiftManager.fondoCaja == 0.0) Text("AVISO: Corte sin fondo", color = Color.Red, fontSize = 12.sp, fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(24.dp))
        Button(onClick = onConfirm, modifier = Modifier.fillMaxWidth().height(60.dp), colors = ButtonDefaults.buttonColors(containerColor = Color.Red), shape = RoundedCornerShape(20.dp)) { Text("HACER CORTE", fontWeight = FontWeight.Black) }
        TextButton(onClick = onDismiss, modifier = Modifier.fillMaxWidth()) { Text("REGRESAR", color = Color.Gray) }
    }
}
