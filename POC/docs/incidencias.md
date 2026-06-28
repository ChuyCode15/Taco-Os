# Registro de Incidencias (Log de Errores)

| Fecha | Error | Módulo | Descripción | Solución/Estado |
| :--- | :--- | :--- | :--- | :--- |
| 2024-05-22 | Error 10 (Developer Error) | Auth / Google Sign-In | Falla al intentar loguear con Google. | SOLUCIONADO: Se cambió el SERVER_CLIENT_ID del ID de Android al ID de Aplicación Web como requiere el SDK. |
| 2024-05-22 | Error HTTP 403 | App / createBusiness | El servidor responde con 403 en el segundo paso del registro. | SOLUCIONADO: Se implementó un Interceptor en OkHttp para enviar el Token JWT recibido tras el primer paso (auth/registrar) en las llamadas subsiguientes. |
| 2024-05-22 | Error HTTP 409 | App / registerUser | El servidor responde con 409 (Conflict). | SOLUCIONADO: Se implementó un NetworkUtils que extrae el "mensaje" exacto del backend para mostrarlo en un Alert al usuario (ej: "Usuario ya registrado"). |
