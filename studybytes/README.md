# StudyBytes 📚

Una plataforma de estudio social construida con Flutter.

## 🚀 Características

- **Autenticación** — Login y registro con persistencia local (SharedPreferences)
- **Posts** — Feed educativo con crear, eliminar y dar like
- **Clubs de Estudio** — Chat en tiempo real (mock local)
- **Biblioteca** — Documentos con soporte premium
- **Asistente IA** — Burbuja flotante con Gemini AI
- **Premium** — Sistema de planes de pago (mock)
- **Tema oscuro** — Diseño moderno con paleta `#DCD6F7` / `#D7F2E3` / `#F7C9CC`

---

## ⚙️ Setup

### 1. Instalar dependencias

```bash
flutter pub get
```

### 2. Configurar Gemini API Key (opcional)

Edita `lib/core/constants/app_constants.dart`:

```dart
static const String geminiApiKey = 'TU_API_KEY_AQUI';
```

Obtén tu clave gratuita en: https://aistudio.google.com/app/apikey

> Si dejas la clave de placeholder, el asistente funcionará en modo demo con respuestas predefinidas.

### 3. Ejecutar la app

```bash
flutter run
```

---

## 🔑 Credenciales de prueba

| Email | Contraseña | Premium |
|-------|-----------|---------|
| ghosty@studybytes.com | 123456 | ✅ |
| test@example.com | 123456 | ❌ |

O puedes registrar una cuenta nueva desde la pantalla de registro.

---

## 📁 Estructura

```
lib/
├── core/
│   ├── theme/          # AppTheme con colores de marca
│   └── constants/      # Constantes globales y API keys
├── features/
│   ├── auth/           # Login, Register, AuthBloc
│   ├── home/           # MainPage con navegación responsiva
│   ├── clubs/          # Lista de clubs + chat
│   ├── posts/          # Feed + crear post
│   ├── library/        # Documentos con filtros
│   ├── profile/        # Perfil de usuario
│   └── premium/        # Pantalla de planes + PaymentService
└── widgets/
    └── ai_bubble/      # Asistente IA flotante (Gemini)
```

---

## 🎨 Paleta de colores

| Variable | Color | Uso |
|----------|-------|-----|
| `AppTheme.lavender` | `#DCD6F7` | Chips, etiquetas |
| `AppTheme.mint` | `#D7F2E3` | Estadísticas, confirmaciones |
| `AppTheme.pink` | `#F7C9CC` | Login, hints de error |
| `AppTheme.primaryBlue` | `#4A6CF7` | Primario, botones, selección |
| `AppTheme.darkBg` | `#0F0F1A` | Fondo principal |
| `AppTheme.cardDark` | `#1A1A2E` | Tarjetas y sidebar |

---

## 🔧 Próximos pasos sugeridos

- [ ] Conectar Firebase Auth (reemplaza `LocalAuthService`)
- [ ] Conectar Firestore para posts y clubs reales
- [ ] Integrar Stripe o RevenueCat para pagos reales
- [ ] Implementar push notifications
- [ ] Subida de archivos con Firebase Storage
