import Layout from '@/components/Layout'
import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'
import toast from 'react-hot-toast'

const TAGS = ['Matemáticas', 'Física', 'Historia', 'Programación', 'Biología', 'Química', 'Literatura', 'Otro']

type Post = {
  id: string
  content: string
  tags: string[]
  likes: number
  created_at: string
  username: string
  avatar_emoji: string
  avatar_color: string
  user_id: string
}

export default function PostsPage() {
  const [posts, setPosts] = useState<Post[]>([])
  const [content, setContent] = useState('')
  const [selectedTag, setSelectedTag] = useState('Otro')
  const [filterTag, setFilterTag] = useState('')
  const [loading, setLoading] = useState(false)
  const [userId, setUserId] = useState('')
  const [showForm, setShowForm] = useState(false)

  useEffect(() => {
    loadPosts()
    supabase.auth.getUser().then(({ data: { user } }) => {
      if (user) setUserId(user.id)
    })
  }, [])

  const loadPosts = async () => {
    const { data } = await supabase
      .from('posts')
      .select('*')
      .order('created_at', { ascending: false })
    if (data) setPosts(data)
  }

  const createPost = async () => {
    if (!content.trim()) return toast.error('Escribe algo primero')
    setLoading(true)
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return
    const { data: profile } = await supabase.from('profiles').select('*').eq('id', user.id).single()
    const { error } = await supabase.from('posts').insert({
      user_id: user.id,
      content: content.trim(),
      tags: [selectedTag],
      likes: 0,
      username: profile?.username || 'Anon',
      avatar_emoji: profile?.avatar_emoji || '📚',
      avatar_color: profile?.avatar_color || '#9c6bff'
    })
    if (error) toast.error('Error al publicar')
    else {
      toast.success('¡Publicado!')
      setContent('')
      setShowForm(false)
      loadPosts()
    }
    setLoading(false)
  }

  const likePost = async (post: Post) => {
    await supabase.from('posts').update({ likes: post.likes + 1 }).eq('id', post.id)
    loadPosts()
  }

  const deletePost = async (id: string) => {
    await supabase.from('posts').delete().eq('id', id)
    toast.success('Post eliminado')
    loadPosts()
  }

  const filtered = filterTag ? posts.filter(p => p.tags?.includes(filterTag)) : posts

  const timeAgo = (date: string) => {
    const diff = Date.now() - new Date(date).getTime()
    const mins = Math.floor(diff / 60000)
    if (mins < 1) return 'ahora'
    if (mins < 60) return `${mins}m`
    const hrs = Math.floor(mins / 60)
    if (hrs < 24) return `${hrs}h`
    return `${Math.floor(hrs / 24)}d`
  }

  return (
    <Layout>
      <div style={{ padding: '24px 0', maxWidth: '720px', margin: '0 auto', animation: 'fadeIn 0.5s ease' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '28px' }}>
          <div>
            <h1 style={{ fontFamily: 'var(--font-display)', fontWeight: '800', fontSize: '28px', color: 'white', marginBottom: '4px' }}>
              💬 Posts
            </h1>
            <p style={{ color: 'rgba(255,255,255,0.4)', fontSize: '13px', fontFamily: 'var(--font-body)' }}>
              Comparte dudas y conocimiento con la comunidad
            </p>
          </div>
          <button className="btn-primary" onClick={() => setShowForm(!showForm)} style={{ fontSize: '13px', padding: '10px 18px' }}>
            + Nueva pregunta
          </button>
        </div>

        {/* Create post */}
        {showForm && (
          <div style={{
            background: 'rgba(156,107,255,0.06)',
            border: '1px solid rgba(156,107,255,0.2)',
            borderRadius: '20px',
            padding: '24px',
            marginBottom: '24px',
            animation: 'fadeIn 0.3s ease'
          }}>
            <textarea
              className="input-field"
              placeholder="¿Cuál es tu pregunta? ¿Qué quieres compartir?"
              value={content}
              onChange={e => setContent(e.target.value)}
              rows={4}
              style={{ resize: 'none', marginBottom: '14px' }}
            />
            <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', marginBottom: '14px' }}>
              {TAGS.map(tag => (
                <button key={tag} onClick={() => setSelectedTag(tag)} style={{
                  padding: '5px 12px',
                  borderRadius: '20px',
                  border: selectedTag === tag ? '1px solid #9c6bff' : '1px solid rgba(255,255,255,0.1)',
                  background: selectedTag === tag ? 'rgba(156,107,255,0.2)' : 'transparent',
                  color: selectedTag === tag ? '#9c6bff' : 'rgba(255,255,255,0.4)',
                  cursor: 'pointer',
                  fontSize: '12px',
                  fontFamily: 'var(--font-body)',
                  transition: 'all 0.2s'
                }}>
                  {tag}
                </button>
              ))}
            </div>
            <div style={{ display: 'flex', gap: '10px' }}>
              <button className="btn-primary" onClick={createPost} disabled={loading} style={{ flex: 1 }}>
                {loading ? '⏳ Publicando...' : '📤 Publicar'}
              </button>
              <button className="btn-secondary" onClick={() => setShowForm(false)}>Cancelar</button>
            </div>
          </div>
        )}

        {/* Filter tags */}
        <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', marginBottom: '20px' }}>
          <button onClick={() => setFilterTag('')} style={{
            padding: '6px 14px',
            borderRadius: '20px',
            border: !filterTag ? '1px solid #9c6bff' : '1px solid rgba(255,255,255,0.1)',
            background: !filterTag ? 'rgba(156,107,255,0.2)' : 'transparent',
            color: !filterTag ? '#9c6bff' : 'rgba(255,255,255,0.4)',
            cursor: 'pointer',
            fontSize: '12px',
            fontFamily: 'var(--font-body)',
            transition: 'all 0.2s'
          }}>Todos</button>
          {TAGS.map(tag => (
            <button key={tag} onClick={() => setFilterTag(tag)} style={{
              padding: '6px 14px',
              borderRadius: '20px',
              border: filterTag === tag ? '1px solid #9c6bff' : '1px solid rgba(255,255,255,0.1)',
              background: filterTag === tag ? 'rgba(156,107,255,0.2)' : 'transparent',
              color: filterTag === tag ? '#9c6bff' : 'rgba(255,255,255,0.4)',
              cursor: 'pointer',
              fontSize: '12px',
              fontFamily: 'var(--font-body)',
              transition: 'all 0.2s'
            }}>{tag}</button>
          ))}
        </div>

        {/* Posts list */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          {filtered.length === 0 && (
            <div style={{ textAlign: 'center', padding: '60px 20px', color: 'rgba(255,255,255,0.3)' }}>
              <div style={{ fontSize: '48px', marginBottom: '12px' }}>💭</div>
              <p style={{ fontFamily: 'var(--font-body)' }}>No hay posts aún. ¡Sé el primero en publicar!</p>
            </div>
          )}
          {filtered.map(post => (
            <div key={post.id} style={{
              background: 'rgba(255,255,255,0.04)',
              border: '1px solid rgba(255,255,255,0.07)',
              borderRadius: '18px',
              padding: '20px',
              transition: 'all 0.2s ease'
            }}
            onMouseEnter={e => {
              (e.currentTarget as HTMLDivElement).style.borderColor = 'rgba(156,107,255,0.25)'
            }}
            onMouseLeave={e => {
              (e.currentTarget as HTMLDivElement).style.borderColor = 'rgba(255,255,255,0.07)'
            }}
            >
              {/* Author */}
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '14px' }}>
                <div style={{
                  width: '38px', height: '38px', borderRadius: '12px',
                  background: post.avatar_color || '#9c6bff',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: '18px'
                }}>{post.avatar_emoji || '📚'}</div>
                <div style={{ flex: 1 }}>
                  <p style={{ fontFamily: 'var(--font-display)', fontWeight: '600', fontSize: '14px', color: 'white' }}>
                    {post.username}
                  </p>
                  <p style={{ color: 'rgba(255,255,255,0.3)', fontSize: '11px', fontFamily: 'var(--font-body)' }}>
                    {timeAgo(post.created_at)}
                  </p>
                </div>
                {post.tags?.[0] && (
                  <span style={{
                    padding: '3px 10px',
                    borderRadius: '20px',
                    background: 'rgba(156,107,255,0.15)',
                    border: '1px solid rgba(156,107,255,0.25)',
                    color: '#9c6bff',
                    fontSize: '11px',
                    fontFamily: 'var(--font-body)'
                  }}>{post.tags[0]}</span>
                )}
              </div>

              {/* Content */}
              <p style={{
                color: 'rgba(255,255,255,0.8)',
                fontFamily: 'var(--font-body)',
                fontSize: '15px',
                lineHeight: '1.6',
                marginBottom: '16px'
              }}>{post.content}</p>

              {/* Actions */}
              <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
                <button onClick={() => likePost(post)} style={{
                  display: 'flex', alignItems: 'center', gap: '6px',
                  background: 'rgba(255,255,255,0.05)', border: '1px solid rgba(255,255,255,0.1)',
                  borderRadius: '10px', padding: '6px 12px', cursor: 'pointer',
                  color: 'rgba(255,255,255,0.6)', fontSize: '13px', fontFamily: 'var(--font-body)',
                  transition: 'all 0.2s'
                }}>
                  ❤️ {post.likes}
                </button>
                {post.user_id === userId && (
                  <button onClick={() => deletePost(post.id)} style={{
                    background: 'rgba(255,80,80,0.08)', border: '1px solid rgba(255,80,80,0.2)',
                    borderRadius: '10px', padding: '6px 12px', cursor: 'pointer',
                    color: 'rgba(255,100,100,0.7)', fontSize: '13px', fontFamily: 'var(--font-body)',
                    transition: 'all 0.2s'
                  }}>
                    🗑️ Eliminar
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </Layout>
  )
}
