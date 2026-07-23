# Assets - Images

## Taco'Os Logo (Opcional)

Para agregar un logo personalizado a la pantalla Splash:

1. Coloca tu imagen de logo en este directorio con el nombre `logo.png`
2. La imagen será usada automáticamente por el SplashPage

**Nota:** Si no se proporciona un logo, el SplashPage usará un Text widget estilizado con "Taco'Os" como fallback.

Formatos recomendados:
- PNG con fondo transparente
- Dimensiones sugeridas: 512x512px o mayor
- Resoluciones múltiples (opcional):
  - `logo.png` - versión base
  - `logo@2x.png` - versión 2x
  - `logo@3x.png` - versión 3x

## Google Logo

Para agregar el logo de Google al botón de inicio de sesión:

1. Descarga el logo oficial de Google desde:
   https://developers.google.com/identity/branding-guidelines

2. Guárdalo como `google_logo.png` en este directorio

**Nota:** El LoginPage tiene un fallback que muestra un ícono genérico si la imagen no está presente.
