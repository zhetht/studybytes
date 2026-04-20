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

