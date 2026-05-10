import Layout from '@/components/Layout'
import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'
import toast from 'react-hot-toast'

const AVATAR_EMOJIS = ['📚', '🎓', '🧠', '💡', '🔬', '🎨', '🎵', '⚡', '🌟', '🦋', '🐙', '🦊', '🐧', '🦄', '🌸', '🍀', '🎯', '🚀', '💎', '🔮']
const AVATAR_COLORS = ['#9c6bff', '#7a47ff', '#00646a', '#00c2cc', '#ff6b6b', '#ffa94d', '#69db7c', '#74c0fc', '#da77f2', '#ff8cc8']

export default function ProfilePage() {
  const [profile, setProfile] = useState<any>(null)
  const [username, setUsername] = useState('')
  const [bio, setBio] = useState('')
  const [avatarEmoji, setAvatarEmoji] = useState('📚')
  const [avatarColor, setAvatarColor] = useState('#9c6bff')
  const [saving, setSaving] = useState(false)
  const [email, setEmail] = useState('')
  const [stats, setStats] = useState({ posts: 0, clubs: 0, library: 0 })

  useEffect(() => {
    const load = async () => {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) return
      setEmail(user.email || '')
      const { data } = await supabase.from('profiles').select('*').eq('id', user.id).single()
      if (data) {
        setProfile(data)
        setUsername(data.username || '')
        setBio(data.bio || '')
        setAvatarEmoji(data.avatar_emoji || '📚')
        setAvatarColor(data.avatar_color || '#9c6bff')
      }

      // Stats
      const [postsRes, clubsRes, libRes] = await Promise.all([
        supabase.from('posts').select('id', { count: 'exact' }).eq('user_id', user.id),
        supabase.from('clubs').select('id', { count: 'exact' }).eq('creator_id', user.id),
        supabase.from('library_items').select('id', { count: 'exact' }).eq('user_id', user.id),
      ])
      setStats({ posts: postsRes.count || 0, clubs: clubsRes.count || 0, library: libRes.count || 0 })
    }
    load()
  }, [])

  const saveProfile = async () => {
    if (!username.trim()) return toast.error('El nombre de usuario es requerido')
    setSaving(true)
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return
    const { error } = await supabase.from('profiles').update({
      username: username.trim(),
      bio: bio.trim(),
      avatar_emoji: avatarEmoji,
      avatar_color: avatarColor
    }).eq('id', user.id)
    if (error) toast.error('Error al guardar')
    else toast.success('✨ Perfil actualizado')
    setSaving(false)
  }

  return (
    <Layout>
      <div style={{ padding: '24px 0', maxWidth: '700px', margin: '0 auto', animation: 'fadeIn 0.5s ease' }}>
        <h1 style={{ fontFamily: 'var(--font-display)', fontWeight: '800', fontSize: '28px', color: 'white', marginBottom: '32px' }}>
          ✨ Mi Perfil
        </h1>

        {/* Avatar preview */}
        <div style={{
          background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(255,255,255,0.08)',
          borderRadius: '24px', padding: '32px', marginBottom: '20px', textAlign: 'center'
        }}>
          <div style={{
            width: '100px', height: '100px', borderRadius: '28px',
            background: avatarColor, display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: '48px', margin: '0 auto 16px',
            boxShadow: `0 12px 40px ${avatarColor}60`
          }}>{avatarEmoji}</div>
          <h2 style={{ fontFamily: 'var(--font-display)', fontWeight: '700', fontSize: '22px', color: 'white', marginBottom: '4px' }}>
            {username || 'Tu nombre'}
          </h2>
          <p style={{ color: 'rgba(255,255,255,0.4)', fontSize: '13px', fontFamily: 'var(--font-body)', marginBottom: '4px' }}>
            {email}
          </p>
          <p style={{ color: 'rgba(255,255,255,0.35)', fontSize: '13px', fontFamily: 'var(--font-body)', fontStyle: 'italic' }}>
            {bio || 'Sin bio todavía'}
          </p>

          {/* Stats */}
          <div style={{ display: 'flex', gap: '20px', justifyContent: 'center', marginTop: '20px' }}>
            {[
              { label: 'Posts', value: stats.posts, icon: '💬' },
              { label: 'Clubes', value: stats.clubs, icon: '🎓' },
              { label: 'Archivos', value: stats.library, icon: '📚' },
            ].map(s => (
              <div key={s.label} style={{
                textAlign: 'center', padding: '12px 20px',
                background: 'rgba(156,107,255,0.08)', border: '1px solid rgba(156,107,255,0.15)',
                borderRadius: '14px'
              }}>
                <p style={{ fontSize: '20px', marginBottom: '4px' }}>{s.icon}</p>
                <p style={{ fontFamily: 'var(--font-display)', fontWeight: '700', fontSize: '20px', color: '#9c6bff' }}>{s.value}</p>
                <p style={{ color: 'rgba(255,255,255,0.3)', fontSize: '11px', fontFamily: 'var(--font-body)' }}>{s.label}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Edit section */}
        <div style={{ background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(255,255,255,0.08)', borderRadius: '24px', padding: '28px' }}>
          <h3 style={{ fontFamily: 'var(--font-display)', fontWeight: '700', fontSize: '16px', color: 'rgba(255,255,255,0.7)', marginBottom: '20px' }}>
            Editar perfil
          </h3>

          {/* Username */}
          <div style={{ marginBottom: '18px' }}>
            <label style={{ color: 'rgba(255,255,255,0.4)', fontSize: '12px', fontFamily: 'var(--font-body)', marginBottom: '8px', display: 'block' }}>
              NOMBRE DE USUARIO
            </label>
            <input className="input-field" value={username} onChange={e => setUsername(e.target.value)} placeholder="Tu nombre de usuario" />
          </div>

          {/* Bio */}
          <div style={{ marginBottom: '24px' }}>
            <label style={{ color: 'rgba(255,255,255,0.4)', fontSize: '12px', fontFamily: 'var(--font-body)', marginBottom: '8px', display: 'block' }}>
              BIO
            </label>
            <textarea className="input-field" value={bio} onChange={e => setBio(e.target.value)}
              placeholder="Cuéntanos un poco sobre ti..." rows={3} style={{ resize: 'none' }} />
          </div>

          {/* Avatar emoji */}
          <div style={{ marginBottom: '20px' }}>
            <label style={{ color: 'rgba(255,255,255,0.4)', fontSize: '12px', fontFamily: 'var(--font-body)', marginBottom: '12px', display: 'block' }}>
              EMOJI DE AVATAR
            </label>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
              {AVATAR_EMOJIS.map(emoji => (
                <button key={emoji} onClick={() => setAvatarEmoji(emoji)} style={{
                  width: '44px', height: '44px', borderRadius: '12px', border: avatarEmoji === emoji ? '2px solid #9c6bff' : '2px solid transparent',
                  background: avatarEmoji === emoji ? 'rgba(156,107,255,0.2)' : 'rgba(255,255,255,0.05)',
                  cursor: 'pointer', fontSize: '22px', transition: 'all 0.2s',
                  transform: avatarEmoji === emoji ? 'scale(1.1)' : 'scale(1)'
                }}>{emoji}</button>
              ))}
            </div>
          </div>

          {/* Avatar color */}
          <div style={{ marginBottom: '28px' }}>
            <label style={{ color: 'rgba(255,255,255,0.4)', fontSize: '12px', fontFamily: 'var(--font-body)', marginBottom: '12px', display: 'block' }}>
              COLOR DE AVATAR
            </label>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '10px' }}>
              {AVATAR_COLORS.map(color => (
                <button key={color} onClick={() => setAvatarColor(color)} style={{
                  width: '36px', height: '36px', borderRadius: '10px',
                  background: color,
                  border: avatarColor === color ? '3px solid white' : '3px solid transparent',
                  cursor: 'pointer', transition: 'all 0.2s',
                  transform: avatarColor === color ? 'scale(1.2)' : 'scale(1)',
                  boxShadow: avatarColor === color ? `0 4px 16px ${color}80` : 'none'
                }} />
              ))}
            </div>
          </div>

          <button className="btn-primary" onClick={saveProfile} disabled={saving}>
            {saving ? '⏳ Guardando...' : '💾 Guardar cambios'}
          </button>
        </div>
      </div>
    </Layout>
  )
}
