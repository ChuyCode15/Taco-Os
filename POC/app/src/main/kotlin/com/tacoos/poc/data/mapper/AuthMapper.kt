package com.tacoos.poc.data.mapper

import com.tacoos.poc.data.remote.dto.DatosUsuarioAuth
import com.tacoos.poc.domain.model.User

/**
 * Convierte un objeto de datos de usuario de la capa de red al modelo de dominio de usuario.
 * @return Una instancia de [User] con la información mapeada.
 */
fun DatosUsuarioAuth.toDomain(): User = User(
    id = id,
    idGoogle = idGoogle,
    nickname = nickname,
    email = correo,
    rol = rol,
    tieneNegocio = tieneNegocio,
    negocioId = negocioId,
    negocioNombre = negocioNombre
)
