import Layout from '@/components/Layout'
import { useState, useEffect, useRef } from 'react'
import { supabase } from '@/lib/supabase'
import toast from 'react-hot-toast'

type Club = { id: string; name: string; description: string; creator_id: string; members_count: number; created_at: string }
type Message = { id: string; content: string; created_at: string; username: string; avatar_emoji: string; user_id: string }

export default function ClubsPage() {
  const [clubs, setClubs] = useState<Club[]>([])
  const [activeClub, setActiveClub] = useState<Club | null>(null)
  const [messages, setMessages] = useState<Message[]>([])
  const [msgText, setMsgText] = useState('')
  const [showCreate, setShowCreate] = useState(false)
  const [newClubName, setNewClubName] = useState('')
  const [newClubDesc, setNewClubDesc] = useState('')
  const [userId, setUserId] = useState('')
  const [profile, setProfile] = useState<any>(null)
  const messagesEnd = useRef<HTMLDivElement>(null)

  useEffect(() => {
    loadClubs()
    const init = async () => {
      const { data: { user } } = await supabase.auth.getUser()
      if (user) {
        setUserId(user.id)
        const { data } = await supabase.from('profiles').select('*').eq('id', user.id).single()
        setProfile(data)
      }
    }
    init()
  }, [])

  useEffect(() => {
    if (!activeClub) return
    loadMessages(activeClub.id)
    const sub = supabase
      .channel(`club_${activeClub.id}`)
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'club_messages', filter: `club_id=eq.${activeClub.id}` }, payload => {
        setMessages(prev => [...prev, payload.new as Message])
      })
      .subscribe()
    return () => { sub.unsubscribe() }
  }, [activeClub])

  useEffect(() => {
    messagesEnd.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  const loadClubs = async () => {
    const { data } = await supabase.from('clubs').select('*').order('created_at', { ascending: false })
    if (data) setClubs(data)
  }

  const loadMessages = async (clubId: string) => {
    const { data } = await supabase
      .from('club_messages').select('*').eq('club_id', clubId).order('created_at', { ascending: true }).limit(100)
    if (data) setMessages(data)
  }

  const createClub = async () => {
    if (!newClubName.trim()) return toast.error('Escribe el nombre del club')
    const { error } = await supabase.from('clubs').insert({
      name: newClubName.trim(),
      description: newClubDesc.trim() || 'Un espacio para estudiar juntos',
      creator_id: userId,
      members_count: 1
    })
    if (error) toast.error('Error al crear club')
    else { toast.success('¡Club creado!'); setShowCreate(false); setNewClubName(''); setNewClubDesc(''); loadClubs() }
  }

  const sendMessage = async () => {
    if (!msgText.trim() || !activeClub) return
    await supabase.from('club_messages').insert({
      club_id: activeClub.id,
      user_id: userId,
      content: msgText.trim(),
      username: profile?.username || 'Anon',
      avatar_emoji: profile?.avatar_emoji || '📚'
    })
    setMsgText('')
  }

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
      <div style={{ padding: '24px 0', animation: 'fadeIn 0.5s ease' }}>
        <div style={{ display: 'flex', gap: '24px', height: 'calc(100vh - 140px)' }}>
          {/* Sidebar */}
          <div style={{ width: '300px', flexShrink: 0, display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <h1 style={{ fontFamily: 'var(--font-display)', fontWeight: '800', fontSize: '24px', color: 'white' }}>
                🎓 Clubes
              </h1>
              <button className="btn-primary" onClick={() => setShowCreate(!showCreate)} style={{ fontSize: '12px', padding: '8px 14px' }}>
                + Crear
              </button>
            </div>

            {showCreate && (
              <div style={{
                background: 'rgba(156,107,255,0.08)', border: '1px solid rgba(156,107,255,0.2)',
                borderRadius: '16px', padding: '16px', animation: 'fadeIn 0.3s ease'
              }}>
                <input className="input-field" placeholder="Nombre del club" value={newClubName}
                  onChange={e => setNewClubName(e.target.value)} style={{ marginBottom: '10px' }} />
                <input className="input-field" placeholder="Descripción (opcional)" value={newClubDesc}
                  onChange={e => setNewClubDesc(e.target.value)} style={{ marginBottom: '10px' }} />
                <div style={{ display: 'flex', gap: '8px' }}>
                  <button className="btn-primary" onClick={createClub} style={{ flex: 1, fontSize: '13px', padding: '10px' }}>Crear</button>
                  <button className="btn-secondary" onClick={() => setShowCreate(false)} style={{ fontSize: '13px', padding: '10px' }}>✕</button>
                </div>
              </div>
            )}

            <div style={{ overflowY: 'auto', flex: 1, display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {clubs.map(club => (
                <div key={club.id} onClick={() => setActiveClub(club)} style={{
                  padding: '14px 16px',
                  borderRadius: '14px',
                  cursor: 'pointer',
                  background: activeClub?.id === club.id ? 'rgba(156,107,255,0.15)' : 'rgba(255,255,255,0.04)',
                  border: activeClub?.id === club.id ? '1px solid rgba(156,107,255,0.35)' : '1px solid rgba(255,255,255,0.07)',
                  transition: 'all 0.2s ease'
                }}>
                  <p style={{
                    fontFamily: 'var(--font-display)',
                    fontWeight: '600',
                    fontSize: '14px',
                    color: activeClub?.id === club.id ? '#9c6bff' : 'white',
                    marginBottom: '4px'
                  }}># {club.name}</p>
                  <p style={{ color: 'rgba(255,255,255,0.35)', fontSize: '11px', fontFamily: 'var(--font-body)', lineHeight: '1.4' }}>
                    {club.description}
                  </p>
                </div>
              ))}
              {clubs.length === 0 && (
                <p style={{ color: 'rgba(255,255,255,0.25)', fontSize: '13px', fontFamily: 'var(--font-body)', textAlign: 'center', marginTop: '20px' }}>
                  No hay clubes aún. ¡Crea el primero!
                </p>
              )}
            </div>
          </div>

          {/* Chat area */}
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: 'rgba(255,255,255,0.03)', borderRadius: '24px', border: '1px solid rgba(255,255,255,0.07)', overflow: 'hidden' }}>
            {!activeClub ? (
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: '12px' }}>
                <span style={{ fontSize: '52px' }}>🎓</span>
                <p style={{ color: 'rgba(255,255,255,0.3)', fontFamily: 'var(--font-body)', fontSize: '15px' }}>
                  Selecciona un club para chatear
                </p>
              </div>
            ) : (
              <>
                {/* Club header */}
                <div style={{ padding: '16px 24px', borderBottom: '1px solid rgba(255,255,255,0.07)', display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <div style={{
                    width: '40px', height: '40px', borderRadius: '12px',
                    background: 'linear-gradient(135deg, #9c6bff, #7a47ff)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '20px'
                  }}>🎓</div>
                  <div>
                    <p style={{ fontFamily: 'var(--font-display)', fontWeight: '700', fontSize: '16px', color: 'white' }}>
                      #{activeClub.name}
                    </p>
                    <p style={{ color: 'rgba(255,255,255,0.35)', fontSize: '12px', fontFamily: 'var(--font-body)' }}>
                      {activeClub.description}
                    </p>
                  </div>
                </div>

                {/* Messages */}
                <div style={{ flex: 1, overflowY: 'auto', padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
                  {messages.length === 0 && (
                    <div style={{ textAlign: 'center', marginTop: '40px', color: 'rgba(255,255,255,0.2)' }}>
                      <p style={{ fontFamily: 'var(--font-body)', fontSize: '14px' }}>¡Sé el primero en escribir!</p>
                    </div>
                  )}
                  {messages.map((msg, i) => {
                    const isMe = msg.user_id === userId
                    return (
                      <div key={msg.id} style={{
                        display: 'flex',
                        flexDirection: isMe ? 'row-reverse' : 'row',
                        gap: '10px',
                        alignItems: 'flex-end'
                      }}>
                        <div style={{
                          width: '32px', height: '32px', borderRadius: '10px',
                          background: isMe ? 'linear-gradient(135deg, #9c6bff, #7a47ff)' : 'rgba(255,255,255,0.1)',
                          display: 'flex', alignItems: 'center', justifyContent: 'center',
                          fontSize: '14px', flexShrink: 0
                        }}>{msg.avatar_emoji}</div>
                        <div style={{ maxWidth: '65%' }}>
                          {!isMe && (
                            <p style={{ color: 'rgba(255,255,255,0.35)', fontSize: '11px', fontFamily: 'var(--font-body)', marginBottom: '4px' }}>
                              {msg.username} · {timeAgo(msg.created_at)}
                            </p>
                          )}
                          <div style={{
                            background: isMe ? 'linear-gradient(135deg, rgba(156,107,255,0.3), rgba(122,71,255,0.25))' : 'rgba(255,255,255,0.07)',
                            border: isMe ? '1px solid rgba(156,107,255,0.3)' : '1px solid rgba(255,255,255,0.08)',
                            borderRadius: isMe ? '16px 16px 4px 16px' : '16px 16px 16px 4px',
                            padding: '10px 14px'
                          }}>
                            <p style={{ color: 'rgba(255,255,255,0.85)', fontSize: '14px', fontFamily: 'var(--font-body)', lineHeight: '1.5' }}>
                              {msg.content}
                            </p>
                          </div>
                          {isMe && (
                            <p style={{ color: 'rgba(255,255,255,0.25)', fontSize: '11px', fontFamily: 'var(--font-body)', marginTop: '4px', textAlign: 'right' }}>
                              {timeAgo(msg.created_at)}
                            </p>
                          )}
                        </div>
                      </div>
                    )
                  })}
                  <div ref={messagesEnd} />
                </div>

                {/* Input */}
                <div style={{ padding: '16px 24px', borderTop: '1px solid rgba(255,255,255,0.07)', display: 'flex', gap: '10px' }}>
                  <input
                    className="input-field"
                    placeholder={`Mensaje en #${activeClub.name}...`}
                    value={msgText}
                    onChange={e => setMsgText(e.target.value)}
                    onKeyDown={e => e.key === 'Enter' && sendMessage()}
                    style={{ flex: 1 }}
                  />
                  <button className="btn-primary" onClick={sendMessage} style={{ padding: '12px 18px', flexShrink: 0 }}>
                    ➤
                  </button>
                </div>
              </>
            )}
          </div>
        </div>
      </div>
    </Layout>
  )
}
