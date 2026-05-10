import Layout from '@/components/Layout'
import { useState, useEffect, useRef } from 'react'
import { supabase } from '@/lib/supabase'
import toast from 'react-hot-toast'
import dynamic from 'next/dynamic'

const Calendar = dynamic(() => import('react-calendar'), { ssr: false })

const MOODS = [
  { emoji: '😄', label: 'Excelente', score: 5 },
  { emoji: '😊', label: 'Bien', score: 4 },
  { emoji: '😐', label: 'Regular', score: 3 },
  { emoji: '😔', label: 'Bajo', score: 2 },
  { emoji: '😢', label: 'Difícil', score: 1 },
]

const PRIORITIES = ['Alta', 'Media', 'Baja']

type Task = { id: string; title: string; due_date: string; completed: boolean; priority: string; created_at: string }
type ZenEntry = { id: string; mood: string; mood_score: number; journal_text: string; date: string }

type TabType = 'journal' | 'tasks' | 'pomodoro' | 'focus'

export default function ZenPage() {
  const [activeTab, setActiveTab] = useState<TabType>('journal')
  const [tasks, setTasks] = useState<Task[]>([])
  const [entries, setEntries] = useState<ZenEntry[]>([])
  const [selectedDate, setSelectedDate] = useState(new Date())
  const [mood, setMood] = useState('')
  const [moodScore, setMoodScore] = useState(0)
  const [journalText, setJournalText] = useState('')
  const [savingEntry, setSavingEntry] = useState(false)
  const [newTask, setNewTask] = useState('')
  const [taskDate, setTaskDate] = useState('')
  const [taskPriority, setTaskPriority] = useState('Media')
  const [userId, setUserId] = useState('')

  // Pomodoro
  const [pomMode, setPomMode] = useState<'work' | 'break'>('work')
  const [pomSeconds, setPomSeconds] = useState(25 * 60)
  const [pomRunning, setPomRunning] = useState(false)
  const [pomCycles, setPomCycles] = useState(0)
  const pomRef = useRef<ReturnType<typeof setInterval> | null>(null)

  // Focus mode
  const [focusMode, setFocusMode] = useState(false)
  const [focusText, setFocusText] = useState('')

  useEffect(() => {
    supabase.auth.getUser().then(({ data: { user } }) => {
      if (user) { setUserId(user.id); loadTasks(user.id); loadEntries(user.id) }
    })
    return () => { if (pomRef.current) clearInterval(pomRef.current) }
  }, [])

  useEffect(() => {
    if (pomRunning) {
      pomRef.current = setInterval(() => {
        setPomSeconds(s => {
          if (s <= 1) {
            clearInterval(pomRef.current!)
            setPomRunning(false)
            if (pomMode === 'work') {
              setPomCycles(c => c + 1)
              setPomMode('break')
              setPomSeconds(5 * 60)
              toast.success('¡Pomodoro completado! Toma un descanso 🌿')
            } else {
              setPomMode('work')
              setPomSeconds(25 * 60)
              toast.success('¡Descanso terminado! A estudiar 📚')
            }
            return 0
          }
          return s - 1
        })
      }, 1000)
    } else {
      if (pomRef.current) clearInterval(pomRef.current)
    }
    return () => { if (pomRef.current) clearInterval(pomRef.current) }
  }, [pomRunning, pomMode])

  const loadTasks = async (uid: string) => {
    const { data } = await supabase.from('tasks').select('*').eq('user_id', uid).order('due_date', { ascending: true })
    if (data) setTasks(data)
  }

  const loadEntries = async (uid: string) => {
    const { data } = await supabase.from('zen_entries').select('*').eq('user_id', uid).order('date', { ascending: false })
    if (data) setEntries(data)
  }

  const saveEntry = async () => {
    if (!mood) return toast.error('Selecciona tu estado de ánimo')
    setSavingEntry(true)
    const today = selectedDate.toISOString().split('T')[0]
    await supabase.from('zen_entries').upsert({
      user_id: userId, mood, mood_score: moodScore, journal_text: journalText, date: today
    }, { onConflict: 'user_id,date' })
    toast.success('✨ Entrada guardada')
    setMood(''); setMoodScore(0); setJournalText('')
    loadEntries(userId)
    setSavingEntry(false)
  }

  const addTask = async () => {
    if (!newTask.trim()) return toast.error('Escribe el nombre de la tarea')
    await supabase.from('tasks').insert({
      user_id: userId, title: newTask.trim(), due_date: taskDate || null, completed: false, priority: taskPriority
    })
    setNewTask(''); setTaskDate('')
    loadTasks(userId)
  }

  const toggleTask = async (task: Task) => {
    await supabase.from('tasks').update({ completed: !task.completed }).eq('id', task.id)
    loadTasks(userId)
  }

  const deleteTask = async (id: string) => {
    await supabase.from('tasks').delete().eq('id', id)
    loadTasks(userId)
  }

  const resetPom = () => { setPomRunning(false); setPomSeconds(pomMode === 'work' ? 25 * 60 : 5 * 60) }

  const formatTime = (s: number) => `${String(Math.floor(s / 60)).padStart(2, '0')}:${String(s % 60).padStart(2, '0')}`

  const getPriorityColor = (p: string) => p === 'Alta' ? '#ff6b6b' : p === 'Media' ? '#ffa94d' : '#69db7c'

  const pomProgress = pomMode === 'work' ? (25 * 60 - pomSeconds) / (25 * 60) : (5 * 60 - pomSeconds) / (5 * 60)
  const circumference = 2 * Math.PI * 90

  const tabs: { id: TabType; icon: string; label: string }[] = [
    { id: 'journal', icon: '📓', label: 'Diario' },
    { id: 'tasks', icon: '✅', label: 'Tareas' },
    { id: 'pomodoro', icon: '🍅', label: 'Pomodoro' },
    { id: 'focus', icon: '🎯', label: 'Sin Distracciones' },
  ]

  if (focusMode) {
    return (
      <div className="distraction-free">
        <div style={{ width: '100%', maxWidth: '680px', padding: '40px 20px' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '32px' }}>
            <h2 style={{ fontFamily: 'var(--font-display)', fontWeight: '700', fontSize: '22px', color: 'rgba(255,255,255,0.8)' }}>
              🎯 Modo Enfoque
            </h2>
            <button onClick={() => setFocusMode(false)} style={{
              background: 'rgba(255,255,255,0.08)', border: '1px solid rgba(255,255,255,0.12)',
              borderRadius: '10px', padding: '8px 16px', color: 'rgba(255,255,255,0.5)',
              cursor: 'pointer', fontSize: '13px', fontFamily: 'var(--font-body)'
            }}>Salir del modo enfoque</button>
          </div>
          <textarea
            value={focusText}
            onChange={e => setFocusText(e.target.value)}
            placeholder="Escribe aquí sin distracciones... Este es tu espacio."
            style={{
              width: '100%', height: '60vh', background: 'transparent',
              border: 'none', outline: 'none', resize: 'none',
              fontFamily: 'var(--font-body)', fontSize: '18px', lineHeight: '1.9',
              color: 'rgba(255,255,255,0.75)', caretColor: '#9c6bff'
            }}
          />
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '20px' }}>
            <p style={{ color: 'rgba(255,255,255,0.2)', fontSize: '13px', fontFamily: 'var(--font-body)' }}>
              {focusText.split(/\s+/).filter(Boolean).length} palabras
            </p>
            <p style={{ color: 'rgba(255,255,255,0.2)', fontSize: '13px', fontFamily: 'var(--font-body)' }}>
              {focusText.length} caracteres
            </p>
          </div>
        </div>
      </div>
    )
  }

  return (
    <Layout>
      <div style={{ padding: '24px 0', animation: 'fadeIn 0.5s ease' }}>
        {/* Header */}
        <div style={{ marginBottom: '32px' }}>
          <h1 style={{ fontFamily: 'var(--font-display)', fontWeight: '800', fontSize: '28px', marginBottom: '4px',
            background: 'linear-gradient(135deg, #00c2cc, #007f87)', WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent', backgroundClip: 'text' }}>
            🌿 Zona Zen
          </h1>
          <p style={{ color: 'rgba(255,255,255,0.4)', fontSize: '13px', fontFamily: 'var(--font-body)' }}>
            Tu espacio personal para cuidarte y organizarte
          </p>
        </div>

        {/* Tabs */}
        <div style={{ display: 'flex', gap: '8px', marginBottom: '28px', flexWrap: 'wrap' }}>
          {tabs.map(tab => (
            <button key={tab.id} onClick={() => setActiveTab(tab.id)} style={{
              padding: '10px 18px', borderRadius: '12px', border: 'none', cursor: 'pointer',
              fontFamily: 'var(--font-display)', fontWeight: '600', fontSize: '13px',
              transition: 'all 0.2s ease',
              background: activeTab === tab.id
                ? 'linear-gradient(135deg, #00646a, #007f87)'
                : 'rgba(255,255,255,0.05)',
              color: activeTab === tab.id ? 'white' : 'rgba(255,255,255,0.45)'
            }}>
              {tab.icon} {tab.label}
            </button>
          ))}
        </div>

        {/* JOURNAL TAB */}
        {activeTab === 'journal' && (
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 340px', gap: '24px' }}>
            <div>
              {/* New entry */}
              <div style={{
                background: 'rgba(0,100,106,0.12)', border: '1px solid rgba(0,100,106,0.25)',
                borderRadius: '24px', padding: '28px', marginBottom: '20px'
              }}>
                <h3 style={{ fontFamily: 'var(--font-display)', fontWeight: '700', fontSize: '18px', color: '#00c2cc', marginBottom: '20px' }}>
                  ¿Cómo te sientes hoy?
                </h3>
                <div style={{ display: 'flex', gap: '12px', marginBottom: '20px' }}>
                  {MOODS.map(m => (
                    <button key={m.label} onClick={() => { setMood(m.emoji); setMoodScore(m.score) }} style={{
                      padding: '12px', borderRadius: '14px', border: mood === m.emoji ? '2px solid #00c2cc' : '2px solid transparent',
                      background: mood === m.emoji ? 'rgba(0,194,204,0.15)' : 'rgba(255,255,255,0.05)',
                      cursor: 'pointer', fontSize: '26px', display: 'flex', flexDirection: 'column',
                      alignItems: 'center', gap: '4px', transition: 'all 0.2s',
                      transform: mood === m.emoji ? 'scale(1.1)' : 'scale(1)'
                    }}>
                      {m.emoji}
                      <span style={{ fontSize: '10px', color: 'rgba(255,255,255,0.4)', fontFamily: 'var(--font-body)' }}>
                        {m.label}
                      </span>
                    </button>
                  ))}
                </div>
                <textarea
                  className="input-field"
                  placeholder="Escribe sobre tu día, tus pensamientos, lo que sientes..."
                  value={journalText}
                  onChange={e => setJournalText(e.target.value)}
                  rows={5}
                  style={{ resize: 'none', marginBottom: '16px' }}
                />
                <button className="btn-primary" onClick={saveEntry} disabled={savingEntry}
                  style={{ background: 'linear-gradient(135deg, #00646a, #007f87)' }}>
                  {savingEntry ? '⏳ Guardando...' : '✨ Guardar entrada'}
                </button>
              </div>

              {/* Past entries */}
              <h3 style={{ fontFamily: 'var(--font-display)', fontWeight: '700', fontSize: '16px', color: 'rgba(255,255,255,0.6)', marginBottom: '14px' }}>
                Entradas anteriores
              </h3>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                {entries.map(entry => (
                  <div key={entry.id} style={{
                    background: 'rgba(0,100,106,0.08)', border: '1px solid rgba(0,100,106,0.15)',
                    borderRadius: '16px', padding: '18px'
                  }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '10px' }}>
                      <span style={{ fontSize: '24px' }}>{entry.mood}</span>
                      <p style={{ fontFamily: 'var(--font-display)', fontWeight: '600', fontSize: '14px', color: '#00c2cc' }}>
                        {new Date(entry.date + 'T12:00:00').toLocaleDateString('es-MX', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
                      </p>
                    </div>
                    {entry.journal_text && (
                      <p style={{ color: 'rgba(255,255,255,0.55)', fontSize: '13px', fontFamily: 'var(--font-body)', lineHeight: '1.6' }}>
                        {entry.journal_text}
                      </p>
                    )}
                  </div>
                ))}
                {entries.length === 0 && (
                  <p style={{ color: 'rgba(255,255,255,0.25)', fontSize: '13px', fontFamily: 'var(--font-body)' }}>
                    Aún no tienes entradas. ¡Empieza hoy!
                  </p>
                )}
              </div>
            </div>

            {/* Calendar */}
            <div>
              <div style={{ background: 'rgba(0,100,106,0.08)', border: '1px solid rgba(0,100,106,0.2)', borderRadius: '20px', padding: '20px', marginBottom: '16px' }}>
                <h3 style={{ fontFamily: 'var(--font-display)', fontWeight: '700', fontSize: '15px', color: '#00c2cc', marginBottom: '16px' }}>
                  📅 Calendario
                </h3>
                <Calendar onChange={(val) => setSelectedDate(val as Date)} value={selectedDate} />
              </div>

              {/* Mood history */}
              <div style={{ background: 'rgba(0,100,106,0.06)', border: '1px solid rgba(0,100,106,0.15)', borderRadius: '16px', padding: '16px' }}>
                <h4 style={{ fontFamily: 'var(--font-display)', fontWeight: '600', fontSize: '13px', color: 'rgba(255,255,255,0.5)', marginBottom: '12px' }}>
                  Estado de ánimo — últimos 7 días
                </h4>
                <div style={{ display: 'flex', gap: '8px' }}>
                  {entries.slice(0, 7).reverse().map(e => (
                    <div key={e.id} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '4px' }}>
                      <div style={{
                        width: '100%', maxWidth: '30px', borderRadius: '6px',
                        background: `rgba(0,194,204,${e.mood_score / 5 * 0.8 + 0.1})`,
                        height: `${e.mood_score * 10 + 10}px`, transition: 'height 0.5s ease'
                      }} />
                      <span style={{ fontSize: '14px' }}>{e.mood}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* TASKS TAB */}
        {activeTab === 'tasks' && (
          <div style={{ maxWidth: '680px' }}>
            {/* Add task */}
            <div style={{
              background: 'rgba(0,100,106,0.1)', border: '1px solid rgba(0,100,106,0.2)',
              borderRadius: '20px', padding: '24px', marginBottom: '24px'
            }}>
              <h3 style={{ fontFamily: 'var(--font-display)', fontWeight: '700', fontSize: '16px', color: '#00c2cc', marginBottom: '16px' }}>
                + Nueva tarea
              </h3>
              <div style={{ display: 'flex', gap: '10px', marginBottom: '10px' }}>
                <input className="input-field" placeholder="Nombre de la tarea" value={newTask}
                  onChange={e => setNewTask(e.target.value)} style={{ flex: 1 }}
                  onKeyDown={e => e.key === 'Enter' && addTask()} />
                <input type="date" className="input-field" value={taskDate} onChange={e => setTaskDate(e.target.value)}
                  style={{ width: '160px' }} />
              </div>
              <div style={{ display: 'flex', gap: '8px', marginBottom: '14px' }}>
                {PRIORITIES.map(p => (
                  <button key={p} onClick={() => setTaskPriority(p)} style={{
                    padding: '6px 14px', borderRadius: '20px', border: taskPriority === p ? `1px solid ${getPriorityColor(p)}` : '1px solid rgba(255,255,255,0.1)',
                    background: taskPriority === p ? `${getPriorityColor(p)}22` : 'transparent',
                    color: taskPriority === p ? getPriorityColor(p) : 'rgba(255,255,255,0.4)',
                    cursor: 'pointer', fontSize: '12px', fontFamily: 'var(--font-body)', transition: 'all 0.2s'
                  }}>{p}</button>
                ))}
              </div>
              <button className="btn-primary" onClick={addTask} style={{ background: 'linear-gradient(135deg, #00646a, #007f87)' }}>
                ✅ Agregar tarea
              </button>
            </div>

            {/* Task list */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
              {tasks.length === 0 && (
                <div style={{ textAlign: 'center', padding: '40px', color: 'rgba(255,255,255,0.25)' }}>
                  <p style={{ fontFamily: 'var(--font-body)' }}>No hay tareas. ¡Agrega una!</p>
                </div>
              )}
              {['Alta', 'Media', 'Baja'].map(priority => {
                const group = tasks.filter(t => t.priority === priority)
                if (!group.length) return null
                return (
                  <div key={priority}>
                    <p style={{ color: getPriorityColor(priority), fontSize: '12px', fontFamily: 'var(--font-display)', fontWeight: '600', marginBottom: '8px', marginTop: '8px' }}>
                      ● {priority} prioridad
                    </p>
                    {group.map(task => (
                      <div key={task.id} style={{
                        display: 'flex', alignItems: 'center', gap: '12px',
                        background: task.completed ? 'rgba(255,255,255,0.02)' : 'rgba(0,100,106,0.08)',
                        border: `1px solid ${task.completed ? 'rgba(255,255,255,0.05)' : 'rgba(0,100,106,0.2)'}`,
                        borderRadius: '14px', padding: '14px 16px', marginBottom: '8px',
                        transition: 'all 0.2s ease'
                      }}>
                        <button onClick={() => toggleTask(task)} style={{
                          width: '22px', height: '22px', borderRadius: '8px', flexShrink: 0,
                          border: task.completed ? 'none' : '2px solid rgba(0,194,204,0.5)',
                          background: task.completed ? '#00646a' : 'transparent',
                          cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
                          fontSize: '12px', transition: 'all 0.2s'
                        }}>
                          {task.completed ? '✓' : ''}
                        </button>
                        <div style={{ flex: 1 }}>
                          <p style={{
                            fontFamily: 'var(--font-body)', fontSize: '14px', color: task.completed ? 'rgba(255,255,255,0.25)' : 'rgba(255,255,255,0.8)',
                            textDecoration: task.completed ? 'line-through' : 'none'
                          }}>{task.title}</p>
                          {task.due_date && (
                            <p style={{ color: 'rgba(255,255,255,0.3)', fontSize: '11px', fontFamily: 'var(--font-body)', marginTop: '2px' }}>
                              📅 {new Date(task.due_date + 'T12:00:00').toLocaleDateString('es-MX')}
                            </p>
                          )}
                        </div>
                        <button onClick={() => deleteTask(task.id)} style={{
                          background: 'transparent', border: 'none', color: 'rgba(255,80,80,0.4)',
                          cursor: 'pointer', fontSize: '16px', padding: '4px'
                        }}>×</button>
                      </div>
                    ))}
                  </div>
                )
              })}
            </div>
          </div>
        )}

        {/* POMODORO TAB */}
        {activeTab === 'pomodoro' && (
          <div style={{ maxWidth: '480px', margin: '0 auto', textAlign: 'center' }}>
            <div style={{
              background: 'rgba(0,100,106,0.1)', border: '1px solid rgba(0,100,106,0.2)',
              borderRadius: '28px', padding: '48px 32px'
            }}>
              <p style={{
                fontFamily: 'var(--font-display)', fontWeight: '600', fontSize: '14px',
                color: pomMode === 'work' ? '#9c6bff' : '#00c2cc', marginBottom: '8px',
                textTransform: 'uppercase', letterSpacing: '2px'
              }}>
                {pomMode === 'work' ? '🍅 Tiempo de trabajo' : '🌿 Tiempo de descanso'}
              </p>

              {/* Circular timer */}
              <div style={{ position: 'relative', width: '220px', height: '220px', margin: '24px auto' }}>
                <svg width="220" height="220" style={{ transform: 'rotate(-90deg)', filter: 'drop-shadow(0 0 15px rgba(156,107,255,0.4))' }}>
                  <circle cx="110" cy="110" r="90" fill="none" stroke="rgba(255,255,255,0.06)" strokeWidth="12" />
                  <circle cx="110" cy="110" r="90" fill="none"
                    stroke={pomMode === 'work' ? '#9c6bff' : '#00c2cc'}
                    strokeWidth="12" strokeLinecap="round"
                    strokeDasharray={circumference}
                    strokeDashoffset={circumference * (1 - pomProgress)}
                    style={{ transition: 'stroke-dashoffset 1s ease' }}
                  />
                </svg>
                <div style={{
                  position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
                  alignItems: 'center', justifyContent: 'center'
                }}>
                  <span style={{
                    fontFamily: 'var(--font-display)', fontWeight: '800', fontSize: '42px', color: 'white'
                  }}>{formatTime(pomSeconds)}</span>
                  <span style={{ color: 'rgba(255,255,255,0.3)', fontSize: '12px', fontFamily: 'var(--font-body)' }}>
                    {pomCycles} ciclos
                  </span>
                </div>
              </div>

              <div style={{ display: 'flex', gap: '12px', justifyContent: 'center' }}>
                <button
                  onClick={() => setPomRunning(!pomRunning)}
                  style={{
                    padding: '14px 32px', borderRadius: '16px', border: 'none', cursor: 'pointer',
                    fontFamily: 'var(--font-display)', fontWeight: '700', fontSize: '15px',
                    background: pomRunning ? 'rgba(255,255,255,0.1)' : 'linear-gradient(135deg, #00646a, #007f87)',
                    color: 'white', transition: 'all 0.3s ease',
                    boxShadow: pomRunning ? 'none' : '0 8px 25px rgba(0,100,106,0.4)'
                  }}
                >
                  {pomRunning ? '⏸ Pausar' : '▶ Iniciar'}
                </button>
                <button onClick={resetPom} style={{
                  padding: '14px 20px', borderRadius: '16px', border: '1px solid rgba(255,255,255,0.1)',
                  background: 'transparent', color: 'rgba(255,255,255,0.5)', cursor: 'pointer',
                  fontFamily: 'var(--font-body)', fontSize: '13px'
                }}>↺ Reiniciar</button>
              </div>

              <div style={{ marginTop: '28px', padding: '16px', background: 'rgba(255,255,255,0.04)', borderRadius: '14px' }}>
                <p style={{ color: 'rgba(255,255,255,0.4)', fontSize: '12px', fontFamily: 'var(--font-body)', lineHeight: '1.6' }}>
                  🍅 La técnica Pomodoro consiste en 25 minutos de trabajo concentrado seguidos de 5 minutos de descanso. Después de 4 ciclos, toma un descanso largo de 15-30 minutos.
                </p>
              </div>
            </div>
          </div>
        )}

        {/* FOCUS TAB */}
        {activeTab === 'focus' && (
          <div style={{ maxWidth: '560px', margin: '0 auto', textAlign: 'center' }}>
            <div style={{
              background: 'rgba(4,25,45,0.8)', border: '1px solid rgba(0,100,106,0.25)',
              borderRadius: '28px', padding: '52px 40px'
            }}>
              <div style={{ fontSize: '60px', marginBottom: '20px' }}>🎯</div>
              <h2 style={{ fontFamily: 'var(--font-display)', fontWeight: '800', fontSize: '26px', color: 'white', marginBottom: '12px' }}>
                Modo Sin Distracciones
              </h2>
              <p style={{ color: 'rgba(255,255,255,0.4)', fontSize: '14px', fontFamily: 'var(--font-body)', lineHeight: '1.7', marginBottom: '32px' }}>
                Activa este modo para tener una pantalla limpia y silenciosa donde puedas escribir, tomar notas o simplemente concentrarte sin interrupciones.
              </p>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '14px', marginBottom: '28px' }}>
                {['✓ Sin notificaciones visuales', '✓ Pantalla completa limpia', '✓ Editor de texto minimalista', '✓ Contador de palabras'].map((f, i) => (
                  <div key={i} style={{
                    padding: '12px 16px', background: 'rgba(0,100,106,0.12)',
                    border: '1px solid rgba(0,100,106,0.2)', borderRadius: '12px',
                    color: 'rgba(255,255,255,0.6)', fontSize: '14px', fontFamily: 'var(--font-body)', textAlign: 'left'
                  }}>{f}</div>
                ))}
              </div>
              <button
                onClick={() => setFocusMode(true)}
                style={{
                  padding: '16px 40px', borderRadius: '16px', border: 'none', cursor: 'pointer',
                  fontFamily: 'var(--font-display)', fontWeight: '700', fontSize: '15px',
                  background: 'linear-gradient(135deg, #00646a, #007f87)',
                  color: 'white', boxShadow: '0 8px 30px rgba(0,100,106,0.4)',
                  transition: 'all 0.3s ease'
                }}
              >
                🎯 Activar modo enfoque
              </button>
            </div>
          </div>
        )}
      </div>
    </Layout>
  )
}
