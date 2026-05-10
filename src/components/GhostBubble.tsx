import { useState } from 'react'

export default function GhostBubble() {
  const [open, setOpen] = useState(false)

  return (
    <div style={{
      position: 'fixed',
      bottom: '24px',
      right: '24px',
      zIndex: 999,
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'flex-end',
      gap: '12px'
    }}>
      {open && (
        <div style={{
          background: 'linear-gradient(135deg, #0a2d4a, #04192d)',
          border: '1px solid rgba(156,107,255,0.35)',
          borderRadius: '20px',
          padding: '20px',
          width: '240px',
          boxShadow: '0 20px 60px rgba(0,0,0,0.5), 0 0 30px rgba(156,107,255,0.15)',
          animation: 'fadeIn 0.3s ease'
        }}>
          <div style={{ fontSize: '28px', marginBottom: '8px' }}>👻</div>
          <p style={{
            fontFamily: 'var(--font-display)',
            fontWeight: '700',
            fontSize: '14px',
            color: '#dcd6f7',
            marginBottom: '6px'
          }}>¡Hola, soy Specter!</p>
          <p style={{
            color: 'rgba(255,255,255,0.5)',
            fontSize: '12px',
            fontFamily: 'var(--font-body)',
            lineHeight: '1.5'
          }}>
            Pronto seré tu asistente IA personalizado. ¡Estoy aprendiendo para ayudarte mejor! 🌟
          </p>
          <div style={{
            marginTop: '14px',
            padding: '8px 12px',
            background: 'rgba(156,107,255,0.1)',
            border: '1px solid rgba(156,107,255,0.2)',
            borderRadius: '10px',
            fontSize: '11px',
            color: 'rgba(255,255,255,0.4)',
            fontFamily: 'var(--font-body)'
          }}>
            🔮 IA próximamente disponible
          </div>
        </div>
      )}

      {/* Ghost button */}
      <button
        onClick={() => setOpen(!open)}
        style={{
          width: '60px',
          height: '60px',
          borderRadius: '50%',
          border: 'none',
          cursor: 'pointer',
          background: 'linear-gradient(135deg, #9c6bff, #7a47ff)',
          boxShadow: open
            ? '0 0 30px rgba(156,107,255,0.7), 0 0 60px rgba(156,107,255,0.3)'
            : '0 0 20px rgba(156,107,255,0.4)',
          fontSize: '26px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          transition: 'all 0.3s ease',
          animation: 'float 4s ease-in-out infinite',
          transform: open ? 'scale(1.1)' : 'scale(1)',
          position: 'relative'
        }}
      >
        👻
        {/* Pulse ring */}
        {!open && (
          <div style={{
            position: 'absolute',
            inset: 0,
            borderRadius: '50%',
            border: '2px solid rgba(156,107,255,0.5)',
            animation: 'pulse-ring 2s ease-out infinite'
          }} />
        )}
      </button>
    </div>
  )
}
