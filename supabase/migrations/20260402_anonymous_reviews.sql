create extension if not exists pgcrypto;

create table if not exists public.teachers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  department text
);

create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  name text not null
);

create table if not exists public.profiles (
  user_id uuid primary key,
  display_name text not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  teacher_id uuid references public.teachers (id) on delete cascade,
  subject_id uuid references public.subjects (id) on delete cascade,
  text text not null default '',
  rating int not null check (rating between 1 and 5),
  created_at timestamptz not null default timezone('utc', now()),
  constraint reviews_target_check check (
    (teacher_id is not null and subject_id is null) or
    (teacher_id is null and subject_id is not null)
  )
);

create unique index if not exists reviews_one_per_teacher_per_user_idx
  on public.reviews (user_id, teacher_id)
  where teacher_id is not null;

create unique index if not exists reviews_one_per_subject_per_user_idx
  on public.reviews (user_id, subject_id)
  where subject_id is not null;

create index if not exists reviews_teacher_created_at_idx
  on public.reviews (teacher_id, created_at desc)
  where teacher_id is not null;

create index if not exists reviews_subject_created_at_idx
  on public.reviews (subject_id, created_at desc)
  where subject_id is not null;

alter table public.teachers enable row level security;
alter table public.subjects enable row level security;
alter table public.profiles enable row level security;
alter table public.reviews enable row level security;

drop policy if exists "teachers_are_publicly_readable" on public.teachers;
create policy "teachers_are_publicly_readable"
on public.teachers
for select
using (true);

drop policy if exists "subjects_are_publicly_readable" on public.subjects;
create policy "subjects_are_publicly_readable"
on public.subjects
for select
using (true);

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
on public.profiles
for select
using (auth.uid() = user_id);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
on public.profiles
for insert
with check (auth.uid() = user_id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "reviews_are_publicly_readable" on public.reviews;
create policy "reviews_are_publicly_readable"
on public.reviews
for select
using (true);

drop policy if exists "reviews_insert_for_owner_only" on public.reviews;
create policy "reviews_insert_for_owner_only"
on public.reviews
for insert
with check (auth.uid() = user_id);

create or replace function public.enforce_review_rate_limit()
returns trigger
language plpgsql
as $$
declare
  last_review_at timestamptz;
begin
  select created_at
  into last_review_at
  from public.reviews
  where user_id = new.user_id
  order by created_at desc
  limit 1;

  if last_review_at is not null and last_review_at > timezone('utc', now()) - interval '30 seconds' then
    raise exception 'Rate limit exceeded. Please wait before posting again.';
  end if;

  return new;
end;
$$;

drop trigger if exists review_rate_limit_trigger on public.reviews;
create trigger review_rate_limit_trigger
before insert on public.reviews
for each row
execute function public.enforce_review_rate_limit();

insert into public.teachers (id, name, department)
values
  ('11111111-1111-1111-1111-111111111111', 'Aigerim Saparova', 'Computer Science'),
  ('22222222-2222-2222-2222-222222222222', 'Daniyar Nurgaliyev', 'Mathematics'),
  ('33333333-3333-3333-3333-333333333333', 'Madina Orazbek', 'Physics'),
  ('44444444-4444-4444-4444-444444444444', 'Assel Tursynkyzy', 'English Philology'),
  ('55555555-5555-5555-5555-555555555555', 'Ruslan Bekmuratov', 'Pedagogy')
on conflict (id) do update
set
  name = excluded.name,
  department = excluded.department;

insert into public.subjects (id, name)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Introduction to Programming'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Discrete Mathematics'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Data Structures'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Academic English'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Educational Psychology')
on conflict (id) do update
set
  name = excluded.name;
