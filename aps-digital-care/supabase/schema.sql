-- APS Digital Care starter schema. Run in Supabase SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text,
 role text not null default 'client' check (role in ('admin','employee','client')),
 created_at timestamptz not null default now()
);
create table if not exists public.services (
 id uuid primary key default gen_random_uuid(), title text not null, slug text unique not null,
 description text, active boolean not null default true, created_at timestamptz not null default now()
);
create table if not exists public.projects (
 id uuid primary key default gen_random_uuid(), client_id uuid references public.profiles(id),
 title text not null, description text, status text not null default 'planning',
 progress int not null default 0 check(progress between 0 and 100), created_at timestamptz not null default now()
);
create table if not exists public.project_updates (
 id uuid primary key default gen_random_uuid(), project_id uuid not null references public.projects(id) on delete cascade,
 title text not null, body text, created_at timestamptz not null default now()
);
create table if not exists public.inquiries (
 id uuid primary key default gen_random_uuid(), name text not null, email text not null,
 phone text, message text not null, source text default 'website', created_at timestamptz not null default now()
);
create table if not exists public.bookings (
 id uuid primary key default gen_random_uuid(), name text not null, email text not null,
 date date not null, message text, status text not null default 'pending', created_at timestamptz not null default now()
);
create table if not exists public.blogs (
 id uuid primary key default gen_random_uuid(), title text not null, slug text unique not null,
 excerpt text, body text, published boolean not null default false, created_at timestamptz not null default now()
);
create table if not exists public.testimonials (
 id uuid primary key default gen_random_uuid(), client_name text not null, company text,
 quote text not null, approved boolean not null default false, created_at timestamptz not null default now()
);
create table if not exists public.team_members (
 id uuid primary key default gen_random_uuid(), name text not null, role text, bio text,
 image_url text, active boolean not null default true, created_at timestamptz not null default now()
);
create table if not exists public.job_applications (
 id uuid primary key default gen_random_uuid(), name text not null, email text not null,
 role text, resume_url text, message text, created_at timestamptz not null default now()
);
create table if not exists public.newsletter_subscribers (
 id uuid primary key default gen_random_uuid(), email text unique not null,
 created_at timestamptz not null default now()
);
create table if not exists public.chat_messages (
 id uuid primary key default gen_random_uuid(), sender text not null, message text not null,
 created_at timestamptz not null default now()
);
create table if not exists public.notifications (
 id uuid primary key default gen_random_uuid(), user_id uuid references public.profiles(id) on delete cascade,
 title text not null, body text, read_at timestamptz, created_at timestamptz not null default now()
);
create table if not exists public.invoices (
 id uuid primary key default gen_random_uuid(), project_id uuid references public.projects(id),
 client_id uuid references public.profiles(id), invoice_number text unique not null,
 amount numeric(12,2) not null, currency text not null default 'INR',
 status text not null default 'draft', due_date date, created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
alter table public.projects enable row level security;
alter table public.project_updates enable row level security;
alter table public.inquiries enable row level security;
alter table public.bookings enable row level security;
alter table public.newsletter_subscribers enable row level security;
alter table public.blogs enable row level security;
alter table public.testimonials enable row level security;
alter table public.services enable row level security;
alter table public.team_members enable row level security;
alter table public.job_applications enable row level security;
alter table public.chat_messages enable row level security;
alter table public.notifications enable row level security;
alter table public.invoices enable row level security;
-- Public website: allow reading active service/team records and published blogs/approved testimonials.
create policy "Public reads active services" on public.services for select using (active = true);
create policy "Public reads active team" on public.team_members for select using (active = true);
create policy "Public reads published blogs" on public.blogs for select using (published = true);
create policy "Public reads approved testimonials" on public.testimonials for select using (approved = true);
-- Public forms: insert only. No public read/update/delete policies.
create policy "Anyone can submit inquiry" on public.inquiries for insert with check (true);
create policy "Anyone can request booking" on public.bookings for insert with check (true);
create policy "Anyone can subscribe" on public.newsletter_subscribers for insert with check (true);
-- Authenticated users can read/update their own profile. Admin policies should be added using trusted role checks.
create policy "Users read own profile" on public.profiles for select to authenticated using (auth.uid() = id);
create policy "Users update own profile" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);
create policy "Clients read own projects" on public.projects for select to authenticated using (client_id = auth.uid());
create policy "Clients read updates for own projects" on public.project_updates for select to authenticated using (exists(select 1 from public.projects p where p.id = project_id and p.client_id = auth.uid()));
create policy "Users read own notifications" on public.notifications for select to authenticated using (user_id = auth.uid());
create policy "Clients read own invoices" on public.invoices for select to authenticated using (client_id = auth.uid());
-- Create profile rows for new auth users. Role remains client by default; assign admin manually in SQL.
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path = public as $$
begin insert into public.profiles(id,full_name) values(new.id, coalesce(new.raw_user_meta_data->>'full_name','')); return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
-- After creating your own account, grant admin role manually:
-- update public.profiles set role='admin' where id='YOUR-AUTH-USER-UUID';
-- Important: add carefully reviewed admin-only policies before building admin CRUD.
