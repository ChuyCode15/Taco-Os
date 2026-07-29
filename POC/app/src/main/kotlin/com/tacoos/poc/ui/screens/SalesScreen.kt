package com.tacoos.poc.ui.screens

import android.graphics.Bitmap
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.result.launch
import androidx.compose.animation.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.tacoos.poc.ui.components.*
import com.tacoos.poc.ui.theme.ActionBlue
import com.tacoos.poc.ui.theme.PrimaryNavy
import com.tacoos.poc.ui.theme.SuccessGreen
import com.tacoos.poc.ui.theme.WarningAmber
import com.tacoos.poc.utils.ImageStorage
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

/**
 * SalesScreen: Pantalla principal del Punto de Venta (POS).
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
    val repository = (context.applicationContext as com.tacoos.poc.TacoApp).repository

    val products = remember { mutableStateListOf<com.tacoos.poc.data.local.Product>() }
    var selectedSale by remember { mutableStateOf<POSSale?>(null) }
    
    // Carga inicial, semilla y restauración de turno
    LaunchedEffect(Unit) {
        if (GoogleSignInState.negocioId != null) {
            val negocioId = GoogleSignInState.negocioId!!
            repository.seedInitialProducts(negocioId)
            products.clear()
            products.addAll(repository.getProducts(negocioId))
            
            // Punto 3 Protocolo Integridad: Recuperación de turno abierto
            val active = repository.getActiveCorte(negocioId)
            if (active != null) {
                ShiftManager.activeCorteId = active.id
                ShiftManager.isShiftOpen = true
                ShiftManager.fondoCaja = active.initialCash
                ShiftManager.openTimestamp = active.openedAt
                ShiftManager.currentCashier = GoogleSignInState.nombre
            }
        }
    }

    var showOpeningDialog by remember { mutableStateOf(false) }
    var showNewSalePopup by remember { mutableStateOf(false) }
    var showCortePopup by remember { mutableStateOf(false) }
    var showExpensePopup by remember { mutableStateOf(false) }

    var transactionSuccessMessage by remember { mutableStateOf<String?>(null) }
    var transactionErrorMessage by remember { mutableStateOf<String?>(null) }

    val dateFormat = SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.getDefault())

    LaunchedEffect(transactionSuccessMessage) {
        if (transactionSuccessMessage != null) { delay(1500); transactionSuccessMessage = null }
    }
    LaunchedEffect(transactionErrorMessage) {
        if (transactionErrorMessage != null) { delay(1500); transactionErrorMessage = null }
    }

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
                    title = { Text("VENTAS", fontWeight = FontWeight.Black) },
                    navigationIcon = {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            IconButton(onClick = { navController.popBackStack() }) { Icon(Icons.AutoMirrored.Filled.ArrowBack, null) }
                            IconButton(onClick = { scope.launch { drawerState.open() } }) { Icon(Icons.Default.Menu, null) }
                        }
                    }
                )
            }
        ) { padding ->
            Box(modifier = Modifier.fillMaxSize().padding(padding)) {
                Column(modifier = Modifier.fillMaxSize()) {
                    Row(modifier = Modifier.fillMaxWidth().background(Color.LightGray.copy(alpha = 0.1f)).padding(12.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text(SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()).format(Date()), fontWeight = FontWeight.Bold, color = Color.Gray)
                        Text(GoogleSignInState.nombre.ifEmpty { "Usuario" }, fontWeight = FontWeight.Bold, color = ActionBlue)
                    }

                    if (!ShiftManager.isShiftOpen) {
                        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Icon(Icons.Default.Lock, null, modifier = Modifier.size(100.dp), tint = Color.LightGray.copy(alpha = 0.5f))
                                Spacer(Modifier.height(16.dp))
                                Text("LA CAJA ESTÁ CERRADA", fontWeight = FontWeight.Black, color = Color.Gray)
                                Spacer(Modifier.height(32.dp))
                                Button(onClick = { showOpeningDialog = true }, shape = RoundedCornerShape(20.dp), modifier = Modifier.height(60.dp).fillMaxWidth(0.6f)) {
                                    Text("ABRIR CAJA", fontWeight = FontWeight.Black)
                                }
                            }
                        }
                    } else {
                        Column(modifier = Modifier.weight(1f).padding(16.dp)) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text("CORTE ACTIVO", style = MaterialTheme.typography.labelSmall, fontWeight = FontWeight.Bold)
                                Spacer(Modifier.width(8.dp))
                                Box(modifier = Modifier.size(8.dp).clip(CircleShape).background(SuccessGreen))
                            }
                            Text("Abierta: ${dateFormat.format(Date(ShiftManager.openTimestamp))}", fontSize = 10.sp, color = Color.Gray)
                            Spacer(Modifier.height(16.dp))
                            Surface(modifier = Modifier.weight(1f).fillMaxWidth(), shape = RoundedCornerShape(24.dp), color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.2f), border = androidx.compose.foundation.BorderStroke(1.dp, Color.LightGray.copy(alpha = 0.3f))) {
                                if (ShiftManager.sales.isEmpty()) {
                                    Box(contentAlignment = Alignment.Center) { Text("Sin ventas en este corte", color = Color.Gray) }
                                } else {
                                    LazyColumn { items(ShiftManager.sales) { sale -> SaleRow(sale, isSelected = selectedSale?.id == sale.id) { selectedSale = sale } } }
                                }
                            }
                            Row(modifier = Modifier.fillMaxWidth().padding(vertical = 16.dp), horizontalArrangement = Arrangement.SpaceEvenly, verticalAlignment = Alignment.CenterVertically) {
                                ActionButton(Icons.Default.Close, "Cancelar", Color.Red) {
                                    selectedSale?.let {
                                        if (System.currentTimeMillis() - it.timestamp < 300000) {
                                            val index = ShiftManager.sales.indexOf(it)
                                            if (index != -1) ShiftManager.sales[index] = it.copy(status = "Cancelada")
                                            selectedSale = null
                                        } else {
                                            Toast.makeText(context, "Registro inmutable (> 5 min)", Toast.LENGTH_SHORT).show()
                                        }
                                    }
                                }
                                ActionButton(Icons.Default.ShoppingCart, "Gasto", WarningAmber) { showExpensePopup = true }
                                ActionButton(Icons.Default.Add, "Venta", SuccessGreen) { showNewSalePopup = true }
                            }
                            Button(onClick = { showCortePopup = true }, modifier = Modifier.fillMaxWidth().height(60.dp), shape = RoundedCornerShape(16.dp), colors = ButtonDefaults.buttonColors(containerColor = PrimaryNavy)) {
                                Text("CERRAR CORTE", fontWeight = FontWeight.Black)
                            }
                        }
                    }
                }
                if (transactionSuccessMessage != null) TransactionBanner(transactionSuccessMessage!!, SuccessGreen)
                if (transactionErrorMessage != null) TransactionBanner(transactionErrorMessage!!, Color.Red)
            }
        }
    }

    if (showOpeningDialog) {
        OpeningForm(onDismiss = { showOpeningDialog = false }) { fondo ->
            scope.launch {
                val newCorte = repository.openCorte(
                    negocioId = GoogleSignInState.negocioId ?: "N/A",
                    cashierId = GoogleSignInState.userId,
                    initialCash = fondo
                )
                ShiftManager.activeCorteId = newCorte.id
                ShiftManager.fondoCaja = fondo
                ShiftManager.isShiftOpen = true
                ShiftManager.openTimestamp = System.currentTimeMillis()
                ShiftManager.currentCashier = GoogleSignInState.nombre
                showOpeningDialog = false
            }
        }
    }

    if (showNewSalePopup) {
        NewSaleDialog(
            products = products,
            onDismiss = { showNewSalePopup = false },
            onConfirm = { sale ->
                scope.launch {
                    try {
                        val imgPath = sale.voucherPhoto?.let { ImageStorage.saveImage(context, it, "sale") }
                        
                        // Mapeo inmutable para auditoría (Punto 2 Maqueta)
                        val note = com.tacoos.poc.data.local.SaleNote(
                            id = sale.id,
                            tenantId = GoogleSignInState.negocioId ?: "N/A",
                            corteId = ShiftManager.activeCorteId ?: "",
                            totalProducts = sale.items.sumOf { it.totalQuantity },
                            totalAmount = sale.amount,
                            paymentMethod = if (sale.method == "Efectivo") "CASH" else "CARD",
                            voucherPath = imgPath,
                            productsJson = sale.items.joinToString { "${it.totalQuantity}x ${it.productName}" }
                        )
                        
                        val details = sale.items.map { 
                            com.tacoos.poc.data.local.SaleDetail(
                                id = UUID.randomUUID().toString(),
                                noteId = note.id,
                                productName = it.productName,
                                quantity = it.totalQuantity,
                                unitPrice = if (it.totalQuantity > 0) it.totalPrice / it.totalQuantity else 0.0,
                                totalPrice = it.totalPrice
                            )
                        }

                        // Guardado atómico (ACID)
                        repository.registerInmutableSale(note, details)
                        
                        ShiftManager.sales.add(0, sale)
                        transactionSuccessMessage = "Venta blindada localmente"
                        showNewSalePopup = false
                    } catch (e: Exception) { 
                        transactionErrorMessage = "Error de persistencia profunda" 
                    }
                }
            },
            onRefreshProducts = {
                scope.launch {
                    products.clear()
                    products.addAll(repository.getProducts(GoogleSignInState.negocioId ?: "N/A"))
                }
            }
        )
    }

    if (showExpensePopup) {
        ExpenseDialog(onDismiss = { showExpensePopup = false }) { expense ->
            scope.launch {
                val imgPath = expense.receiptPhoto?.let { ImageStorage.saveImage(context, it, "expense") }
                repository.registerExpense(
                    id = expense.id,
                    detail = expense.detail,
                    amount = expense.amount,
                    cashier = expense.cashier,
                    negocioId = GoogleSignInState.negocioId ?: "N/A",
                    imagePath = imgPath
                )
                ShiftManager.expenses.add(expense)
                showExpensePopup = false
                Toast.makeText(context, "Gasto persistido localmente", Toast.LENGTH_SHORT).show()
            }
        }
    }

    if (showCortePopup) {
        CorteDialog(onDismiss = { showCortePopup = false }) {
            scope.launch {
                // Cálculo de dinero real basado en UI (simplificado para el POC)
                val totalCash = ShiftManager.sales.filter { it.status == "Cobrada" && it.method == "Efectivo" }.sumOf { it.amount }
                val totalExp = ShiftManager.expenses.sumOf { it.amount }
                val expectedCash = ShiftManager.fondoCaja + totalCash - totalExp
                
                ShiftManager.activeCorteId?.let { 
                    repository.closeCorte(it, expectedCash) 
                }

                ShiftManager.isShiftOpen = false
                ShiftManager.activeCorteId = null
                ShiftManager.sales.clear()
                ShiftManager.expenses.clear()
                showCortePopup = false
                navController.popBackStack()
            }
        }
    }
}

@Composable
fun TransactionBanner(message: String, color: Color) {
    Box(modifier = Modifier.fillMaxWidth().height(50.dp).background(color), contentAlignment = Alignment.Center) {
        Text(message, color = Color.White, fontWeight = FontWeight.Bold)
    }
}

@Composable
fun OpeningForm(onDismiss: () -> Unit, onConfirm: (Double) -> Unit) {
    var fondoInput by remember { mutableStateOf("") }
    TacoDialog(title = "Abrir Caja", onDismiss = onDismiss, confirmButton = { Button(onClick = { onConfirm(fondoInput.toDoubleOrNull() ?: 0.0) }) { Text("ACEPTAR") } }, dismissButton = { TextButton(onClick = onDismiss) { Text("CANCELAR") } }) {
        Text("¿Deseas ingresar un fondo de caja?")
        Spacer(Modifier.height(16.dp))
        OutlinedTextField(value = fondoInput, onValueChange = { if (it.all { c -> c.isDigit() }) fondoInput = it }, label = { Text("Cantidad") }, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number), modifier = Modifier.fillMaxWidth())
    }
}

@Composable
fun SaleRow(sale: POSSale, isSelected: Boolean, onClick: () -> Unit) {
    val statusColor = if (sale.status == "Cancelada") Color.Red else (if (sale.method == "Efectivo") SuccessGreen else ActionBlue)
    Row(modifier = Modifier.fillMaxWidth().background(if (isSelected) ActionBlue.copy(alpha = 0.1f) else Color.Transparent).clickable { onClick() }.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
        Box(modifier = Modifier.size(10.dp).clip(CircleShape).background(statusColor))
        Spacer(Modifier.width(12.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text("Venta #${sale.id.take(4)}", fontWeight = FontWeight.Bold)
            Text(sale.method, fontSize = 12.sp, color = Color.Gray)
        }
        Text("$${sale.amount}", fontWeight = FontWeight.Black, color = if (sale.status == "Cancelada") Color.Red else PrimaryNavy)
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NewSaleDialog(
    products: List<com.tacoos.poc.data.local.Product>,
    onDismiss: () -> Unit,
    onConfirm: (POSSale) -> Unit,
    onRefreshProducts: () -> Unit
) {
    var step by remember { mutableStateOf(1) }
    val saleDetails = remember { mutableStateListOf<POSItem>() }
    val sessionItems = remember { mutableStateListOf<POSItem>() }
    var selectedCategory by remember { mutableStateOf("Comidas") }
    var showCobroPopup by remember { mutableStateOf(false) }
    var itemToDeleteIndex by remember { mutableStateOf<Int?>(null) }
    
    var showProductForm by remember { mutableStateOf(false) }
    var productToEdit by remember { mutableStateOf<com.tacoos.poc.data.local.Product?>(null) }
    var productOptionsIndex by remember { mutableStateOf<Int?>(null) }

    val repository = (LocalContext.current.applicationContext as com.tacoos.poc.TacoApp).repository
    val scope = rememberCoroutineScope()
    val context = LocalContext.current

    TacoDialog(
        title = if (step == 1) "Nota de Venta" else "Agregar Producto",
        onDismiss = onDismiss,
        maxHeightFactor = 0.6f,
        navigationIcon = if (step > 1) Icons.AutoMirrored.Filled.ArrowBack else null,
        onNavigationClick = { step = 1 },
        headerAction = if (step == 2) {
            {
                Text(text = "+", modifier = Modifier.padding(end = 12.dp).clickable { productToEdit = null; showProductForm = true }, color = ActionBlue, fontWeight = FontWeight.Bold, fontSize = 24.sp)
            }
        } else null
    ) {
        if (step == 1) {
            Column {
                Box(modifier = Modifier.weight(1f)) {
                    if (saleDetails.isEmpty()) {
                        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) { Text("Sin productos", color = Color.Gray) }
                    } else {
                        Box {
                            LazyColumn {
                                itemsIndexed(saleDetails) { index, item ->
                                    Row(modifier = Modifier.fillMaxWidth().clickable { itemToDeleteIndex = index }.padding(8.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                                        Text("${item.quantity}x ${item.name}", modifier = Modifier.weight(1f), fontWeight = FontWeight.Medium)
                                        Text("$${item.price * item.quantity}", fontWeight = FontWeight.Bold)
                                    }
                                }
                            }
                            itemToDeleteIndex?.let { index ->
                                Box(modifier = Modifier.fillMaxSize().clickable { itemToDeleteIndex = null }, contentAlignment = Alignment.Center) {
                                    Surface(modifier = Modifier.shadow(8.dp, RoundedCornerShape(16.dp)), shape = RoundedCornerShape(16.dp), color = Color.White) {
                                        Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                                            IconButton(onClick = { saleDetails.removeAt(index); itemToDeleteIndex = null }) { Icon(Icons.Default.Delete, contentDescription = "Eliminar", tint = Color.Red) }
                                        }
                                    }
                                }
                            }
                        }
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
                        Box(modifier = Modifier.weight(1f).height(40.dp).clip(RoundedCornerShape(12.dp)).background(if (selectedCategory == cat) ActionBlue else Color.Transparent).clickable { selectedCategory = cat }, contentAlignment = Alignment.Center) {
                            Text(cat, color = if (selectedCategory == cat) Color.White else Color.Gray, fontWeight = FontWeight.Bold, fontSize = 11.sp)
                        }
                    }
                }
                Spacer(Modifier.height(8.dp))
                Box(modifier = Modifier.weight(1f)) {
                    LazyColumn(modifier = Modifier.fillMaxSize()) {
                        val filteredProducts = products.filter { it.category == selectedCategory }
                        itemsIndexed(filteredProducts) { index, prod ->
                            ProductRowInline(
                                prod = POSItem(prod.name, prod.price, prod.category, imagePath = prod.imagePath),
                                onAdd = { qty -> sessionItems.add(POSItem(prod.name, prod.price, prod.category, qty, prod.imagePath)) },
                                onLongClick = { if (GoogleSignInState.rol == "dueño" || GoogleSignInState.rol == "administrador") productOptionsIndex = index }
                            )
                        }
                        if (sessionItems.isNotEmpty()) {
                            item { HorizontalDivider(Modifier.padding(vertical = 12.dp)) }
                            items(sessionItems) { item ->
                                Row(modifier = Modifier.fillMaxWidth().padding(horizontal = 8.dp)) {
                                    Text(text = "${item.quantity} ${item.name}", fontSize = 11.sp, color = Color.Gray, modifier = Modifier.weight(1f))
                                    Text("$${item.price * item.quantity}", fontSize = 11.sp, color = Color.Gray)
                                }
                            }
                        }
                        item {
                            if (sessionItems.isNotEmpty()) {
                                Button(onClick = {
                                    sessionItems.groupBy { it.name }.forEach { (name, list) ->
                                        val totalQty = list.sumOf { it.quantity }; val product = list.first(); val existing = saleDetails.find { it.name == name }
                                        if (existing != null) existing.quantity += totalQty else saleDetails.add(product.copy(quantity = totalQty))
                                    }
                                    sessionItems.clear(); step = 1
                                }, modifier = Modifier.fillMaxWidth().padding(top = 16.dp), colors = ButtonDefaults.buttonColors(containerColor = PrimaryNavy)) { Text("Listo", fontWeight = FontWeight.Bold) }
                            }
                        }
                    }
                    productOptionsIndex?.let { index ->
                        val currentProd = products.filter { it.category == selectedCategory }[index]
                        Box(modifier = Modifier.fillMaxSize().clickable { productOptionsIndex = null }, contentAlignment = Alignment.Center) {
                            Surface(modifier = Modifier.shadow(8.dp, RoundedCornerShape(16.dp)), shape = RoundedCornerShape(16.dp), color = Color.White) {
                                Row(modifier = Modifier.padding(12.dp)) {
                                    IconButton(onClick = { productToEdit = currentProd; showProductForm = true; productOptionsIndex = null }) { Icon(Icons.Default.Edit, "Editar", tint = ActionBlue) }
                                    Spacer(Modifier.width(8.dp))
                                    IconButton(onClick = { scope.launch { repository.deleteProduct(currentProd); onRefreshProducts(); productOptionsIndex = null } }) { Icon(Icons.Default.Delete, "Eliminar", tint = Color.Red) }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    if (showProductForm) {
        ProductForm(
            product = productToEdit,
            onDismiss = { showProductForm = false },
            onSave = { name, price, cat, photo ->
                scope.launch {
                    val imgPath = photo?.let { ImageStorage.saveImage(context, it, "prod") } ?: productToEdit?.imagePath
                    val p = productToEdit?.copy(name = name, price = price, category = cat, imagePath = imgPath)
                        ?: com.tacoos.poc.data.local.Product(id = UUID.randomUUID().toString(), name = name, price = price, category = cat, imagePath = imgPath, negocioId = GoogleSignInState.negocioId ?: "N/A")
                    if (productToEdit == null) repository.saveProduct(p) else repository.updateProduct(p)
                    onRefreshProducts()
                    showProductForm = false
                }
            }
        )
    }

    if (showCobroPopup) {
        CobroForm(
            items = saleDetails,
            onDismiss = { showCobroPopup = false },
            onConfirm = { amount, method, photo ->
                val summaries = saleDetails.map { SaleItemSummary(it.name, it.quantity, it.price * it.quantity) }
                onConfirm(POSSale(UUID.randomUUID().toString(), amount, method, "Cobrada", items = summaries, voucherPhoto = photo))
                showCobroPopup = false
            }
        )
    }
}

@Composable
fun CobroForm(items: List<POSItem>, onDismiss: () -> Unit, onConfirm: (Double, String, Bitmap?) -> Unit) {
    val total = items.sumOf { it.price * it.quantity }
    var paymentMethod by remember { mutableStateOf("Efectivo") }
    var amountPaid by remember { mutableStateOf("") }
    var voucherPhoto by remember { mutableStateOf<Bitmap?>(null) }
    val cameraLauncher = rememberLauncherForActivityResult(ActivityResultContracts.TakePicturePreview()) { voucherPhoto = it }

    TacoDialog(title = "Resumen de venta", onDismiss = onDismiss, maxHeightFactor = 0.6f) {
        LazyColumn(modifier = Modifier.weight(1f)) {
            items(items) { item -> Row(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), horizontalArrangement = Arrangement.SpaceBetween) { Text("${item.quantity} ${item.name}", color = Color.Gray); Text("$${item.price * item.quantity}", fontWeight = FontWeight.Bold) } }
        }
        HorizontalDivider(Modifier.padding(vertical = 8.dp))
        ReportRow("TOTAL:", "$${total}", isBold = true, color = PrimaryNavy)
        Row(modifier = Modifier.fillMaxWidth()) {
            Button(onClick = { paymentMethod = "Efectivo" }, modifier = Modifier.weight(1f), colors = ButtonDefaults.buttonColors(containerColor = if (paymentMethod == "Efectivo") ActionBlue else Color.Gray)) { Text("Efectivo") }
            Spacer(Modifier.width(8.dp))
            Button(onClick = { paymentMethod = "Tarjeta" }, modifier = Modifier.weight(1f), colors = ButtonDefaults.buttonColors(containerColor = if (paymentMethod == "Tarjeta") ActionBlue else Color.Gray)) { Text("Tarjeta") }
        }
        Spacer(Modifier.height(12.dp))
        if (paymentMethod == "Efectivo") {
            OutlinedTextField(value = amountPaid, onValueChange = { if (it.all { c -> c.isDigit() }) amountPaid = it }, label = { Text("Paga con") }, modifier = Modifier.fillMaxWidth())
            val p = amountPaid.toDoubleOrNull() ?: 0.0
            if (p >= total) {
                Column(modifier = Modifier.padding(top = 12.dp)) {
                    Text("CAMBIO", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = SuccessGreen)
                    Text("$${p - total}", color = SuccessGreen, fontSize = 36.sp, fontWeight = FontWeight.Black)
                }
            }
        } else {
            Button(onClick = { cameraLauncher.launch() }, modifier = Modifier.fillMaxWidth(), colors = ButtonDefaults.buttonColors(containerColor = Color.LightGray)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.AddCircle, null)
                    Spacer(Modifier.width(8.dp))
                    Text(if (voucherPhoto != null) "VOUCHER CAPTURADO" else "FOTO DEL VOUCHER")
                }
            }
            if (voucherPhoto != null) {
                Image(bitmap = voucherPhoto!!.asImageBitmap(), contentDescription = null, modifier = Modifier.size(100.dp).clip(RoundedCornerShape(8.dp)).align(Alignment.CenterHorizontally), contentScale = ContentScale.Crop)
            }
        }
        Spacer(Modifier.height(16.dp))
        val canConfirm = if (paymentMethod == "Tarjeta") voucherPhoto != null else true
        Button(onClick = { onConfirm(total, paymentMethod, voucherPhoto) }, enabled = canConfirm, modifier = Modifier.fillMaxWidth().height(60.dp), shape = RoundedCornerShape(20.dp), colors = ButtonDefaults.buttonColors(containerColor = if (canConfirm) SuccessGreen else Color.Gray)) { Text("COBRA", fontWeight = FontWeight.Black, fontSize = 18.sp) }
    }
}

@OptIn(androidx.compose.foundation.ExperimentalFoundationApi::class)
@Composable
fun ProductRowInline(prod: POSItem, onAdd: (Int) -> Unit, onLongClick: () -> Unit = {}) {
    var qty by remember { mutableStateOf("") }
    val focusRequester = remember { FocusRequester() }
    var isSelected by remember { mutableStateOf(false) }
    val image = remember(prod.imagePath) { ImageStorage.loadImage(prod.imagePath) }
    
    Card(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp).combinedClickable(onClick = { isSelected = true }, onLongClick = onLongClick), shape = RoundedCornerShape(12.dp), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)) {
        Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
            if (image != null) {
                Image(bitmap = image.asImageBitmap(), contentDescription = null, modifier = Modifier.size(40.dp).clip(RoundedCornerShape(8.dp)), contentScale = ContentScale.Crop)
            } else {
                Box(modifier = Modifier.size(40.dp).clip(RoundedCornerShape(8.dp)).background(Color.LightGray.copy(alpha = 0.2f)))
            }
            Spacer(Modifier.width(12.dp))
            Column(modifier = Modifier.weight(1f)) { Text(prod.name, fontWeight = FontWeight.Bold); Text("$${prod.price}", color = ActionBlue, fontSize = 12.sp) }
            if (isSelected) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    OutlinedTextField(value = qty, onValueChange = { if (it.all { c -> c.isDigit() }) qty = it }, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number), modifier = Modifier.width(70.dp).focusRequester(focusRequester), textStyle = LocalTextStyle.current.copy(textAlign = TextAlign.Center))
                    IconButton(onClick = { if (qty.isNotEmpty()) { onAdd(qty.toInt()); qty = "" } }) { Icon(Icons.Default.Add, null, tint = ActionBlue) }
                    LaunchedEffect(Unit) { focusRequester.requestFocus() }
                }
            } else { Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, null, tint = Color.LightGray) }
        }
    }
}

@Composable
fun ProductForm(product: com.tacoos.poc.data.local.Product? = null, onDismiss: () -> Unit, onSave: (String, Double, String, Bitmap?) -> Unit) {
    var name by remember { mutableStateOf(product?.name ?: "") }
    var price by remember { mutableStateOf(product?.price?.toString() ?: "") }
    var category by remember { mutableStateOf(product?.category ?: "Comidas") }
    var photo by remember { mutableStateOf<Bitmap?>(null) }
    var expanded by remember { mutableStateOf(false) }
    val cameraLauncher = rememberLauncherForActivityResult(ActivityResultContracts.TakePicturePreview()) { photo = it }
    val existingImage = remember(product?.imagePath) { ImageStorage.loadImage(product?.imagePath) }

    TacoDialog(title = if (product == null) "Nuevo Producto" else "Editar Producto", onDismiss = onDismiss, maxHeightFactor = 0.8f) {
        Column(modifier = Modifier.padding(8.dp)) {
            Box(modifier = Modifier.size(100.dp).clip(RoundedCornerShape(16.dp)).background(Color.LightGray.copy(alpha = 0.2f)).clickable { cameraLauncher.launch() }.align(Alignment.CenterHorizontally), contentAlignment = Alignment.Center) {
                val displayBitmap = photo ?: existingImage
                if (displayBitmap != null) {
                    Image(bitmap = displayBitmap.asImageBitmap(), contentDescription = null, modifier = Modifier.fillMaxSize(), contentScale = ContentScale.Crop)
                    Box(modifier = Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.2f)), contentAlignment = Alignment.Center) { Icon(Icons.Default.CameraAlt, null, tint = Color.White) }
                } else {
                    Icon(Icons.Default.AddAPhoto, "Cámara", tint = Color.Gray)
                }
            }
            Spacer(Modifier.height(16.dp))
            OutlinedTextField(value = name, onValueChange = { name = it }, label = { Text("Nombre") }, modifier = Modifier.fillMaxWidth())
            Spacer(Modifier.height(8.dp))
            OutlinedTextField(value = price, onValueChange = { if (it.all { c -> c.isDigit() || c == '.' }) price = it }, label = { Text("Precio") }, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number), modifier = Modifier.fillMaxWidth())
            Spacer(Modifier.height(16.dp))
            Box(modifier = Modifier.fillMaxWidth()) {
                OutlinedTextField(value = category, onValueChange = {}, readOnly = true, label = { Text("Categoría") }, trailingIcon = { IconButton(onClick = { expanded = true }) { Icon(Icons.Default.ArrowDropDown, null) } }, modifier = Modifier.fillMaxWidth())
                DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
                    listOf("Comidas", "Bebidas", "Postres").forEach { cat -> DropdownMenuItem(text = { Text(cat) }, onClick = { category = cat; expanded = false }) }
                }
            }
            Spacer(Modifier.height(24.dp))
            Button(onClick = { if (name.isNotEmpty() && price.isNotEmpty()) onSave(name, price.toDoubleOrNull() ?: 0.0, category, photo) }, modifier = Modifier.fillMaxWidth().height(60.dp), shape = RoundedCornerShape(20.dp), colors = ButtonDefaults.buttonColors(containerColor = ActionBlue)) { Text("GUARDAR PRODUCTO", fontWeight = FontWeight.Black) }
            TextButton(onClick = onDismiss, modifier = Modifier.fillMaxWidth()) { Text("CANCELAR", color = Color.Gray) }
        }
    }
}

@Composable
fun ExpenseDialog(onDismiss: () -> Unit, onConfirm: (POSExpense) -> Unit) {
    var detalle by remember { mutableStateOf("") }; var cantidad by remember { mutableStateOf("") }; var capturedPhoto by remember { mutableStateOf<Bitmap?>(null) }
    val cameraLauncher = rememberLauncherForActivityResult(ActivityResultContracts.TakePicturePreview()) { capturedPhoto = it }

    TacoDialog(title = "Registrar Gasto", onDismiss = onDismiss, maxHeightFactor = 0.6f) {
        OutlinedTextField(value = detalle, onValueChange = { detalle = it }, label = { Text("Detalle") }, modifier = Modifier.fillMaxWidth())
        OutlinedTextField(value = cantidad, onValueChange = { if (it.all { c -> c.isDigit() }) cantidad = it }, label = { Text("Total") }, modifier = Modifier.fillMaxWidth())
        Spacer(Modifier.height(8.dp))
        Button(onClick = { cameraLauncher.launch() }, modifier = Modifier.fillMaxWidth(), colors = ButtonDefaults.buttonColors(containerColor = Color.LightGray)) {
            Row(verticalAlignment = Alignment.CenterVertically) { Icon(Icons.Default.AddCircle, null); Spacer(Modifier.width(8.dp)); Text(if (capturedPhoto != null) "FOTO CAPTURADA" else "TOMAR FOTO TICKET") }
        }
        if (capturedPhoto != null) {
            Image(bitmap = capturedPhoto!!.asImageBitmap(), contentDescription = null, modifier = Modifier.size(80.dp).clip(RoundedCornerShape(8.dp)).align(Alignment.CenterHorizontally), contentScale = ContentScale.Crop)
        }
        Button(onClick = { onConfirm(POSExpense(detail = detalle, amount = cantidad.toDoubleOrNull() ?: 0.0, cashier = GoogleSignInState.nombre, receiptPhoto = capturedPhoto)) }, modifier = Modifier.fillMaxWidth()) { Text("REGISTRAR GASTO") }
        TextButton(onClick = onDismiss, modifier = Modifier.fillMaxWidth()) { Text("CANCELAR") }
    }
}

@Composable
fun CorteDialog(onDismiss: () -> Unit, onConfirm: () -> Unit) {
    val totalSales = ShiftManager.sales.filter { it.status == "Cobrada" }.sumOf { it.amount }; val totalCash = ShiftManager.sales.filter { it.status == "Cobrada" && it.method == "Efectivo" }.sumOf { it.amount }; val totalCard = ShiftManager.sales.filter { it.status == "Cobrada" && it.method == "Tarjeta" }.sumOf { it.amount }; val totalExp = ShiftManager.expenses.sumOf { it.amount }; val cashInDrawer = totalCash + ShiftManager.fondoCaja - totalExp
    TacoDialog(title = "¿Cerrar Corte?", onDismiss = onDismiss, maxHeightFactor = 0.6f) {
        Text("Responsable: ${ShiftManager.currentCashier}", fontWeight = FontWeight.Bold); HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp)); ReportRow("Total Ventas:", "$totalSales"); ReportRow("Pago con Tarjeta:", "$totalCard"); ReportRow("Pago en Efectivo:", "$totalCash"); ReportRow("Total Gastos:", "$totalExp"); HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp)); ReportRow("Fondo Inicial:", "$${ShiftManager.fondoCaja}"); ReportRow("EFECTIVO EN CAJA:", "$${cashInDrawer}", color = SuccessGreen)
        if (ShiftManager.fondoCaja == 0.0) Text("AVISO: Corte sin fondo", color = Color.Red, fontSize = 12.sp, fontWeight = FontWeight.Bold)
        Button(onClick = onConfirm, modifier = Modifier.fillMaxWidth().height(60.dp), colors = ButtonDefaults.buttonColors(containerColor = Color.Red), shape = RoundedCornerShape(20.dp)) { Text("HACER CORTE", fontWeight = FontWeight.Black) }
        TextButton(onClick = onDismiss, modifier = Modifier.fillMaxWidth()) { Text("REGRESAR", color = Color.Gray) }
    }
}
