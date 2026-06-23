# 🌮 Taco'Os App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.11.5+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11.5+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-Private-red?style=for-the-badge)

**Sistema de punto de venta (POS) móvil para negocios de comida**

[Características](#-características-principales) •
[Arquitectura](#-arquitectura) •
[Instalación](#-instalación) •
[Configuración](#-configuración) •
[Uso](#-uso) •
[Tecnologías](#-tecnologías)

</div>

---

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Características Principales](#-características-principales)
- [Arquitectura](#-arquitectura)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación](#-instalación)
- [Configuración](#-configuración)
  - [Google Sign-In](#google-sign-in)
  - [Variables de Entorno](#variables-de-entorno)
  - [Backend](#backend)
- [Ejecución](#-ejecución)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Tecnologías](#-tecnologías)
- [Testing](#-testing)
- [Documentación Adicional](#-documentación-adicional)
- [Contribuir](#-contribuir)
- [Licencia](#-licencia)

---

## 📖 Descripción

**Taco'Os App** es una aplicación móvil de punto de venta (POS) diseñada específicamente para negocios de comida como taquerías, restaurantes pequeños y food trucks. La aplicación permite gestionar ventas, inventario, gastos y cierres de caja de manera eficiente, con soporte offline-first para garantizar operación continua incluso sin conexión a internet.

### 🎯 Objetivo

Proporcionar a los negocios de comida una herramienta móvil, intuitiva y confiable para:
- Registrar ventas rápidamente
- Gestionar inventario de productos
- Controlar gastos y cortes de caja
- Vincular múltiples cajeros a un negocio
- Sincronizar datos automáticamente con el backend cuando hay conexión

---

## ✨ Características Principales

### 👤 Autenticación y Roles
- ✅ **Login con Google Sign-In** - Autenticación segura usando cuentas de Google
- 🔐 **JWT Storage** - Tokens almacenados de forma segura en Keychain/Keystore
- 👥 **Dos roles de usuario**:
  - **Patrón**: Dueño del negocio con acceso total al dashboard
  - **Cajero**: Empleado con acceso limitado a registro de ventas

### 💰 Gestión de Ventas
- 📱 **Registro de ventas** con catálogo de productos
- ❌ **Cancelación de ventas** con foto obligatoria
- 💵 **Múltiples métodos de pago**: efectivo, tarjeta, transferencia
- 📊 **Resumen de turno** ("¿Cómo voy?")

### 📦 Inventario y Catálogo
- 🏷️ **Catálogo offline-first** sincronizado desde el backend
- 🔄 **Sincronización automática** cada 5 minutos
- 📂 **Categorías de productos** para organización

### 💸 Gastos y Cortes
- 🧾 **Registro de gastos** con categorías
- 🔒 **Corte de caja** (cierre de turno) con arqueo
- 📸 **Fotos de comprobantes** para gastos y cancelaciones

### 🔄 Sincronización
- ☁️ **Sync automático** de transacciones cada 5 minutos
- 🚦 **Indicador de estado** de sincronización
- 📡 **Modo offline-first** - la app funciona sin internet
- ⚡ **Sync prioritario**: sesiones → ventas → gastos → cortes

### 🔗 Vinculación de Cajeros
- 📱 **Código QR** generado por el Patrón
- 🔓 **Escaneo QR** por el Cajero para vincular al negocio
- ⏱️ **Tokens con expiración** para seguridad

### 📊 Dashboard del Patrón
- 📈 **Métricas de negocio** (ventas, gastos, utilidad)
- 👥 **Gestión de cajeros** vinculados
- 📉 **Historial de transacciones**
- 💼 **Estadísticas por periodo**

---

## 🏗️ Arquitectura

La aplicación sigue los principios de **Clean Architecture** con separación en capas:

```
lib/
├── core/                    # Constantes, errores, utilidades compartidas
│   ├── constants/          # API endpoints, configuración
│   ├── errors/             # Exceptions, Failures
│   └── network/            # NetworkInfo
│
├── domain/                  # Capa de dominio (lógica de negocio)
│   ├── entities/           # Modelos de negocio puros
│   ├── repositories/       # Interfaces de repositorios
│   └── usecases/           # Casos de uso de la aplicación
│
├── infrastructure/          # Capa de infraestructura (implementaciones)
│   ├── datasources/        # Fuentes de datos (local/remoto)
│   │   ├── local/         # SQLite/Drift DAOs
│   │   └── remote/        # REST API clients
│   ├── repositories/       # Implementaciones de repositorios
│   └── services/          # Servicios (storage, sync)
│
└── presentation/            # Capa de presentación (UI)
    ├── blocs/              # BLoC state management
    ├── pages/              # Pantallas de la app
    ├── widgets/            # Componentes reutilizables
    └── router/             # Navegación con go_router
```

### 🔑 Patrones de Diseño

- **Clean Architecture**: Separación de capas e inversión de dependencias
- **BLoC Pattern**: Gestión de estado con flutter_bloc
- **Repository Pattern**: Abstracción de fuentes de datos
- **Dependency Injection**: Inyección de dependencias con get_it
- **Offline-First**: Base de datos local con Drift y sincronización en background

---

## 🔧 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- **Flutter SDK**: `3.11.5` o superior ([Instalar Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: `3.11.5` o superior (incluido con Flutter)
- **Android Studio** / **Xcode**: Para emuladores y compilación nativa
- **Git**: Para clonar el repositorio
- **Cuenta de Google Cloud Platform**: Para configurar Google Sign-In OAuth

### Verificar instalación de Flutter

```bash
flutter --version
flutter doctor
```

---

## 📥 Instalación

### 1. Clonar el Repositorio

```bash
git clone https://github.com/tu-usuario/taco-os-app.git
cd taco-os-app/taco_os_app
```

### 2. Instalar Dependencias

```bash
flutter pub get
```

### 3. Generar Código (Drift, BLoC)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Configurar Google Sign-In

Sigue las instrucciones detalladas en [GOOGLE_CONFIG_COMPLETO.md](./GOOGLE_CONFIG_COMPLETO.md)

---

## ⚙️ Configuración

### Google Sign-In

La aplicación utiliza Google Sign-In para autenticación. Necesitas configurar OAuth 2.0 en Google Cloud Platform:

#### Paso 1: Crear Proyecto en Google Cloud Platform

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita la API de Google Sign-In

#### Paso 2: Crear Credenciales OAuth 2.0

Necesitas crear **3 Client IDs**:

1. **Web Client ID** (para la aplicación)
2. **Android Client ID** (para la app Android)
3. **iOS Client ID** (para la app iOS)

#### Paso 3: Configurar en la App

##### Android

1. Copia tu Web Client ID y agrégalo en:

**`android/app/build.gradle.kts`**:
```kotlin
android {
    defaultConfig {
        // ...
        resValue("string", "default_web_client_id", "\"TU_WEB_CLIENT_ID_AQUI\"")
    }
}
```

2. Descarga `google-services.json` desde Firebase/GCP y colócalo en:
```
android/app/google-services.json
```

##### iOS

Edita **`ios/Runner/Info.plist`**:
```xml
<key>GIDClientID</key>
<string>TU_IOS_CLIENT_ID_AQUI</string>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.TU_IOS_CLIENT_ID_INVERTIDO</string>
        </array>
    </dict>
</array>
```

📖 **Documentación completa**: Ver [GOOGLE_CONFIG_COMPLETO.md](./GOOGLE_CONFIG_COMPLETO.md)

### Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto (basado en `.env.example`):

```bash
cp .env.example .env
```

Edita `.env` con tus configuraciones:

```env
# Backend API
API_BASE_URL=https://tu-backend.com/api
API_TIMEOUT=30000

# Google Sign-In (Web Client ID)
GOOGLE_WEB_CLIENT_ID=921503491132-XXXXXXXXXX.apps.googleusercontent.com

# Entorno
ENVIRONMENT=development
```

### Backend

La app requiere un backend REST API con los siguientes endpoints:

- `POST /api/auth/google` - Autenticación con Google
- `POST /api/auth/signout` - Cerrar sesión
- `GET /api/auth/me` - Obtener usuario actual
- `GET /api/products` - Obtener catálogo de productos
- `POST /api/transactions/sync` - Sincronizar transacciones
- ... (más endpoints según funcionalidad)

Configura la URL del backend en `lib/core/constants/api_endpoints.dart`:

```dart
class ApiEndpoints {
  static const String baseUrl = 'https://tu-backend.com/api';
  // ...
}
```

---

## 🚀 Ejecución

### Ejecutar en Modo Debug

#### Android
```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en dispositivo específico
flutter run -d <device-id>

# Ejecutar en emulador Android
flutter run -d emulator-5554
```

#### iOS
```bash
# Ejecutar en simulador iOS
flutter run -d "iPhone 14 Pro"

# Ejecutar en dispositivo físico iOS
flutter run -d <device-id>
```

### Ejecutar en Modo Release

```bash
flutter run --release -d <device-id>
```

### Compilar APK (Android)

```bash
# APK universal
flutter build apk

# APK separados por arquitectura (más ligeros)
flutter build apk --split-per-abi
```

### Compilar App Bundle (Android - para Play Store)

```bash
flutter build appbundle
```

### Compilar IPA (iOS)

```bash
flutter build ipa
```

### Hot Reload y Hot Restart

Mientras la app está ejecutándose:
- **Hot Reload**: `r` - Recarga cambios sin perder estado
- **Hot Restart**: `R` - Reinicia la app desde cero
- **Quit**: `q` - Detiene la ejecución

---

## 📁 Estructura del Proyecto

```
taco_os_app/
├── android/                      # Proyecto Android nativo
│   ├── app/
│   │   ├── build.gradle.kts     # Configuración de Gradle
│   │   ├── google-services.json # Config de Google Sign-In
│   │   └── src/
│   └── gradle/
│
├── ios/                          # Proyecto iOS nativo
│   ├── Runner/
│   │   ├── Info.plist           # Configuración de la app
│   │   └── Assets.xcassets/
│   └── Podfile
│
├── lib/                          # Código Dart de la aplicación
│   ├── core/                    # Núcleo compartido
│   │   ├── constants/
│   │   ├── errors/
│   │   └── network/
│   │
│   ├── domain/                   # Capa de dominio
│   │   ├── entities/            # User, Product, Transaction, etc.
│   │   ├── repositories/        # Interfaces
│   │   └── usecases/            # Lógica de negocio
│   │
│   ├── infrastructure/           # Capa de infraestructura
│   │   ├── datasources/
│   │   │   ├── local/          # Drift/SQLite
│   │   │   └── remote/         # Dio/REST
│   │   ├── repositories/        # Implementaciones
│   │   └── services/            # Storage, Sync
│   │
│   ├── presentation/             # Capa de presentación
│   │   ├── blocs/               # BLoC state management
│   │   │   ├── auth/
│   │   │   ├── cajero/
│   │   │   └── patron/
│   │   ├── pages/               # Pantallas
│   │   │   ├── splash/
│   │   │   ├── auth/
│   │   │   ├── cajero/
│   │   │   └── patron/
│   │   ├── widgets/             # Componentes UI
│   │   └── router/              # Navegación
│   │
│   ├── injection_container.dart # Dependency Injection (get_it)
│   ├── main.dart                # Entry point
│   └── app.dart                 # Widget raíz
│
├── test/                         # Tests unitarios e integración
│   ├── domain/
│   ├── infrastructure/
│   └── presentation/
│
├── assets/                       # Recursos estáticos
│   └── images/                  # Imágenes y logos
│
├── .env.example                  # Ejemplo de variables de entorno
├── .gitignore
├── pubspec.yaml                  # Dependencias de Flutter
├── analysis_options.yaml         # Reglas de lint
└── README.md                     # Este archivo
```

---

## 🛠️ Tecnologías

### Framework y Lenguaje
- **Flutter** `3.11.5+` - Framework multiplataforma
- **Dart** `3.11.5+` - Lenguaje de programación

### State Management
- **flutter_bloc** `^9.1.1` - BLoC pattern para gestión de estado
- **equatable** `^2.0.7` - Comparación de objetos inmutables

### Networking
- **dio** `^5.9.2` - Cliente HTTP para REST API
- **connectivity_plus** `^7.1.1` - Detección de conectividad

### Base de Datos Local
- **drift** `^2.34.0` - ORM SQLite type-safe
- **drift_flutter** `^0.3.0` - Plugin de Flutter para Drift

### Autenticación
- **google_sign_in** `^6.2.1` - Autenticación con Google
- **flutter_secure_storage** `^10.3.1` - Almacenamiento seguro de JWT

### Navegación
- **go_router** `^17.3.0` - Navegación declarativa

### Utilidades
- **fpdart** `^1.2.0` - Programación funcional (Either, Option)
- **get_it** `^9.2.1` - Dependency Injection
- **uuid** `^4.5.1` - Generación de UUIDs
- **intl** `^0.19.0` - Internacionalización y formateo

### Features
- **mobile_scanner** `^7.2.0` - Escaneo de códigos QR
- **qr_flutter** `^4.1.0` - Generación de códigos QR
- **image_picker** `^1.1.2` - Captura de fotos
- **permission_handler** `^12.0.0` - Manejo de permisos

### Testing
- **flutter_test** - Tests unitarios
- **bloc_test** `^10.0.0` - Tests de BLoCs
- **mocktail** `^1.0.0` - Mocking para tests

### Development
- **flutter_lints** `^6.0.0` - Reglas de lint
- **build_runner** `^2.15.0` - Generación de código
- **drift_dev** `^2.34.0` - Generador de código Drift

---

## 🧪 Testing

### Ejecutar Todos los Tests

```bash
flutter test
```

### Ejecutar Tests Específicos

```bash
# Test de un archivo específico
flutter test test/domain/usecases/auth/sign_in_use_case_test.dart

# Tests por carpeta
flutter test test/domain/
```

### Cobertura de Tests

```bash
# Generar reporte de cobertura
flutter test --coverage

# Ver reporte en HTML (requiere lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Tests de Integración

```bash
flutter test integration_test/
```

---

## 📚 Documentación Adicional

- **[GOOGLE_CONFIG_COMPLETO.md](./GOOGLE_CONFIG_COMPLETO.md)** - Configuración detallada de Google Sign-In
- **[GOOGLE_SIGNIN_SETUP.md](./GOOGLE_SIGNIN_SETUP.md)** - Guía rápida de setup
- **[GOOGLE_SIGNIN_FIX_SUMMARY.md](./GOOGLE_SIGNIN_FIX_SUMMARY.md)** - Solución de problemas comunes

---

## 🤝 Contribuir

Este es un proyecto privado. Si tienes acceso al repositorio y deseas contribuir:

### 1. Crear una Rama

```bash
git checkout -b feature/nueva-funcionalidad
```

### 2. Hacer Cambios

```bash
git add .
git commit -m "feat: descripción de la funcionalidad"
```

### 3. Push y Pull Request

```bash
git push origin feature/nueva-funcionalidad
```

Luego crea un Pull Request en GitHub.

### Convenciones de Commits

Seguimos [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - Nueva funcionalidad
- `fix:` - Corrección de bug
- `docs:` - Cambios en documentación
- `style:` - Formateo, punto y coma faltante, etc.
- `refactor:` - Refactorización de código
- `test:` - Agregar tests
- `chore:` - Cambios en build, dependencias, etc.

---

## 📄 Licencia

Este proyecto es **privado** y no tiene licencia pública. Todos los derechos reservados.

---

## 👥 Equipo de Desarrollo

- **Desarrollador Principal**: [Tu Nombre]
- **Backend**: [Nombre del desarrollador backend]
- **Diseño UI/UX**: [Nombre del diseñador]

---

## 📞 Contacto y Soporte

Para preguntas, reportar bugs o solicitar nuevas funcionalidades:

- **Email**: soporte@tacoosapp.com
- **Slack**: #taco-os-dev
- **Issues**: [GitHub Issues](https://github.com/tu-usuario/taco-os-app/issues)

---

## 🔄 Changelog

### v1.0.0 (YYYY-MM-DD)
- ✅ Autenticación con Google Sign-In
- ✅ Gestión de roles (Patrón/Cajero)
- ✅ Registro de ventas
- ✅ Catálogo offline-first
- ✅ Sincronización automática
- ✅ Dashboard del Patrón
- ✅ Vinculación de cajeros por QR

---

<div align="center">

**[⬆ Volver arriba](#-tacos-app)**

Hecho con ❤️ para negocios de comida

</div>
