import Layout from '@/components/Layout'
import { useState, useEffect, useRef } from 'react'
import { supabase } from '@/lib/supabase'
import toast from 'react-hot-toast'

const SUBJECTS = ['Matemáticas', 'Física', 'Historia', 'Programación', 'Biología', 'Química', 'Literatura', 'Idiomas', 'Arte', 'Otro']

type LibItem = {
  id: string; title: string; description: string; file_url: string; file_type: string;
  subject: string; created_at: string; username: string; user_id: string
}

const getFileIcon = (type: string) => {
  if (type?.includes('pdf')) return '📄'
  if (type?.includes('image')) return '🖼️'
  if (type?.includes('word') || type?.includes('document')) return '📝'
  if (type?.includes('presentation') || type?.includes('powerpoint')) return '📊'
  if (type?.includes('sheet') || type?.includes('excel')) return '📈'
  return '📁'
}

export default function LibraryPage() {
  const [items, setItems] = useState<LibItem[]>([])
  const [showForm, setShowForm] = useState(false)
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [subject, setSubject] = useState('Otro')
  const [file, setFile] = useState<File | null>(null)
  const [loading, setLoading] = useState(false)
  const [filterSubject, setFilterSubject] = useState('')
  const [search, setSearch] = useState('')
  const [userId, setUserId] = useState('')
  const fileRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    loadItems()
    supabase.auth.getUser().then(({ data: { user } }) => { if (user) setUserId(user.id) })
  }, [])

  const loadItems = async () => {
    const { data } = await supabase.from('library_items').select('*').order('created_at', { ascending: false })
    if (data) setItems(data)
  }

  const uploadItem = async () => {
    if (!title || !file) return toast.error('Necesitas un título y un archivo')
    setLoading(true)
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const ext = file.name.split('.').pop()
    const path = `${user.id}/${Date.now()}.${ext}`
    const { error: uploadError } = await supabase.storage.from('library').upload(path, file)
    if (uploadError) { toast.error('Error al subir archivo'); setLoading(false); return }

    const { data: urlData } = supabase.storage.from('library').getPublicUrl(path)
    const { data: profile } = await supabase.from('profiles').select('username').eq('id', user.id).single()

    await supabase.from('library_items').insert({
      user_id: user.id,
      title,
      description,
      file_url: urlData.publicUrl,
      file_type: file.type,
      subject,
      username: profile?.username || 'Anon'
    })

    toast.success('¡Material subido!')
    setTitle(''); setDescription(''); setFile(null); setShowForm(false)
    loadItems()
    setLoading(false)
  }

  const deleteItem = async (id: string) => {
    await supabase.from('library_items').delete().eq('id', id)
    toast.success('Eliminado')
    loadItems()
  }

  const filtered = items
    .filter(i => !filterSubject || i.subject === filterSubject)
    .filter(i => !search || i.title.toLowerCase().includes(search.toLowerCase()) || i.description?.toLowerCase().includes(search.toLowerCase()))

  const timeAgo = (date: string) => {
    const diff = Date.now() - new Date(date).getTime()
    const days = Math.floor(diff / 86400000)
    if (days === 0) return 'hoy'
    if (days === 1) return 'ayer'
    return `hace ${days} días`
  }

  return (
    <Layout>
      <div style={{ padding: '24px 0', animation: 'fadeIn 0.5s ease' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '28px' }}>
          <div>
            <h1 style={{ fontFamily: 'var(--font-display)', fontWeight: '800', fontSize: '28px', color: 'white', marginBottom: '4px' }}>
              📚 Biblioteca
            </h1>
            <p style={{ color: 'rgba(255,255,255,0.4)', fontSize: '13px', fontFamily: 'var(--font-body)' }}>
              Material educativo compartido por la comunidad
            </p>
          </div>
          <button className="btn-primary" onClick={() => setShowForm(!showForm)} style={{ fontSize: '13px', padding: '10px 18px' }}>
            + Subir material
          </button>
        </div>

        {/* Upload form */}
        {showForm && (
          <div style={{
            background: 'rgba(220,214,247,0.05)', border: '1px solid rgba(220,214,247,0.15)',
            borderRadius: '20px', padding: '24px', marginBottom: '28px', animation: 'fadeIn 0.3s ease'
          }}>
            <h3 style={{ fontFamily: 'var(--font-display)', fontWeight: '700', fontSize: '16px', color: '#dcd6f7', marginBottom: '16px' }}>
              📤 Subir material
            </h3>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px', marginBottom: '14px' }}>
              <input className="input-field" placeholder="Título del material" value={title} onChange={e => setTitle(e.target.value)} />
              <select
                value={subject}
                onChange={e => setSubject(e.target.value)}
                style={{
                  background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.12)',
                  borderRadius: '12px', padding: '12px 16px', color: 'white', fontFamily: 'var(--font-body)',
                  fontSize: '14px', outline: 'none', cursor: 'pointer'
                }}
              >
                {SUBJECTS.map(s => <option key={s} value={s} style={{ background: '#04192d' }}>{s}</option>)}
              </select>
            </div>
            <textarea className="input-field" placeholder="Descripción (opcional)" value={description}
              onChange={e => setDescription(e.target.value)} rows={2} style={{ resize: 'none', marginBottom: '14px' }} />
            <div
              onClick={() => fileRef.current?.click()}
              style={{
                border: '2px dashed rgba(220,214,247,0.25)', borderRadius: '12px', padding: '24px',
                textAlign: 'center', cursor: 'pointer', marginBottom: '14px',
                background: file ? 'rgba(220,214,247,0.06)' : 'transparent',
                transition: 'all 0.2s'
              }}
            >
              <p style={{ color: 'rgba(255,255,255,0.4)', fontSize: '13px', fontFamily: 'var(--font-body)' }}>
                {file ? `✅ ${file.name}` : '📎 Haz clic para seleccionar un archivo (PDF, imágenes, documentos)'}
              </p>
              <input ref={fileRef} type="file" style={{ display: 'none' }} onChange={e => setFile(e.target.files?.[0] || null)}
                accept=".pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx,.png,.jpg,.jpeg,.gif" />
            </div>
            <div style={{ display: 'flex', gap: '10px' }}>
              <button className="btn-primary" onClick={uploadItem} disabled={loading} style={{ flex: 1 }}>
                {loading ? '⏳ Subiendo...' : '📤 Subir'}
              </button>
              <button className="btn-secondary" onClick={() => setShowForm(false)}>Cancelar</button>
            </div>
          </div>
        )}

        {/* Search + filter */}
        <div style={{ display: 'flex', gap: '12px', marginBottom: '20px', flexWrap: 'wrap' }}>
          <input className="input-field" placeholder="🔍 Buscar material..." value={search}
            onChange={e => setSearch(e.target.value)} style={{ flex: 1, minWidth: '200px' }} />
          <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
            <button onClick={() => setFilterSubject('')} style={{
              padding: '8px 14px', borderRadius: '20px', border: !filterSubject ? '1px solid #dcd6f7' : '1px solid rgba(255,255,255,0.1)',
              background: !filterSubject ? 'rgba(220,214,247,0.15)' : 'transparent',
              color: !filterSubject ? '#dcd6f7' : 'rgba(255,255,255,0.4)',
              cursor: 'pointer', fontSize: '12px', fontFamily: 'var(--font-body)', transition: 'all 0.2s'
            }}>Todos</button>
            {SUBJECTS.map(s => (
              <button key={s} onClick={() => setFilterSubject(s)} style={{
                padding: '8px 14px', borderRadius: '20px', border: filterSubject === s ? '1px solid #dcd6f7' : '1px solid rgba(255,255,255,0.1)',
                background: filterSubject === s ? 'rgba(220,214,247,0.15)' : 'transparent',
                color: filterSubject === s ? '#dcd6f7' : 'rgba(255,255,255,0.4)',
                cursor: 'pointer', fontSize: '12px', fontFamily: 'var(--font-body)', transition: 'all 0.2s'
              }}>{s}</button>
            ))}
          </div>
        </div>

        {/* Grid */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '16px' }}>
          {filtered.length === 0 && (
            <div style={{ gridColumn: '1/-1', textAlign: 'center', padding: '60px 20px', color: 'rgba(255,255,255,0.3)' }}>
              <div style={{ fontSize: '48px', marginBottom: '12px' }}>📚</div>
              <p style={{ fontFamily: 'var(--font-body)' }}>No hay material aún. ¡Sé el primero en compartir!</p>
            </div>
          )}
          {filtered.map(item => (
            <div key={item.id} className="lib-item">
              <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: '12px' }}>
                <div style={{ fontSize: '32px' }}>{getFileIcon(item.file_type)}</div>
                <span style={{
                  padding: '3px 10px', borderRadius: '20px',
                  background: 'rgba(220,214,247,0.12)', border: '1px solid rgba(220,214,247,0.2)',
                  color: '#dcd6f7', fontSize: '11px', fontFamily: 'var(--font-body)'
                }}>{item.subject}</span>
              </div>
              <h3 style={{ fontFamily: 'var(--font-display)', fontWeight: '700', fontSize: '16px', color: 'white', marginBottom: '6px' }}>
                {item.title}
              </h3>
              {item.description && (
                <p style={{ color: 'rgba(255,255,255,0.45)', fontSize: '13px', fontFamily: 'var(--font-body)', lineHeight: '1.5', marginBottom: '12px' }}>
                  {item.description}
                </p>
              )}
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: '12px' }}>
                <p style={{ color: 'rgba(255,255,255,0.25)', fontSize: '11px', fontFamily: 'var(--font-body)' }}>
                  {item.username} · {timeAgo(item.created_at)}
                </p>
                <div style={{ display: 'flex', gap: '8px' }}>
                  <a href={item.file_url} target="_blank" rel="noopener noreferrer" style={{
                    padding: '6px 12px', borderRadius: '10px', background: 'rgba(220,214,247,0.15)',
                    border: '1px solid rgba(220,214,247,0.25)', color: '#dcd6f7',
                    textDecoration: 'none', fontSize: '12px', fontFamily: 'var(--font-body)', transition: 'all 0.2s'
                  }}>Ver/Descargar</a>
                  {item.user_id === userId && (
                    <button onClick={() => deleteItem(item.id)} style={{
                      padding: '6px', borderRadius: '10px', background: 'rgba(255,80,80,0.08)',
                      border: '1px solid rgba(255,80,80,0.2)', color: 'rgba(255,100,100,0.7)',
                      cursor: 'pointer', fontSize: '13px', transition: 'all 0.2s'
                    }}>🗑️</button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </Layout>
  )
}
