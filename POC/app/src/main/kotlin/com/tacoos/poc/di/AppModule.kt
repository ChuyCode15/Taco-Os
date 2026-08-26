package com.tacoos.poc.di

import android.content.Context
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent

/**
 * Módulo de Hilt que provee dependencias básicas y globales de la aplicación.
 */
@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    /**
     * Proporciona el contexto de la aplicación.
     */
    @Provides
    fun provideContext(@ApplicationContext context: Context): Context = context
}
