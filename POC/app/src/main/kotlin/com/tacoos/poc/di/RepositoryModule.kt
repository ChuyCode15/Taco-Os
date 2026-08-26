package com.tacoos.poc.di

import com.tacoos.poc.data.repository.AuthRepositoryImpl
import com.tacoos.poc.domain.repository.AuthRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * Módulo de Hilt para la abstracción de repositorios.
 * Asocia las interfaces del dominio con sus implementaciones en la capa de datos.
 */
@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    /**
     * Proporciona la implementación concreta de [AuthRepository].
     * @param impl Implementación basada en red y preferencias.
     * @return Instancia vinculada de [AuthRepository].
     */
    @Binds
    @Singleton
    abstract fun bindAuthRepository(impl: AuthRepositoryImpl): AuthRepository
}
