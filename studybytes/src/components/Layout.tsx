import { useRouter } from 'next/router'
import { supabase } from '@/lib/supabase'
import GhostBubble from './GhostBubble'
import toast from 'react-hot-toast'

const navItems = [
  { path: '/', icon: '🏠', label: 'Inicio' },
  { path: '/posts', icon: '💬', label: 'Posts' },
  { path: '/clubs', icon: '🎓', label: 'Clubes' },
  { path: '/library', icon: '📚', label: 'Biblioteca' },
  { path: '/zen', icon: '🌿', label: 'Zona Zen' },
  { path: '/profile', icon: '✨', label: 'Perfil' },
]

export default function Layout({ children }: { children: React.ReactNode }) {
  const router = useRouter()

  const handleLogout = async () => {
    await supabase.auth.signOut()
    toast.success('¡Hasta pronto!')
    router.push('/auth')
  }

  return (
    <div style={{ minHeight: '100vh', background: '#04192d', display: 'flex', flexDirection: 'column' }}>
      {/* Top nav */}
      <nav style={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        zIndex: 100,
        background: 'rgba(4,25,45,0.85)',
        backdropFilter: 'blur(20px)',
        borderBottom: '1px solid rgba(255,255,255,0.07)',
        padding: '0 24px',
        height: '64px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <span style={{ fontSize: '22px' }}>👻</span>
          <span style={{
            fontFamily: 'var(--font-display)',
            fontWeight: '800',
            fontSize: '18px',
            background: 'linear-gradient(135deg, #9c6bff, #dcd6f7)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
            backgroundClip: 'text'
          }}>StudyBytes</span>
        </div>

        {/* Nav items */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
          {navItems.map(item => {
            const isActive = router.pathname === item.path
            return (
              <button
                key={item.path}
                onClick={() => router.push(item.path)}
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  gap: '2px',
                  padding: '6px 10px',
                  borderRadius: '10px',
                  border: 'none',
                  cursor: 'pointer',
                  background: isActive ? 'rgba(156,107,255,0.15)' : 'transparent',
                  transition: 'all 0.2s ease',
                  position: 'relative'
                }}
              >
                <span style={{ fontSize: '16px' }}>{item.icon}</span>
                <span style={{
                  fontSize: '10px',
                  fontFamily: 'var(--font-body)',
                  color: isActive ? '#9c6bff' : 'rgba(255,255,255,0.35)',
                  fontWeight: isActive ? '500' : '400'
                }}>{item.label}</span>
                {isActive && (
                  <div style={{
                    position: 'absolute',
                    bottom: '-1px',
                    left: '50%',
                    transform: 'translateX(-50%)',
                    width: '4px',
                    height: '4px',
                    borderRadius: '50%',
                    background: '#9c6bff'
                  }} />
                )}
              </button>
            )
          })}
        </div>

        <button
          onClick={handleLogout}
          style={{
            background: 'rgba(255,255,255,0.05)',
            border: '1px solid rgba(255,255,255,0.1)',
            borderRadius: '10px',
            padding: '6px 14px',
            color: 'rgba(255,255,255,0.4)',
            cursor: 'pointer',
            fontSize: '12px',
            fontFamily: 'var(--font-body)',
            transition: 'all 0.2s ease'
          }}
        >
          Salir
        </button>
      </nav>

      {/* Content */}
      <main style={{ marginTop: '64px', flex: 1, padding: '24px', maxWidth: '1200px', margin: '64px auto 0', width: '100%' }}>
        {children}
      </main>

      <GhostBubble />
    </div>
  )
}
