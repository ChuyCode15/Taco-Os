package com.tacoos.poc.di

import com.tacoos.poc.domain.usecase.FormatTimeUseCase
import com.tacoos.poc.domain.usecase.ValidateBusinessNameUseCase
import com.tacoos.poc.domain.usecase.ValidateAddressUseCase
import com.tacoos.poc.domain.usecase.ValidateGiroUseCase
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * Módulo de Hilt que gestiona la provisión de casos de uso (Use Cases) de la aplicación.
 */
@Module
@InstallIn(SingletonComponent::class)
object UseCaseModule {

    /** Proporciona el caso de uso para formatear tiempos y horarios. */
    @Provides
    @Singleton
    fun provideFormatTimeUseCase(): FormatTimeUseCase = FormatTimeUseCase()

    /** Proporciona la lógica de validación del nombre del negocio. */
    @Provides
    @Singleton
    fun provideValidateBusinessNameUseCase(): ValidateBusinessNameUseCase = ValidateBusinessNameUseCase()

    /** Proporciona la lógica de validación de direcciones físicas. */
    @Provides
    @Singleton
    fun provideValidateAddressUseCase(): ValidateAddressUseCase = ValidateAddressUseCase()

    /** Proporciona la lógica de validación para el giro o categoría del negocio. */
    @Provides
    @Singleton
    fun provideValidateGiroUseCase(): ValidateGiroUseCase = ValidateGiroUseCase()
}
