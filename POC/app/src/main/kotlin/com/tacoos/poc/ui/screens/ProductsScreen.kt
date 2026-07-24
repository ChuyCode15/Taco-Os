package com.tacoos.poc.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.tacoos.poc.TacoApp
import com.tacoos.poc.data.local.Product
import com.tacoos.poc.ui.theme.ActionBlue
import com.tacoos.poc.utils.ImageStorage
import kotlinx.coroutines.launch
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProductsScreen(
    navController: NavController,
    isDarkMode: Boolean,
    onThemeChange: (Boolean) -> Unit
) {
    val context = LocalContext.current
    val repository = (context.applicationContext as TacoApp).repository
    val scope = rememberCoroutineScope()
    
    val products = remember { mutableStateListOf<Product>() }
    var isLoading by remember { mutableStateOf(true) }
    
    var showProductForm by remember { mutableStateOf(false) }
    var productToEdit by remember { mutableStateOf<Product?>(null) }
    
    var searchQuery by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf("Todos") }
    val categories = listOf("Todos", "Comidas", "Bebidas", "Postres")

    fun refreshProducts() {
        scope.launch {
            isLoading = true
            val negocioId = GoogleSignInState.negocioId ?: "N/A"
            val list = repository.getProducts(negocioId)
            products.clear()
            products.addAll(list)
            isLoading = false
        }
    }

    LaunchedEffect(Unit) {
        refreshProducts()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("MIS PRODUCTOS", fontWeight = FontWeight.Black) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, null)
                    }
                },
                actions = {
                    IconButton(onClick = { 
                        productToEdit = null
                        showProductForm = true 
                    }) {
                        Icon(Icons.Default.Add, null, tint = ActionBlue)
                    }
                }
            )
        }
    ) { padding ->
        Column(modifier = Modifier.fillMaxSize().padding(padding)) {
            // Buscador
            OutlinedTextField(
                value = searchQuery,
                onValueChange = { searchQuery = it },
                modifier = Modifier.fillMaxWidth().padding(16.dp),
                placeholder = { Text("Buscar producto...") },
                leadingIcon = { Icon(Icons.Default.Search, null) },
                shape = RoundedCornerShape(12.dp),
                singleLine = true,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = ActionBlue,
                    unfocusedBorderColor = Color.LightGray.copy(alpha = 0.5f)
                )
            )
            
            // Filtros de Categoría
            ScrollableTabRow(
                selectedTabIndex = categories.indexOf(selectedCategory),
                edgePadding = 16.dp,
                containerColor = Color.Transparent,
                divider = {},
                indicator = {}
            ) {
                categories.forEach { cat ->
                    val selected = selectedCategory == cat
                    Tab(
                        selected = selected,
                        onClick = { selectedCategory = cat },
                        text = {
                            Surface(
                                color = if (selected) ActionBlue else Color.LightGray.copy(alpha = 0.2f),
                                shape = RoundedCornerShape(16.dp),
                                modifier = Modifier.padding(vertical = 4.dp)
                            ) {
                                Text(
                                    cat,
                                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp),
                                    color = if (selected) Color.White else Color.Gray,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 12.sp
                                )
                            }
                        }
                    )
                }
            }

            if (isLoading) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = ActionBlue)
                }
            } else {
                val filteredList = products.filter { 
                    (selectedCategory == "Todos" || it.category == selectedCategory) &&
                    it.name.contains(searchQuery, ignoreCase = true)
                }
                
                if (filteredList.isEmpty()) {
                    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Text("No hay productos registrados", color = Color.Gray)
                    }
                } else {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(16.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        items(filteredList) { product ->
                            ProductManagementRow(
                                product = product,
                                onEdit = {
                                    productToEdit = product
                                    showProductForm = true
                                },
                                onDelete = {
                                    scope.launch {
                                        repository.deleteProduct(product)
                                        refreshProducts()
                                    }
                                }
                            )
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
                    val p = productToEdit?.copy(
                        name = name, 
                        price = price, 
                        category = cat, 
                        imagePath = imgPath
                    ) ?: Product(
                        id = UUID.randomUUID().toString(),
                        name = name,
                        price = price,
                        category = cat,
                        imagePath = imgPath,
                        negocioId = GoogleSignInState.negocioId ?: "N/A"
                    )
                    
                    if (productToEdit == null) {
                        repository.saveProduct(p)
                    } else {
                        repository.updateProduct(p)
                    }
                    refreshProducts()
                    showProductForm = false
                }
            }
        )
    }
}

@Composable
fun ProductManagementRow(
    product: Product,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    val image = remember(product.imagePath) { ImageStorage.loadImage(product.imagePath) }
    
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
        )
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Miniatura del producto
            Box(
                modifier = Modifier
                    .size(50.dp)
                    .clip(RoundedCornerShape(10.dp))
                    .background(Color.LightGray.copy(alpha = 0.3f)),
                contentAlignment = Alignment.Center
            ) {
                if (image != null) {
                    Image(
                        bitmap = image.asImageBitmap(),
                        contentDescription = null,
                        modifier = Modifier.fillMaxSize(),
                        contentScale = ContentScale.Crop
                    )
                } else {
                    Icon(Icons.Default.Fastfood, null, tint = Color.Gray.copy(alpha = 0.5f))
                }
            }
            
            Spacer(Modifier.width(16.dp))
            
            Column(modifier = Modifier.weight(1f)) {
                Text(product.name, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                Text(product.category, color = Color.Gray, fontSize = 12.sp)
                Text("$${product.price}", color = ActionBlue, fontWeight = FontWeight.Black, fontSize = 14.sp)
            }
            
            Row {
                IconButton(onClick = onEdit) {
                    Icon(Icons.Default.Edit, contentDescription = "Editar", tint = ActionBlue)
                }
                IconButton(onClick = onDelete) {
                    Icon(Icons.Default.Delete, contentDescription = "Eliminar", tint = Color.Red.copy(alpha = 0.7f))
                }
            }
        }
    }
}
