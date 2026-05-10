import type { AppProps } from 'next/app'
import { useEffect, useState } from 'react'
import { useRouter } from 'next/router'
import { supabase } from '@/lib/supabase'
import { Toaster } from 'react-hot-toast'
import '@/styles/globals.css'
import 'react-calendar/dist/Calendar.css'

export default function App({ Component, pageProps }: AppProps) {
  const router = useRouter()
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (!session && router.pathname !== '/auth') {
        router.push('/auth')
      } else if (session && router.pathname === '/auth') {
        router.push('/')
      }
      setLoading(false)
    })

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      if (!session && router.pathname !== '/auth') {
        router.push('/auth')
      }
    })

    return () => subscription.unsubscribe()
  }, [router.pathname])

  if (loading) return (
    <div style={{ 
      display: 'flex', 
      alignItems: 'center', 
      justifyContent: 'center', 
      height: '100vh', 
      background: '#04192d',
      flexDirection: 'column',
      gap: '20px'
    }}>
      <div style={{ fontSize: '48px', animation: 'float 2s ease-in-out infinite' }}>👻</div>
      <div style={{ 
        color: 'rgba(255,255,255,0.5)', 
        fontFamily: 'var(--font-body)',
        fontSize: '14px'
      }}>Cargando StudyBytes...</div>
    </div>
  )

  return (
    <>
      <Toaster position="top-right" toastOptions={{
        style: {
          background: '#0a2d4a',
          color: 'white',
          border: '1px solid rgba(156,107,255,0.3)',
          borderRadius: '12px',
          fontFamily: 'var(--font-body)',
          fontSize: '14px'
        }
      }} />
      <Component {...pageProps} />
    </>
  )
}
