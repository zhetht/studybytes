-- =============================================
-- STUDYBYTES — SUPABASE SQL SCHEMA
-- Ejecuta esto en el SQL Editor de Supabase
-- =============================================

-- 1. PROFILES
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  username text not null,
  avatar_color text default '#9c6bff',
  avatar_emoji text default '📚',
  bio text default '',
  created_at timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "Users can view all profiles"
  on public.profiles for select using (true);

create policy "Users can insert own profile"
  on public.profiles for insert with check (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update using (auth.uid() = id);

-- 2. POSTS
create table if not exists public.posts (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  content text not null,
  tags text[] default '{}',
  likes integer default 0,
  username text not null,
  avatar_emoji text default '📚',
  avatar_color text default '#9c6bff',
  created_at timestamptz default now()
);

alter table public.posts enable row level security;

create policy "Posts are viewable by everyone"
  on public.posts for select using (true);

create policy "Users can insert own posts"
  on public.posts for insert with check (auth.uid() = user_id);

create policy "Users can update posts"
  on public.posts for update using (true);

create policy "Users can delete own posts"
  on public.posts for delete using (auth.uid() = user_id);

-- 3. CLUBS
create table if not exists public.clubs (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  description text default '',
  creator_id uuid references auth.users on delete cascade not null,
  members_count integer default 1,
  created_at timestamptz default now()
);

alter table public.clubs enable row level security;

create policy "Clubs are viewable by everyone"
  on public.clubs for select using (true);

create policy "Users can create clubs"
  on public.clubs for insert with check (auth.uid() = creator_id);

create policy "Creator can update clubs"
  on public.clubs for update using (auth.uid() = creator_id);

create policy "Creator can delete clubs"
  on public.clubs for delete using (auth.uid() = creator_id);

-- 4. CLUB MESSAGES
create table if not exists public.club_messages (
  id uuid default gen_random_uuid() primary key,
  club_id uuid references public.clubs on delete cascade not null,
  user_id uuid references auth.users on delete cascade not null,
  content text not null,
  username text not null,
  avatar_emoji text default '📚',
  created_at timestamptz default now()
);

alter table public.club_messages enable row level security;

create policy "Messages viewable by everyone"
  on public.club_messages for select using (true);

create policy "Users can insert messages"
  on public.club_messages for insert with check (auth.uid() = user_id);

create policy "Users can delete own messages"
  on public.club_messages for delete using (auth.uid() = user_id);

-- Enable realtime for club_messages
alter publication supabase_realtime add table public.club_messages;

-- 5. LIBRARY ITEMS
create table if not exists public.library_items (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  title text not null,
  description text default '',
  file_url text not null,
  file_type text default '',
  subject text default 'Otro',
  username text not null,
  created_at timestamptz default now()
);

alter table public.library_items enable row level security;

create policy "Library items viewable by everyone"
  on public.library_items for select using (true);

create policy "Users can upload to library"
  on public.library_items for insert with check (auth.uid() = user_id);

create policy "Users can delete own library items"
  on public.library_items for delete using (auth.uid() = user_id);

-- 6. ZEN ENTRIES
create table if not exists public.zen_entries (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  mood text default '',
  mood_score integer default 3,
  journal_text text default '',
  date date not null,
  created_at timestamptz default now(),
  unique(user_id, date)
);

alter table public.zen_entries enable row level security;

create policy "Users can view own zen entries"
  on public.zen_entries for select using (auth.uid() = user_id);

create policy "Users can insert own zen entries"
  on public.zen_entries for insert with check (auth.uid() = user_id);

create policy "Users can update own zen entries"
  on public.zen_entries for update using (auth.uid() = user_id);

create policy "Users can delete own zen entries"
  on public.zen_entries for delete using (auth.uid() = user_id);

-- 7. TASKS
create table if not exists public.tasks (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  title text not null,
  due_date date,
  completed boolean default false,
  priority text default 'Media',
  created_at timestamptz default now()
);

alter table public.tasks enable row level security;

create policy "Users can view own tasks"
  on public.tasks for select using (auth.uid() = user_id);

create policy "Users can insert own tasks"
  on public.tasks for insert with check (auth.uid() = user_id);

create policy "Users can update own tasks"
  on public.tasks for update using (auth.uid() = user_id);

create policy "Users can delete own tasks"
  on public.tasks for delete using (auth.uid() = user_id);

-- =============================================
-- STORAGE BUCKET
-- Crear manualmente en Storage > New Bucket:
-- Nombre: library
-- Public bucket: SI (habilitado)
-- Allowed MIME types: */* (o los que prefieras)
-- Max file size: 50 MB (plan gratuito)
-- =============================================
