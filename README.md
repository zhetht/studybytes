# 👻 StudyBytes

Tu plataforma de estudio social con IA — Posts, Clubes, Biblioteca, Zona Zen y más.

## 🚀 Setup en 10 minutos

### 1. Supabase (base de datos + auth)

1. Ve a [supabase.com](https://supabase.com) y crea una cuenta gratuita
2. Crea un **Nuevo Proyecto** (elige región cercana a México: `South America - São Paulo`)
3. En el menú lateral → **SQL Editor** → pega TODO el contenido de `supabase-schema.sql` → Run
4. En el menú lateral → **Storage** → **New Bucket**:
   - Nombre: `library`
   - Public bucket: ✅ activado
5. En **Settings** → **API** → copia:
   - `Project URL` → es tu `NEXT_PUBLIC_SUPABASE_URL`
   - `anon public` key → es tu `NEXT_PUBLIC_SUPABASE_ANON_KEY`

### 2. Variables de entorno

Crea un archivo `.env.local` en la raíz del proyecto:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://XXXXXX.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 3. Instalar y correr localmente

```bash
npm install
npm run dev
```

Abre [http://localhost:3000](http://localhost:3000)

### 4. Deploy en Vercel

1. Ve a [vercel.com](https://vercel.com) → conecta tu cuenta de GitHub
2. Sube este proyecto a un repositorio GitHub
3. En Vercel → **Add New Project** → importa el repo
4. En la sección **Environment Variables** agrega:
   - `NEXT_PUBLIC_SUPABASE_URL` = tu URL de Supabase
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` = tu anon key
5. Haz clic en **Deploy** 🚀

## 📱 Funcionalidades

| Sección | Descripción |
|---------|-------------|
| 🏠 Inicio | Manual de uso + cards de navegación |
| 💬 Posts | Preguntas públicas con likes y tags |
| 🎓 Clubes | Chats en tiempo real por materia |
| 📚 Biblioteca | Subir/descargar material educativo |
| 🌿 Zona Zen | Diario, tareas, Pomodoro, modo enfoque |
| ✨ Perfil | Avatar personalizable, bio, estadísticas |
| 👻 Specter | Burbuja flotante (IA próximamente) |

## ⚠️ Plan Gratuito — Límites

### Supabase Free Tier:
- 500 MB de base de datos
- 1 GB de almacenamiento en Storage
- 2 GB de transferencia/mes
- Autenticación ilimitada
- Tiempo real incluido
- **Suficiente para 1 semana de uso normal** ✅

### Vercel Free Tier (Hobby):
- 100 GB de ancho de banda/mes
- Deployments ilimitados
- **Más que suficiente** ✅

## 🔑 Variables necesarias

Solo necesitas 2 variables de entorno:

```
NEXT_PUBLIC_SUPABASE_URL       # URL de tu proyecto Supabase
NEXT_PUBLIC_SUPABASE_ANON_KEY  # Llave pública anon de Supabase
```

¡Eso es todo! No se necesita API key de IA todavía (Specter se conectará en una futura versión).

## 🛠️ Stack Técnico

- **Frontend**: Next.js 14 + TypeScript + CSS Variables
- **Estilos**: Tailwind CSS + CSS custom
- **Base de datos**: Supabase (PostgreSQL)
- **Auth**: Supabase Auth (email + password)
- **Storage**: Supabase Storage (archivos)
- **Realtime**: Supabase Realtime (chat de clubes)
- **Deploy**: Vercel
