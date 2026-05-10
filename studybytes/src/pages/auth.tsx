import { useState } from 'react'
import { supabase } from '@/lib/supabase'
import { useRouter } from 'next/router'
import toast from 'react-hot-toast'

export default function AuthPage() {
  const [mode, setMode] = useState<'login' | 'register'>('login')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [username, setUsername] = useState('')
  const [loading, setLoading] = useState(false)
  const router = useRouter()

  const handleLogin = async () => {
    if (!email || !password) return toast.error('Completa todos los campos')
    setLoading(true)
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) {
      toast.error('Credenciales incorrectas')
    } else {
      toast.success('¡Bienvenido de vuelta!')
      router.push('/')
    }
    setLoading(false)
  }

  const handleRegister = async () => {
    if (!email || !password || !username) return toast.error('Completa todos los campos')
    if (password.length < 6) return toast.error('La contraseña debe tener al menos 6 caracteres')
    setLoading(true)
    const { data, error } = await supabase.auth.signUp({ email, password })
    if (error) {
      toast.error(error.message)
    } else if (data.user) {
      await supabase.from('profiles').insert({
        id: data.user.id,
        username,
        avatar_color: '#9c6bff',
        avatar_emoji: '📚',
        bio: '¡Hola! Estoy aquí para aprender.'
      })
      toast.success('¡Cuenta creada! Ya puedes iniciar sesión.')
      setMode('login')
    }
    setLoading(false)
  }

  return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #04192d 0%, #0a1f35 40%, #04192d 100%)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '20px',
      position: 'relative',
      overflow: 'hidden'
    }}>
      {/* Background orbs */}
      <div style={{
        position: 'absolute', top: '10%', left: '5%',
        width: '300px', height: '300px',
        borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(156,107,255,0.15) 0%, transparent 70%)',
        filter: 'blur(40px)',
        animation: 'float 8s ease-in-out infinite'
      }} />
      <div style={{
        position: 'absolute', bottom: '10%', right: '5%',
        width: '250px', height: '250px',
        borderRadius: '50%',
        background: 'radial-gradient(circle, rgba(0,100,106,0.2) 0%, transparent 70%)',
        filter: 'blur(40px)',
        animation: 'float 10s ease-in-out infinite reverse'
      }} />

      {/* Card */}
      <div style={{
        width: '100%',
        maxWidth: '440px',
        background: 'rgba(255,255,255,0.04)',
        backdropFilter: 'blur(30px)',
        border: '1px solid rgba(255,255,255,0.1)',
        borderRadius: '28px',
        padding: '40px',
        position: 'relative',
        zIndex: 1
      }}>
        {/* Logo area */}
        <div style={{ textAlign: 'center', marginBottom: '36px' }}>
          <div style={{
            fontSize: '52px',
            marginBottom: '12px',
            animation: 'float 3s ease-in-out infinite',
            display: 'inline-block'
          }}>👻</div>
          <h1 style={{
            fontFamily: 'var(--font-display)',
            fontSize: '32px',
            fontWeight: '800',
            background: 'linear-gradient(135deg, #9c6bff, #dcd6f7)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
            backgroundClip: 'text',
            marginBottom: '6px'
          }}>StudyBytes</h1>
          <p style={{ color: 'rgba(255,255,255,0.4)', fontSize: '13px', fontFamily: 'var(--font-body)' }}>
            Tu compañero de estudio inteligente
          </p>
        </div>

        {/* Tabs */}
        <div style={{
          display: 'grid',
          gridTemplateColumns: '1fr 1fr',
          gap: '8px',
          marginBottom: '28px',
          background: 'rgba(255,255,255,0.05)',
          borderRadius: '14px',
          padding: '4px'
        }}>
          {(['login', 'register'] as const).map(m => (
            <button key={m} onClick={() => setMode(m)} style={{
              padding: '10px',
              borderRadius: '10px',
              border: 'none',
              cursor: 'pointer',
              fontFamily: 'var(--font-display)',
              fontWeight: '600',
              fontSize: '13px',
              transition: 'all 0.3s ease',
              background: mode === m ? 'linear-gradient(135deg, #9c6bff, #7a47ff)' : 'transparent',
              color: mode === m ? 'white' : 'rgba(255,255,255,0.4)',
            }}>
              {m === 'login' ? 'Iniciar sesión' : 'Registrarse'}
            </button>
          ))}
        </div>

        {/* Form */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          {mode === 'register' && (
            <div>
              <label style={{ color: 'rgba(255,255,255,0.5)', fontSize: '12px', fontFamily: 'var(--font-body)', marginBottom: '6px', display: 'block' }}>
                NOMBRE DE USUARIO
              </label>
              <input
                className="input-field"
                type="text"
                placeholder="¿Cómo te llaman?"
                value={username}
                onChange={e => setUsername(e.target.value)}
              />
            </div>
          )}
          <div>
            <label style={{ color: 'rgba(255,255,255,0.5)', fontSize: '12px', fontFamily: 'var(--font-body)', marginBottom: '6px', display: 'block' }}>
              CORREO ELECTRÓNICO
            </label>
            <input
              className="input-field"
              type="email"
              placeholder="tu@correo.com"
              value={email}
              onChange={e => setEmail(e.target.value)}
            />
          </div>
          <div>
            <label style={{ color: 'rgba(255,255,255,0.5)', fontSize: '12px', fontFamily: 'var(--font-body)', marginBottom: '6px', display: 'block' }}>
              CONTRASEÑA
            </label>
            <input
              className="input-field"
              type="password"
              placeholder="••••••••"
              value={password}
              onChange={e => setPassword(e.target.value)}
              onKeyDown={e => e.key === 'Enter' && (mode === 'login' ? handleLogin() : handleRegister())}
            />
          </div>

          <button
            className="btn-primary"
            onClick={mode === 'login' ? handleLogin : handleRegister}
            disabled={loading}
            style={{ marginTop: '8px', opacity: loading ? 0.7 : 1 }}
          >
            {loading ? '⏳ Procesando...' : mode === 'login' ? '✨ Iniciar sesión' : '🚀 Crear cuenta'}
          </button>
        </div>

        {/* Switch mode hint */}
        <p style={{ textAlign: 'center', marginTop: '20px', color: 'rgba(255,255,255,0.35)', fontSize: '13px', fontFamily: 'var(--font-body)' }}>
          {mode === 'login' ? '¿Eres nuevo? ' : '¿Ya tienes cuenta? '}
          <span
            onClick={() => setMode(mode === 'login' ? 'register' : 'login')}
            style={{ color: '#9c6bff', cursor: 'pointer', fontWeight: '500' }}
          >
            {mode === 'login' ? 'Regístrate aquí' : 'Inicia sesión'}
          </span>
        </p>
      </div>
    </div>
  )
}
