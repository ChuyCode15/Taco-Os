package com.tacoos.poc.core.util

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import java.io.File
import java.io.FileOutputStream
import java.util.UUID

/**
 * ImageStorage: Utilidad para persistir imágenes físicamente en el almacenamiento interno.
 */
object ImageStorage {
    private const val FOLDER_NAME = "tacoos_images"

    /**
     * saveImage: Guarda un Bitmap en disco y retorna la ruta absoluta.
     */
    fun saveImage(context: Context, bitmap: Bitmap, prefix: String = "img"): String? {
        return try {
            val directory = File(context.filesDir, FOLDER_NAME)
            if (!directory.exists()) directory.mkdirs()

            val fileName = "${prefix}_${UUID.randomUUID()}.jpg"
            val file = File(directory, fileName)

            FileOutputStream(file).use { out ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, 85, out)
            }
            file.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    /**
     * loadImage: Carga un Bitmap desde una ruta de archivo.
     */
    fun loadImage(path: String?): Bitmap? {
        if (path.isNullOrEmpty()) return null
        return try {
            BitmapFactory.decodeFile(path)
        } catch (e: Exception) {
            null
        }
    }

    /**
     * deleteImage: Elimina un archivo físico del disco.
     */
    fun deleteImage(path: String?) {
        if (path.isNullOrEmpty()) return
        try {
            val file = File(path)
            if (file.exists()) file.delete()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
