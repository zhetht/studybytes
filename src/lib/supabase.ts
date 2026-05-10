import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export type Database = {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          username: string
          avatar_color: string
          avatar_emoji: string
          bio: string
          created_at: string
        }
        Insert: {
          id: string
          username: string
          avatar_color?: string
          avatar_emoji?: string
          bio?: string
        }
        Update: {
          username?: string
          avatar_color?: string
          avatar_emoji?: string
          bio?: string
        }
      }
      posts: {
        Row: {
          id: string
          user_id: string
          content: string
          tags: string[]
          likes: number
          created_at: string
          username: string
          avatar_emoji: string
          avatar_color: string
        }
      }
      clubs: {
        Row: {
          id: string
          name: string
          description: string
          creator_id: string
          members_count: number
          created_at: string
        }
      }
      club_messages: {
        Row: {
          id: string
          club_id: string
          user_id: string
          content: string
          created_at: string
          username: string
          avatar_emoji: string
        }
      }
      library_items: {
        Row: {
          id: string
          user_id: string
          title: string
          description: string
          file_url: string
          file_type: string
          subject: string
          created_at: string
          username: string
        }
      }
      zen_entries: {
        Row: {
          id: string
          user_id: string
          mood: string
          mood_score: number
          journal_text: string
          date: string
          created_at: string
        }
      }
      tasks: {
        Row: {
          id: string
          user_id: string
          title: string
          due_date: string
          completed: boolean
          priority: string
          created_at: string
        }
      }
    }
  }
}
