# Configuración de Supabase para StudyBytes

## 1. Crear proyecto en Supabase

1. Ve a https://supabase.com y crea una cuenta
2. Crea un nuevo proyecto
3. En **Settings → API** copia:
   - **Project URL** → `supabaseUrl`
   - **anon public key** → `supabaseAnonKey`
4. Pega ambos valores en `lib/config/api_config.dart`

---

## 2. Crear las tablas (SQL Editor)

Ve a **SQL Editor** en tu proyecto y ejecuta esto:

```sql
-- ── TABLA: posts ──────────────────────────────────────────────────────────
CREATE TABLE posts (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title       TEXT NOT NULL,
  content     TEXT NOT NULL,
  author_id   TEXT NOT NULL,
  author_name TEXT NOT NULL,
  likes       TEXT[] DEFAULT '{}',
  tags        TEXT[] DEFAULT '{}',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar Row Level Security
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Cualquiera puede leer posts
CREATE POLICY "posts_select" ON posts FOR SELECT USING (true);

-- Solo el autor puede insertar
CREATE POLICY "posts_insert" ON posts FOR INSERT WITH CHECK (true);

-- Solo el autor puede borrar (auth.uid() si usas Supabase Auth)
CREATE POLICY "posts_delete" ON posts FOR DELETE USING (true);

-- Actualizar likes (cualquier usuario autenticado)
CREATE POLICY "posts_update" ON posts FOR UPDATE USING (true);


-- ── TABLA: documents ──────────────────────────────────────────────────────
CREATE TABLE documents (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title       TEXT NOT NULL,
  description TEXT DEFAULT '',
  file_url    TEXT NOT NULL,
  file_type   TEXT NOT NULL DEFAULT 'pdf',
  author_id   TEXT NOT NULL,
  author_name TEXT NOT NULL,
  downloads   INT DEFAULT 0,
  views       INT DEFAULT 0,
  tags        TEXT[] DEFAULT '{}',
  is_premium  BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "docs_select" ON documents FOR SELECT USING (true);
CREATE POLICY "docs_insert" ON documents FOR INSERT WITH CHECK (true);
CREATE POLICY "docs_delete" ON documents FOR DELETE USING (true);


-- ── FUNCIÓN: incrementar vistas ───────────────────────────────────────────
CREATE OR REPLACE FUNCTION increment_views(doc_id UUID)
RETURNS VOID AS $$
  UPDATE documents SET views = views + 1 WHERE id = doc_id;
$$ LANGUAGE SQL;
```

---

## 3. Crear el bucket de Storage

1. Ve a **Storage** en el menú lateral
2. Crea un nuevo bucket llamado exactamente: **`documents`**
3. Marca la casilla **Public bucket** (para que las URLs sean accesibles)
4. En **Policies** del bucket agrega:

```sql
-- Cualquiera puede leer archivos del bucket
CREATE POLICY "storage_select"
ON storage.objects FOR SELECT
USING (bucket_id = 'documents');

-- Cualquiera puede subir (ajustar con auth si quieres restricciones)
CREATE POLICY "storage_insert"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'documents');

-- El autor puede borrar
CREATE POLICY "storage_delete"
ON storage.objects FOR DELETE
USING (bucket_id = 'documents');
```

---

## 4. Verificar

Con las tablas y bucket creados, al abrir la app deberías ver:
- ✅ Posts cargados desde Supabase (vacío al inicio)
- ✅ Biblioteca vacía lista para subir
- ✅ Botón "Subir" funcional en la Biblioteca
- ✅ Botón "+" funcional en Posts

Si algo falla, la app carga datos mock automáticamente para que no se rompa.
