import Layout from '@/components/Layout'
import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'

const features = [
  {
    icon: '💬',
    title: 'Posts',
    desc: 'Publica preguntas, comparte dudas y responde a otros estudiantes. Tu comunidad está aquí.',
    path: '/posts',
    color: '#9c6bff'
  },
  {
    icon: '🎓',
    title: 'Clubes',
    desc: 'Únete a chats grupales por materia, crea tu propio club de estudio y conecta en tiempo real.',
    path: '/clubs',
    color: '#7a47ff'
  },
  {
    icon: '📚',
    title: 'Biblioteca',
    desc: 'Sube y descarga material educativo: apuntes, PDFs, presentaciones. Todo organizado por tema.',
    path: '/library',
    color: '#dcd6f7'
  },
  {
    icon: '🌿',
    title: 'Zona Zen',
    desc: 'Tu espacio personal: diario de ánimo, tareas, calendario, Pomodoro y modo sin distracciones.',
    path: '/zen',
    color: '#00c2cc'
  },
  {
    icon: '✨',
    title: 'Perfil',
    desc: 'Personaliza tu avatar, agrega tu bio y muestra tu identidad como estudiante.',
    path: '/profile',
    color: '#b48fff'
  },
  {
    icon: '👻',
    title: 'Specter (IA)',
    desc: 'Nuestro asistente fantasma estará pronto disponible para ayudarte con cualquier duda.',
    path: '/',
    color: '#9c6bff',
    soon: true
  },
]

export default function HomePage() {
  const router = useRouter()
  const [username, setUsername] = useState('Estudiante')
  const [showTutorial, setShowTutorial] = useState(true)

  useEffect(() => {
    const load = async () => {
      const { data: { user } } = await supabase.auth.getUser()
      if (user) {
        const { data } = await supabase.from('profiles').select('username').eq('id', user.id).single()
        if (data) setUsername(data.username)
      }
    }
    load()
  }, [])

  return (
    <Layout>
      <div style={{ padding: '24px 0', animation: 'fadeIn 0.6s ease' }}>
        {/* Header */}
        <div style={{ marginBottom: '40px' }}>
          <p style={{ color: 'rgba(255,255,255,0.4)', fontSize: '13px', fontFamily: 'var(--font-body)', marginBottom: '8px' }}>
            {new Date().toLocaleDateString('es-MX', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
          </p>
          <h1 style={{
            fontFamily: 'var(--font-display)',
            fontWeight: '800',
            fontSize: '36px',
            background: 'linear-gradient(135deg, #9c6bff, #dcd6f7)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
            backgroundClip: 'text',
            marginBottom: '10px'
          }}>
            Hola, {username} 👋
          </h1>
          <p style={{ color: 'rgba(255,255,255,0.5)', fontFamily: 'var(--font-body)', fontSize: '15px' }}>
            Tu centro de operaciones para estudiar mejor y conectar con otros.
          </p>
        </div>

        {/* Tutorial toggle */}
        <div style={{ marginBottom: '32px' }}>
          <button
            onClick={() => setShowTutorial(!showTutorial)}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '10px',
              background: 'rgba(156,107,255,0.1)',
              border: '1px solid rgba(156,107,255,0.25)',
              borderRadius: '14px',
              padding: '14px 20px',
              cursor: 'pointer',
              width: '100%',
              justifyContent: 'space-between',
              transition: 'all 0.3s ease'
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <span style={{ fontSize: '20px' }}>📖</span>
              <span style={{
                fontFamily: 'var(--font-display)',
                fontWeight: '700',
                fontSize: '16px',
                color: '#dcd6f7'
              }}>Manual de uso — ¿Cómo funciona StudyBytes?</span>
            </div>
            <span style={{ color: 'rgba(255,255,255,0.4)', fontSize: '18px' }}>
              {showTutorial ? '▲' : '▼'}
            </span>
          </button>

          {showTutorial && (
            <div style={{
              background: 'rgba(255,255,255,0.03)',
              border: '1px solid rgba(255,255,255,0.07)',
              borderTop: 'none',
              borderRadius: '0 0 14px 14px',
              padding: '24px',
              animation: 'fadeIn 0.3s ease'
            }}>
              {/* Steps */}
              {[
                { num: '01', title: 'Crea tu perfil', desc: 'Ve a ✨ Perfil y personaliza tu avatar, agrega un emoji, color y tu bio.' },
                { num: '02', title: 'Explora los Posts', desc: 'En 💬 Posts puedes hacer preguntas públicas, dar likes y comentar respuestas.' },
                { num: '03', title: 'Únete a un Club', desc: 'En 🎓 Clubes encontrarás chats en tiempo real. Busca tu materia o crea uno.' },
                { num: '04', title: 'Comparte en Biblioteca', desc: 'Sube tus apuntes en 📚 Biblioteca para que todos puedan aprender contigo.' },
                { num: '05', title: 'Cuídate en Zona Zen', desc: 'En 🌿 Zona Zen lleva tu diario, gestiona tareas y usa el Pomodoro para estudiar.' },
                { num: '06', title: 'Specter IA (pronto)', desc: 'El 👻 flotante conectará con tu asistente de IA. ¡Muy pronto disponible!' },
              ].map((step, i) => (
                <div key={i} style={{
                  display: 'flex',
                  gap: '16px',
                  marginBottom: i < 5 ? '16px' : '0',
                  padding: '14px',
                  background: 'rgba(255,255,255,0.03)',
                  borderRadius: '12px',
                  border: '1px solid rgba(255,255,255,0.05)'
                }}>
                  <div style={{
                    flexShrink: 0,
                    width: '36px',
                    height: '36px',
                    borderRadius: '10px',
                    background: 'linear-gradient(135deg, #9c6bff, #7a47ff)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontFamily: 'var(--font-display)',
                    fontWeight: '700',
                    fontSize: '11px',
                    color: 'white'
                  }}>{step.num}</div>
                  <div>
                    <h3 style={{ fontFamily: 'var(--font-display)', fontWeight: '700', fontSize: '14px', color: '#dcd6f7', marginBottom: '4px' }}>
                      {step.title}
                    </h3>
                    <p style={{ color: 'rgba(255,255,255,0.45)', fontSize: '13px', fontFamily: 'var(--font-body)', lineHeight: '1.5' }}>
                      {step.desc}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Features grid */}
        <h2 style={{
          fontFamily: 'var(--font-display)',
          fontWeight: '700',
          fontSize: '20px',
          color: 'rgba(255,255,255,0.7)',
          marginBottom: '20px'
        }}>Explorar secciones</h2>

        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))',
          gap: '16px'
        }}>
          {features.map((f, i) => (
            <div
              key={i}
              onClick={() => !f.soon && router.push(f.path)}
              style={{
                background: 'rgba(255,255,255,0.04)',
                border: '1px solid rgba(255,255,255,0.08)',
                borderRadius: '20px',
                padding: '24px',
                cursor: f.soon ? 'default' : 'pointer',
                transition: 'all 0.3s ease',
                position: 'relative',
                overflow: 'hidden'
              }}
              onMouseEnter={e => {
                if (!f.soon) {
                  const el = e.currentTarget as HTMLDivElement
                  el.style.borderColor = `${f.color}50`
                  el.style.background = 'rgba(255,255,255,0.07)'
                  el.style.transform = 'translateY(-3px)'
                }
              }}
              onMouseLeave={e => {
                const el = e.currentTarget as HTMLDivElement
                el.style.borderColor = 'rgba(255,255,255,0.08)'
                el.style.background = 'rgba(255,255,255,0.04)'
                el.style.transform = 'translateY(0)'
              }}
            >
              {f.soon && (
                <div style={{
                  position: 'absolute',
                  top: '14px',
                  right: '14px',
                  background: 'rgba(156,107,255,0.2)',
                  border: '1px solid rgba(156,107,255,0.3)',
                  borderRadius: '8px',
                  padding: '3px 8px',
                  fontSize: '10px',
                  fontFamily: 'var(--font-display)',
                  color: '#9c6bff',
                  fontWeight: '600'
                }}>PRONTO</div>
              )}
              <div style={{ fontSize: '32px', marginBottom: '12px' }}>{f.icon}</div>
              <h3 style={{
                fontFamily: 'var(--font-display)',
                fontWeight: '700',
                fontSize: '18px',
                color: f.color,
                marginBottom: '8px'
              }}>{f.title}</h3>
              <p style={{
                color: 'rgba(255,255,255,0.45)',
                fontSize: '13px',
                fontFamily: 'var(--font-body)',
                lineHeight: '1.6'
              }}>{f.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </Layout>
  )
}
