package com.tacoos.poc.presentation.ui.ventas

import android.graphics.Bitmap
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AddAPhoto
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.tacoos.poc.data.local.Product
import com.tacoos.poc.presentation.ui.components.TacoDialog
import com.tacoos.poc.presentation.theme.ActionBlue
import com.tacoos.poc.core.util.ImageStorage

@Composable
fun ProductForm(
    product: Product? = null,
    onDismiss: () -> Unit,
    onSave: (String, Double, String, Bitmap?) -> Unit
) {
    var name by remember { mutableStateOf(product?.name ?: "") }
    var price by remember { mutableStateOf(product?.price?.toString() ?: "") }
    var category by remember { mutableStateOf(product?.category ?: "Comidas") }
    var photo by remember { mutableStateOf<Bitmap?>(null) }
    var expanded by remember { mutableStateOf(false) }
    val cameraLauncher = rememberLauncherForActivityResult(ActivityResultContracts.TakePicturePreview()) { photo = it }
    val existingImage = remember(product?.imagePath) { ImageStorage.loadImage(product?.imagePath) }

    TacoDialog(title = if (product == null) "Nuevo Producto" else "Editar Producto", onDismiss = onDismiss, maxHeightFactor = 0.8f) {
        Column(modifier = Modifier.padding(8.dp)) {
            Box(modifier = Modifier.size(100.dp).clip(RoundedCornerShape(16.dp)).background(Color.LightGray.copy(alpha = 0.2f)).clickable { cameraLauncher.launch(null) }.align(Alignment.CenterHorizontally), contentAlignment = Alignment.Center) {
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

@Preview(showBackground = true)
@Composable
fun ProductFormPreview() {
    ProductForm(onDismiss = {}, onSave = { _, _, _, _ -> })
}

